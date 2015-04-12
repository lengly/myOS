
run:
	make nasm
	qemu-system-i386 -fda helloos.img

nasm:
	nasm -o helloos.img helloos.nas

clean:
	rm -rf helloos.img *~
