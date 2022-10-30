;
;   peoples secure computing system (PSCS)
;   kernel, 16 bit real mode.
;

bits 16

INTERRUPT_VECTOR_TABLE equ 0000h
testt: db "testt", 0xa, 0xd, 0x0
buf: resb 10

kernel:
    mov si, loadedString
    call print_string

    mov ax, 9
    mov bx, testt
    mov bp, buf
    call memcpy
    mov si, buf
    call print_string

    mov al, 70h
    mov bx, returnInt
    call setInterrupt

    mov al, 71h
    mov bx, clearscreen
    call setInterrupt

    mov al, 72h
    mov bx, DELAY_TIMER
    call setInterrupt

    mov al, 73h
    mov bx, print_string
    call setInterrupt

    mov al, 74h
    mov bx, writeSector
    call setInterrupt

    mov al, 75h
    mov bx, readSector
    call setInterrupt

    mov al, 76h
    mov bx, readFile
    call setInterrupt

    mov al, 77h
    mov bx, writeFile
    call setInterrupt

    mov al, 78h
    mov bx, getAlStore
    call setInterrupt

    mov al, 79h
    mov bx, getSectorPointer
    call setInterrupt


kernel_loop:

    call getChar

    jmp kernel_loop
;
; in:  bx = source pointer, bp = destination pointer, ax = length in bytes
;

currentPos: dw 0
length: dw 0

memcpy:
    mov word [length], ax
.loop:

    mov byte al, [bx]
    mov byte [bp], al

    mov word ax, [length]
    cmp word [currentPos], ax
    je .end

    inc word bx
    inc word bp
    inc word [currentPos]

    jmp .loop

.end:
    ret

%include "src/kernel/vga.asm"
%include "src/kernel/svga.asm"
%include "src/kernel/terminal.asm"
%include "src/kernel/disk.asm"
%include "src/kernel/fs.asm"
%include "src/bia/text.asm"

times 1474560 - ($ - $$)  db 0 ; pad to the exact ammount of bytes on a "1.44 mb" floppy disk (double 720k)
                               ; https://www.quora.com/If-the-capacity-of-a-floppy-disk-is-1-44-MB-what-is-its-exact-capacity-in-bits/answer/Joe-Zbiciak?ch=10&oid=110788345&share=1ea5be2d&srid=unZYpZ&target_type=answer
