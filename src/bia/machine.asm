;
; wip for running machine code
; 2022 Lilly
;

initcode: times 512 nop ; code space for your program to load more stuff from elsewhere
initcodeEnd:
    jmp kernel_loop
editLocation: dw 0
runMachineCode:
    call clearscreen
    jmp initcode

; cx = char input (x2)
; cl = byte out
; a = 0, b = 1, c = 2, d = 3, e = 4, f = 5, g = 6, h = 7, i = 8, j = 9, k = 10
; l = 11, m = 12, n = 13, o = 14, p = 15 
charsToNibbles:
    sub cl, 97 ; a is ascii 97 so this converts the alphabet into int
    sub ch, 97 ;

    lock xchg cl, ch ; swap first and second char
                     ; lock prefix insures we dont get interrupted during xchg

    rol ch, 4  ; rotate left by 4 bits
    add cl, ch ; put the two numbers back together

    ret

; tiny "editor" for the machine code
; loads code at 0x1000
machineEdit:
    call clearscreen
    xor bp, bp
.loop:
    xor ax, ax
    int 16h

    cmp al, 0x20
    je .doneByte
    cmp al, 0x1b
    je runMachineCode

    mov [currentByte+bp], al

    cmp bp, 1
    je .decBP

    inc bp

    jmp .loop
.decBP:
    mov bp, 0
    jmp .loop

.doneByte:
    mov cx, [currentByte]
    call charsToNibbles

    pusha
    mov si, currentByte
    call print_string
    popa

    mov bx, [editLocation]
    mov byte [initcode+bx], cl
    inc word [editLocation]
    mov word [currentByte], 0
    mov bp, 0
    jmp .loop
currentByte: resb 2
db " "
db 0