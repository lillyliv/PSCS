bits 16

text:
    ; int 69h
    call disktest
    ; int 71h
    mov ax, 4
    int 72h ; timer interrupt
    int 71h ; clearscreen interrupt
    int 70h ; return interrupt
    ; jmp $