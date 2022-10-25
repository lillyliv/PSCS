nasm -f bin src/boot/boot.asm -o build/boot.img
nasm -f bin build/data.asm -o build/data.img
qemu-system-x86_64 -fda build/boot.img -fdb build/data.img