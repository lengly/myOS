img: nasm
	dd if=/dev/zero of=os.img bs=512 count=2880
	dd if=bootloader of=os.img bs=512 count=1

run: img
	qemu-system-i386 -fda os.img

nasm:
	nasm -o bootloader -l ipl.lst ipl.nas

clean:
	rm -rf os.img
	rm -rf bootloader ipl.lst
	rm -rf *~
