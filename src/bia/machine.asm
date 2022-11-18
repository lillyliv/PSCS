;
; wip for running machine code
; 2022 Lilly
;

    ;  9 00000011 BE207C                  mov si, 7c20h ; random part of a string in bootloader
    ; 10 00000014 CD73                    int 0x73


; code: db 0xbe,0x20,0x7c,0xcd,0x73

initcode: times 512 nop ; code space for your program to load more stuff from elsewhere
initcodeEnd:
    ; mov si, 7c20h
    ; int 73h
    jmp $
editLocation: dw 0
runMachineCode:
    ; mov si, halting
    ; call print_string
    jmp initcode

; ax = char input (x2)
; bl = byte out
; a = 0, b = 1, c = 2, d = 3, e = 4, f = 5, g = 6, h = 7, i = 8, j = 9, k = 10
; l = 11, m = 12, n = 13, o = 14, p = 15 
charsToNibbles:
    sub al, 97
    sub ah, 97

    xchg al, ah ; swap first and second char

    mov cl, 4  ; using cl for compatability with cpu older than 80186
    rol ah, cl 
    mov cl, ah

    add al, cl

    mov bl, al

    ret
; tiny "editor" for the machine code
; loads code at 0x1000
machineEdit:
    ; makes the word "0x0001" and prints it


;839b
    ; 11 00000016 BE207C                  mov si, 7c20h
    ; 12 00000019 CD73                    int 0x73

    ; mov ax, "lo"
    ; call charsToNibbles
    ; mov [initcode], bl
    ; mov ax, "ca"
    ; call charsToNibbles
    ; mov [initcode+1], bl
    ; mov ax, "hm"
    ; call charsToNibbles
    ; mov [initcode+2], bl
    ; mov ax, "mn"
    ; call charsToNibbles
    ; mov [initcode+3], bl
    ; mov ax, "hd"
    ; call charsToNibbles
    ; mov [initcode+4], bl
    ; mov dx, initcode
    ; call print_hex
    ; jmp initcode
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
    mov ax, [currentByte]
    call charsToNibbles

    mov bx, [editLocation]
    mov byte [initcode+bx], al
    inc word [editLocation]
    mov word [currentByte], 0
    mov bp, 0
    jmp .loop
currentByte: resb 3