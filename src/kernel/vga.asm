;
;   in:  nothing
;   out: nothing
;
startVGA:
    mov ax, 013h
    int 10h ; 320x200 16 color
    ret

;
;   in:  ax = Y coord, bx = X coord, dl = color
;   out: nothing
;

putPixel:

    mov ax, 0a000h
    mov es, ax

    push dx               ; oops, mul changes dx too
    mov cx, 320
    mul cx                ; multiply Y (ax) by 320 (one row)
    add ax, bx            ; and add X (bx) (result= dx:ax)
    mov di, ax
    pop dx
    mov [es:di], dl       ; store color/pixel
    ret