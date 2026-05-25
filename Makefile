ASM=nasm

all: boot.img
	qemu-system-i386 -drive format=raw,file=boot.img

boot.img: boot.bin kernel.bin
	cat boot.bin kernel.bin > boot.img

boot.bin: boot.asm
	$(ASM) -f bin boot.asm -o boot.bin

kernel.bin: kernel.asm
	$(ASM) -f bin kernel.asm -o kernel.bin
	truncate -s 2048 kernel.bin

clean:
	rm -f *.bin *.img
