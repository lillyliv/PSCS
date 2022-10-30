;
; Peoples Secure Computing System built-in text editor
; 2022 Lilly
;
bits 16
fail: db "failed", 0
exiting: db "exiting Text editor", 0xa, 0xd, 0
filename: db "enter Filename: ", 0
char: resb 2
pos: dw 0

text:
    int 78h
    mov byte [bp], 1
    mov ch, 0
    mov cl, 1 ; sector
    mov dh, 0
    mov dl, 1
    ; mov al, 1
    int 76h
    cmp ax, 0
    je .fail

    int 79h
    mov si, bp
    int 73h

    mov ax, 4
    int 72h ; timer interrupt
    int 71h ; clearscreen interrupt
    jmp loop
.fail:
    mov si, fail
    int 73h
    jmp end
    ; jmp $

loop:
    xor ax, ax
    mov ah, 0x00
    int 0x16

    cmp byte al, 1bh
    je end

    mov [char], al
    mov si, char
    int 73h
    inc word [pos]
    jmp loop

end:
    mov si, exiting
    int 73h
    int 70h

saveFile:



    ret

readFileToBuffer:

    ret