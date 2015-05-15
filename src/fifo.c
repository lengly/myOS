#include "bootpack.h"

#define FLAGS_OVERRUN 0x0001

void fifo32_init(struct FIFO32 *fifo, int size, int *buf, struct TASK *task)
{
	fifo->size = size;
	fifo->buf = buf;
	fifo->p = fifo->q = fifo->flags = 0;
	fifo->free = size;
	fifo->task = task; /* 有数据写入时需要唤醒的任务 */
	return;
}

int fifo32_put(struct FIFO32 *fifo, int data)
{
	if (fifo->free == 0) {
		fifo->flags |= FLAGS_OVERRUN;
		return -1;
	}
	fifo->buf[fifo->p] = data;
	if (++fifo->p == fifo->size) {
		fifo->p = 0;
	}
	fifo->free--;
	if (fifo->task != 0) {
		if (fifo->task->flags != 2) { /* 如果任务处于休眠状态 */
			task_run(fifo->task, -1, 0); /* 将任务唤醒 */
		}
	}
	return 0;
}

int fifo32_get(struct FIFO32 *fifo)
{
	if (fifo->free == fifo->size) {
		return -1;
	}
	int data;
	data = fifo->buf[fifo->q];
	if (++fifo->q == fifo->size) {
		fifo->q = 0;
	}
	fifo->free++;
	return data;
}

int fifo32_status(struct FIFO32 *fifo)
{
	return fifo->size - fifo->free;
}
