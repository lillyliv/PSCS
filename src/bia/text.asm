;
; Peoples Secure Computing System built-in text editor
; 2022 Lilly
;
; god what have i done
bits 16
text:
    int 71h ; clearscreen interrupt
    jmp loop

loop:
    xor ax, ax
    int 0x16

    cmp byte al, 1bh
    je end

    cmp byte ah, 0eh
    je .backspace

    mov dl, [screenposx]
    mov dh, [screenposy]
    call setpos

    mov [char], al
    mov si, char
    int 73h

    cmp byte [screenposx], 79
    je .endrow
    inc byte [screenposx]
.back:
    mov bp, [pos]
    mov byte [textBuffer+bp], al
    inc word [pos]
    jmp loop
.endrow:
    mov byte [screenposx], 0
    inc byte [screenposy]
    jmp .back
.endrowup:
    dec byte [screenposy]
    mov byte [screenposx], 79
    jmp .back
.backspace:
    dec word [pos]
    mov bp, [pos]
    mov byte [textBuffer+bp], 0
    cmp byte [screenposx], 0 
    je .endrowup
    dec byte [screenposx]
    mov al, " "
    mov dl, [screenposx]
    mov dh, [screenposy]
    call putCharAt
    jmp loop


prepFileMetaData:
    mov word [textfilemetadata],     "df" ; data floppy magic word
    mov byte [textfilemetadata+2],    0   ; cyl start of file is located at
    mov byte [textfilemetadata+3],    3   ; sect start of file is located at
    mov byte [textfilemetadata+4],    0   ; head start of file is located at
    mov word [textfilemetadata+5],   "hi" ; filename
    mov byte [textfilemetadata+100],  1   ; size in 512 byte sectors
    mov word [textfilemetadata+101], "me" ; file owner
    ret
end:
    jmp saveFile

saveFile:

    call prepFileMetaData

    int 79h
    mov bx, textBuffer
    int 7ah

    int 78h
    mov ch, 0
    mov cl, 2
    mov dh, 0
    mov dl, 1
    int 77h
    int 70h

readFileToBuffer:

    ret
;dh for row, dl for column
setpos:
    mov bh, 0
    mov ah, 02h
    int 10h

    ret

;dh for row, dl for column, al for char
putCharAt:

    call setpos

    xor ah, ah

    mov ah, 0Eh
	mov bx, 0007h	; gray colour, black background
    int 10h

    ret

fail: db "failed", 0
exiting: db "exiting Text editor", 0xa, 0xd, 0
filename: db "enter Filename: ", 0
char: resb 2
pos: dw 0
screenposx: db 0
screenposy: db 0
textBuffer: resb 2000 ; 80x25 chars
textfilemetadata: resb 512
textBufferEnd: db 0
