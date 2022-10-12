;
;   peoples secure computing system (PSCS)
;   kernel, 16 bit real mode.

bits 16

kernel:
    call clearscreen
    mov dh, 0
    mov dl, 0
    call movecursor
    mov si, loadedString
    call print_string

    call startVGA
    

    mov ax, 0
    mov bx, 0
    mov dl, 15

    call putPixel



kernel_loop:
    jmp kernel_loop

    ret

%include "src/kernel/vga.asm"