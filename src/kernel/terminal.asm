
qwetry db 'QWERTYUIOP[]', 10, 0, 'ASDFGHJKL:', 39, '~', 0, '|ZXCVBNM<>/'
charInp db 0, 0
space db " ", 0x0
haltcmd db "HALT", 0x0
textcmd db "TEXT", 0x0
termRam times 100 db 0
termRamPos dw 0x0


getChar:

    xor ax, ax
    mov ah, 0x00
    int 0x16
    mov al, ah
    cmp al, 1 ; esc
    jne notEsc
    call clearscreen

    mov dx, 0
    call movecursor

    mov word [termRamPos], 0
    xor cx, cx

escLoop:


    mov [termRamPos], cx
    mov bx, [termRamPos]
    mov byte [termRam + bx], 0

    inc cx
    cmp cx, 99
    jne escLoop

    mov word [termRamPos], 0

    ret
notEsc:

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

    ; jmp done

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

    ret

runCMD:

    xor ah, ah
    
    mov bx, termRam
    mov bp, haltcmd

    call compareString
    cmp ah, 1
    je halt

    mov bx, termRam
    mov bp, textcmd

    call compareString
    cmp ah, 1
    je text

    call clearscreen
    jmp donecmd
donecmd:

    mov bx, [termRamPos]
    mov byte [termRam + bx], 0
    mov word [termRamPos], 0

    ; call clearscreen

    xor cx, cx
    call escLoop
    ret