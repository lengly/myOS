OBJS_BOOTPACK = bootpack.obj naskfunc.obj hankaku.obj graphic.obj dsctbl.obj \
			int.obj fifo.obj keyboard.obj mouse.obj memory.obj sheet.obj

TOOLS_PATH	:= ../z_tools/
INCPATH		:= $(TOOLS_PATH)haribote/

CC1 		:= wine $(TOOLS_PATH)cc1.exe -I $(INCPATH) -Os -Wall -quiet
GAS2NASK 	:= wine $(TOOLS_PATH)gas2nask.exe -a
NASK 		:= wine $(TOOLS_PATH)nask.exe
OBJ2BIM 	:= wine $(TOOLS_PATH)obj2bim.exe
RULEFILE 	:= $(TOOLS_PATH)haribote/haribote.rul
BIM2HRB 	:= wine $(TOOLS_PATH)bim2hrb.exe
MAKEFONT	:= wine $(TOOLS_PATH)makefont.exe
BIN2OBJ		:= wine $(TOOLS_PATH)bin2obj.exe

all:
	make img
	make sys
	sudo make copy

obj2bim : $(OBJS_BOOTPACK) 
	$(OBJ2BIM) @$(RULEFILE) out:bootpack.bim stack:3136k map:bootpack.map \
			$(OBJS_BOOTPACK)

bim2hrb : obj2bim
	$(BIM2HRB) bootpack.bim bootpack.hrb 0

sys : bim2hrb
	cat asmhead.bin bootpack.hrb > haribote.sys

hankaku.obj :
	$(MAKEFONT) hankaku.txt hankaku.bin
	$(BIN2OBJ) hankaku.bin hankaku.obj _hankaku

%.gas : %.c Makefile
	$(CC1) -o $*.gas $*.c

%.nas : %.gas Makefile
	$(GAS2NASK) $*.gas $*.nas

%.obj : %.nas Makefile
	$(NASK) $*.nas $*.obj $*.lst

img: nas
	dd if=bootloader of=os.img count=1 bs=512
	dd if=/dev/zero of=os.img bs=512 seek=1 count=2879

run:
	qemu-system-i386 -fda os.img

nas:
	$(NASK) ipl.nas bootloader ipl.lst
	$(NASK) asmhead.nas asmhead.bin

copy:
	mkdir -p /tmp/floppy
	mount -o loop os.img /tmp/floppy
	sleep 1
	cp haribote.sys /tmp/floppy
	sleep 1
	umount /tmp/floppy

clean:
	rm -rf os.img
	rm -rf bootloader ipl.lst
	rm -rf haribote.sys
	rm -rf asmhead.bin
	rm -rf *.lst *.obj *.bin
	rm -rf bootpack.gas bootpack.nas bootpack.bim bootpack.hrb bootpack.map
	rm -rf *~

