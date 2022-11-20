nasm -f bin src/boot/boot.asm -o build/boot.img
nasm -f bin build/data.asm -o build/data.img
qemu-system-x86_64 -m 1000M -fda build/boot.img -fdb build/data.img -audiodev coreaudio,id=audio0 -machine pcspk-audiodev=audio0