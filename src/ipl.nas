; ipl-os
; TAB=4
CYLS	EQU		10

		ORG		0x7c00
		JMP		entry
; 以下这段是标准FAT12格式软盘专用的代码

		DB		0x90
		DB		"HELLOIPL"		; 启动区的名称可以是任意的字符串(8字节)
		DW		512				; 每个扇区 (sector)的大小 (必须为512字节)
		DB		1				; 簇 (cluster)的大小 (必须为1个扇区)
		DW		1				; FAT的起始位置 (一般从第一个扇区开始)
		DB		2				; FAT的个数 (必须为2)
		DW		224				; 根目录的大小 (一般设成224项)
		DW		2880			; 该磁盘的大小 (必须是2880扇区)
		DB		0xf0			; 磁盘的种类 (必须是0xf0)
		DW		9				; FAT的长度 (必须是9扇区)
		DW		18				; 1个磁道(track)有几个扇区 (必须是18)
		DW		2				; 磁头数 (必须是2)
		DD		0				; 不是用分区，必须是0
		DD		2880			; 重写一次磁盘大小
		DB		0,0,0x29		; 意义不明，固定
		DD		0xffffffff		; (可能是) 卷标号码
		DB		"HELLO-OS   "	; 磁盘的名称 (11字节)
		DB		"FAT12   "		; 磁盘格式名称 (8字节)
		RESB	18				; 先空出18字节

; 程序核心

entry:
		MOV		AX,0
		MOV		SS,AX
		MOV		DS,AX			; 段寄存器清零
		MOV		ES,AX
		
		MOV		SP,0x7c00
		
		MOV		SI,msg
		CALL	putloop

; 读入内容到内存
		MOV		AX,0x0820
		MOV		ES,AX
		MOV		CH,0			; 柱面0
		MOV		DH,0			; 磁头0
		MOV		CL,2			; 扇区2

readloop:
		MOV		SI,0			; 记录失败次数的寄存器

retry:
		MOV		AH,0x02			; AH=0x02 : 读盘
		MOV		AL,1			; 1个扇区
		MOV		BX,0
		MOV		DL,0x00			; A驱动器
		INT		0x13			; 调用磁盘BIOS
		JNC		next			; 没出错就跳到next
		ADD		SI,1
		CMP		SI,5
		JAE		error
		MOV		AH,0x00
		MOV		DL,0x00			; A驱动器
		INT		0x13			; 重置驱动器
		JMP		retry
next:
		MOV		AX,ES
		ADD		AX,0x0020
		MOV		ES,AX
		ADD		CL,1
		CMP		CL,18
		JBE		readloop		; CL <= 18 则跳转到readloop继续读
		MOV		CL,1
		ADD		DH,1
		CMP		DH,2
		JB		readloop		; 18个扇区读完之后增加磁头
		MOV		DH,0
		ADD		CH,1
		CMP		CH,CYLS
		JB		readloop		; 两面磁头都读完之后增加柱面

		MOV		[0x0ff0],CH		; 把CYLS的值写到0x0ff0的地址中
		JMP		fin

putloop:
		MOV		AL,[SI]
		ADD		SI,1
		CMP		AL,0
		JE		over
		MOV		AH,0x0e			; 显示一个文字
		MOV		BX,15			; 指定字符颜色
		INT		0x10			; 调用显卡BIOS
		JMP		putloop
over:
		ret
fin:
		JMP		0xc400			; 执行内容
error:
		MOV		SI,errormsg
		JMP		putloop
msg:
		DB		0x0a, 0x0a		; 换行两次
		DB		"hello, world"
		DB		0x0a			; 换行
		DB		0
errormsg:
		DB		0x0a, 0x0a		; 换行两次
		DB		"load error"
		DB		0x0a			; 换行
		DB		0

		TIMES 510-($-$$) db 0	; 填写0x00 直到0x001fe

		DB		0x55, 0xaa

