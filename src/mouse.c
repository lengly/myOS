#include "bootpack.h"

struct FIFO8 mousefifo;

void inthandler2c(int *esp)
{
	unsigned char data;
	io_out8(PIC1_OCW2, 0x64);	/* 通知PIC1 IRQ－12的受理已经完成 */
	io_out8(PIC0_OCW2, 0x62);	/* 通知PIC0 IRQ－12的受理已经完成 */
	data = io_in8(PORT_KEYDAT);
	fifo8_put(&mousefifo, data);
	return;
}

#define KEYCMD_SENDTO_MOUSE		0xd4
#define MOUSECMD_ENABLE			0xf4

void enable_mouse(struct MOUSE_DEC *mdec)
{
	wait_KBC_sendready();
	io_out8(PORT_KEYCMD, KEYCMD_SENDTO_MOUSE);
	wait_KBC_sendready();
	io_out8(PORT_KEYDAT, MOUSECMD_ENABLE);
	mdec->phase = 0;  /* 等待鼠标进入0xfa的状态 */
	return;
}

int mouse_decode(struct MOUSE_DEC *mdec, unsigned char data)
{
	if (mdec->phase == 0) {
		/* 等待鼠标的0xfa的阶段 */
		if (data == 0xfa) {
			mdec->phase = 1;
		}
		return 0;
	} else if (mdec->phase == 1) {
		/* 等待鼠标第一字节的阶段 */
		if ((data & 0xc8) == 0x08) {
			/* 如果第一字节正确 */
			mdec->buf[0] = data;
			mdec->phase = 2;
		}
		return 0;
	} else if (mdec->phase == 2) {
		/* 等待鼠标第二字节的阶段 */
		mdec->buf[1] = data;
		mdec->phase = 3;
		return 0;
	} else if (mdec->phase == 3) {
		/* 等待鼠标第三字节的阶段 */
		mdec->buf[2] = data;
		mdec->phase = 1;	
		mdec->btn = mdec->buf[0] & 0x07;
		mdec->x = mdec->buf[1];
		mdec->y = mdec->buf[2];
		if ((mdec->buf[0] & 0x10) != 0) {
			mdec->x |= 0xffffff00;
		}
		if ((mdec->buf[0] & 0x20) != 0) {
			mdec->y |= 0xffffff00;
		}
		mdec->y = - mdec->y; /* 鼠标y轴方向与画面方向相反 */
		return 1;
	}
	return -1;
}

