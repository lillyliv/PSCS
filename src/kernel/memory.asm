;
; in:  bx = source pointer, bp = destination pointer, ax = length in bytes
;

currentPos: dw 0
length: dw 0

memcpy:
    mov word [length], ax
.loop:

    mov byte al, [ds:bx]
    mov byte [ds:bp], al

    mov word ax, [length]
    cmp word [currentPos], ax
    je .end

    inc word bx
    inc word bp
    inc word [currentPos]

    jmp .loop

.end:
    ret

unreal_alloc:
unreal_inp: resb 512
unreal_inp_2: resb 512