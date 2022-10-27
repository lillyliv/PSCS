;
;   The PSCS Filesystem is inspired by USTAR
;   https://wiki.osdev.org/USTAR
;   This filesystem is meant to be modified in place however
;



; 0-2 sector magic word ("df" ascii)
; 3 cylinder
; 4 sector
; 5 head
; 6-100 filename 
; 101 filesize (measured in 512 byte sectors)
; 102-152 owner (username can only be 50 bytes)
; 153-512 reserved
;
;
;

filemetadata: resb 512
alstore: resb 1

getAlStore:
    mov bp, alstore
    ret

;
; in: ch=metadata cylinder, cl=sector, dh=head, dl=drive, al=block
; out: ax=escape code (1 success, 0 fail)
;
readFile:

    ; mov [alstore], al

    call readSector

    ; mov si, sector
    ; call print_string

    cmp word [sector], "df"
    je .fail

    mov bp, [alstore]
    add [sector + 3], bp
    mov cl, [sector + 3]
    ; add al, cl
    ; inc cl
    ; mov dh, [sector + 4]
    mov ch, 0
    ; mov cl, 3
    mov dh, 0
    mov dl, 1

    call readSector

    mov ax, 1
    ret

.fail:
    xor ax, ax
    ret

;
;   push index, pointer to data ( ends with 0, escape byte is 5C (backslash) )
;
writeFile:

    ret





; ;
; ;   push index, drive
; ;   pop cylinder, head, sector, location
; ;
; getFileFromTable:
;     mov ch, 0 ; first track (starts from 0)
;     mov cl, 2 ; second sector (starts from 1)
;     mov dh, 0 ; first head of two (starts from 0)
;     pop ax    ; drive number
;     mov dl, ah

;     call readSector

;     pop ax
;     mov cx, 3
;     mul cx
;     mov bx, ax

;     push word [sector+bx] ;location
;     push word [sector+bx+1] ;sector
;     push word [sector+bx+2] ;head
;     push word [sector+bx+3] ;track

;     push 0
;     push 0
;     push 3
;     push 0

;     ret