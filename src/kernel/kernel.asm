;
;   peoples secure computing system (PSCS)
;   kernel, 16 bit real mode.

bits 16

qwetry db 'QWERTYUIOP[]', 10, 0, 'ASDFGHJKL:', 39, '~', 0, '|ZXCVBNM<>/'
charInp db 0, 0
char db 0
space db " ", 0x0

termRam db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
termRamPos dw 0

kernel:
    mov si, loadedString
    call print_string

    mov dx, 0
    push dx

    ; mov word [termRamPos], termRam

kernel_loop:
    call getChar

    jmp kernel_loop

    ret

; god save me from the spaghetti

getChar:

    xor ax, ax
    mov ah, 0x00
    int 0x16
    mov al, ah
    cmp al, 1 ; esc
    jne .notEsc
    call clearscreen

    mov dx, 0
    call movecursor

    mov word [termRamPos], 0
    xor cx, cx

.escLoop:


    mov [termRamPos], cx
    mov bx, [termRamPos]
    mov byte [termRam + bx], 0

    inc cx
    cmp cx, 99
    jne .escLoop

    mov word [termRamPos], 0

    ret
.notEsc:


    cmp al, 0x39
    je spaceP
    cmp al, 0x0e
    je backspaceP
    cmp al, 0x35 ; highest scan code
    ja done
    sub al, 0x10 ; lowest scan code
    jb done
    mov bx, qwetry
    xlat
    mov [charInp], al
    mov si, charInp
    ; call print_string

    jmp done

backspaceP:

    cmp word [termRamPos], 0
    je backspacePdone

    dec word [termRamPos]
    mov bx, [termRamPos]
    mov byte [termRam + bx], 0

    mov byte dl, [termRamPos]
    mov dh, 0
    call movecursor

    mov si, space
    call print_string

    mov byte dl, [termRamPos]
    mov dh, 0
    call movecursor

    ret

backspacePdone:

    ret

spaceP:
    mov si, space
    call print_string

    mov al, " "

    jmp done

done:


    cmp byte [termRamPos], 99
    je backspacePdone

    mov bx, [termRamPos]
    mov byte [termRam + bx], al
    inc word [termRamPos]

    mov dl, 0
    mov dh, 0
    call movecursor

    mov si, termRam
    call print_string

    ; mov si, termRam
    ; call print_string
    ret

runCMD:

    pusha

    


    popa

    ret


%include "src/kernel/vga.asm"
%include "src/kernel/svga.asm"