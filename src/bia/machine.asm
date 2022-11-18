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
    mov dx, initcode
    call print_hex
    ; jmp initcode
    
.loop:

    xor ax, ax
    int 0x16

    cmp ah, 0x1c
    je .enter
    cmp ah, 0x39
    je .byteFinished

    mov bp, [byteStringPos]
    mov [byteStringPos+bp], al

    cmp byte [byteStringPos], 1
    je .resetByteStringPos

    inc byte [byteStringPos]

    jmp .loop

.enter:
    call clearscreen

    jmp initcode
.resetByteStringPos:

    mov byte [byteStringPos], 0
    jmp .loop

.byteFinished:

    mov ax, [currentByteString]
    call charsToNibbles

    mov bp, [editLocation]
    mov byte [initcode+bp], bl

    inc word [editLocation]

    jmp .resetByteStringPos
currentByteString: db 2
db 0
byteStringPos: db 1