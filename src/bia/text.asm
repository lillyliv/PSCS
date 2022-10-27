bits 16
fail: db "failed", 0
text:
    ; int 69h
    ; call disktest
    ; int 71h

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

    mov si, sector
    int 73h

    mov ax, 4
    int 72h ; timer interrupt
    int 71h ; clearscreen interrupt
    int 70h ; return interrupt
.fail:
    mov si, fail
    int 73h
    int 70h
    ; jmp $