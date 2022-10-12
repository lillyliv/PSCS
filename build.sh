nasm -f bin src/boot/boot.asm -o build/boot.bin
qemu-system-x86_64 -fda build/boot.bin 