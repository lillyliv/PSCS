;
;   peoples secure computing system (PSCS)
;   kernel, 16 bit real mode.

bits 16

qwetry db 'QWERTYUIOP[]', 10, 0, 'ASDFGHJKL:', 39, '~', 0, '|ZXCVBNM<>/'
charInp db 0, 0
char db 0
space db " ", 0x0
haltcmd db "HALT", 0x0
return db "RETURN", 0x0

termRam db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
termRamPos dw 0, 0
cmpRamPos dw 0, 0

kernel:
    mov si, loadedString
    call print_string

    mov dx, 0
    push dx

    ; mov word [termRamPos], termRam

kernel_loop:
    ; cmp sp, 0x600
    ; jl halt

    call getChar

    jmp kernel_loop

    ret

;
;   in: two string pointers in bx and bp
;   out: 1 or 0 in ah
;   this took an ungodly ammount of time to get working
;
compareString:
    mov ah, 1
.loop:


    mov ch, [bp]
    mov cl, [bx]
    cmp cl, ch
    jne .false


    cmp byte [bp], 0
    je .end
    cmp byte [bx], 0
    je .end


    inc bp
    inc bx

    jmp .loop

    ret

.false:
    mov ah, 0
    ret
.end:
    ret

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

    cmp al, 0x1c
    je runCMD
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
    ; mov [charInp], al
    ; mov si, charInp
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

    xor ah, ah

    ; push termRam
    ; push haltcmd

    mov bx, termRam
    mov bp, haltcmd

    call compareString

    ; mov word [termRam], "ha"
    ; cmp word [termRam], "HA"

    ; pop ax

    cmp ah, 1
    je halt

    popa

    ret

%include "src/kernel/vga.asm"
%include "src/kernel/svga.asm"