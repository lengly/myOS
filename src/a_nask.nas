[FORMAT "WCOFF"]				; 制作目标文件的模式
[INSTRSET "i486p"]
[BITS 32]						; 制作32位模式用的机器语言
[FILE "a_nask.nas"]				; 源文件名信息

		GLOBAL	_api_putchar
		GLOBAL	_api_end

[SECTION .text]

_api_putchar:					; void api_putchar(int c);
		MOV			EDX,1
		MOV			AL,[ESP+4]	; c
		INT 		0x40
		RET

_api_end:						; void api_end(void);
		MOV			EDX,4
		INT 		0x40