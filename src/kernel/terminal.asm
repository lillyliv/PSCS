
qwetry db 'QWERTYUIOP[]', 10, 0, 'ASDFGHJKL:', 39, '~', 0, '|ZXCVBNM<>/'
charInp db 0, 0
space db " ", 0x0
haltcmd db "HALT", 0x0
textcmd db "TEXT", 0x0
rebootcmd db "REBOOT", 0x0
machinecmd db "MACHINE", 0x0

commie:
 db "                     ,.                 ", 0xa, 0xd
db "                       *@@@/             ", 0xa, 0xd
db "                          ,@@@@          ", 0xa, 0xd
db "          @@@@@@@@@          @@@@@       ", 0xa, 0xd
db "       /@@@@@@@@@             *@@@@.     ", 0xa, 0xd
db "     @@@@@@@@@@@@               @@@@*    ", 0xa, 0xd
db "    @@@@@@@@&@@@@@@@            @@@@@    ", 0xa, 0xd
db "       @@@.    /@@@@@@&         *@@@@(   ", 0xa, 0xd
db "                  (@@@@@@&      @@@@@#   ", 0xa, 0xd
db "                     %@@@@@@#  @@@@@@    ", 0xa, 0xd
db "           @&           &@@@@@@@@@@@/    ", 0xa, 0xd
db "      @@#@@@@@@&          @@@@@@@@@      ", 0xa, 0xd
db "      @@@@@  @@@@@@@@@@@@@@@@@@@@@@@@.   ", 0xa, 0xd
db "   @@@@@*       ,@@@@@@@@@@@@.   /@@@@@@,", 0xa, 0xd
db " /@@@@@                             (@@@@", 0

termRam times 100 db 0
termRamPos dw 0x0
termChar db "$ ", 0
commandsListPointers resw 50
commandsListStringPointers resw 50
commiecmd db "COMMIE", 0

commieDraw:
    xor dx, dx
    call movecursor
    mov si, commie
    call print_string
    xor ax, ax
    int 16h
    ret
setupInitalCommands:
    pusha

    mov bp, text
    mov [commandsListPointers+0], bp
    mov bp, textcmd
    mov [commandsListStringPointers+0], bp

    mov bp, reboot
    mov [commandsListPointers+2], bp
    mov bp, rebootcmd
    mov [commandsListStringPointers+2], bp

    mov bp, halt
    mov [commandsListPointers+4], bp
    mov bp, haltcmd
    mov [commandsListStringPointers+4], bp

    mov bp, commieDraw
    mov [commandsListPointers+6], bp
    mov bp, commiecmd
    mov [commandsListStringPointers+6], bp

    mov bp, machineEdit
    mov [commandsListPointers+8], bp
    mov bp, machinecmd
    mov [commandsListStringPointers+8], bp

    popa
    ret
getChar:

    xor ax, ax
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

    mov bx, [termRamPos]

    ; mov byte [sector + bx], 0

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

    ; mov byte [sector + bx], al

    inc word [termRamPos]

    mov dl, 0
    mov dh, 0
    call movecursor

    mov si, termChar
    call print_string

    mov si, termRam
    call print_string

    ret

runCMD:
    xor si, si
.loop:

    mov cx, commandsListPointers
    mov dx, commandsListStringPointers

    add cx, si
    add cx, si
    add dx, si
    add dx, si

    cmp si, 50
    je .done

    mov bp, termRam
    mov bx, dx
    mov ax, [bx]
    mov bx, ax
    push dx
    push cx
    push si
    call compareString
    pop si
    pop cx
    pop dx
    
    cmp ah, 1
    je .execute

    inc si

    jmp .loop
.execute:
    mov bx, cx
    call [bx]
.done:

    call clearscreen
    jmp donecmd
donecmd:

    mov bx, [termRamPos]
    mov byte [termRam + bx], 0
    mov word [termRamPos], 0

    mov  ax, 3    ; BIOS video mode 80x25 16-color text
    int  10h      ; this also happens to clear the screen.

    xor cx, cx
    call escLoop

    xor dx, dx
    call movecursor

    mov si, termChar
    call print_string

    ret