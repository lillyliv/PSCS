
sector: times 512 db 0

writeSector:
    pusha
    xor ax, ax    ; make sure ds is set to 0
    mov ds, ax
    cld
    ; start putting in values:
    mov ah, 3h     ; int13h function 3
    mov al, 1      ; we want to write 1 sectors
    ; mov ch, 0    ; from cylinder number 0
    ; mov cl, 5    ; the sector number (starts from 1, not 0)
    ; mov dh, 0    ; head number 0
    xor bx, bx    
    mov es, bx     ; es should be 0
    mov bx, sector ; 512bytes from origin address 7c00h
    ; mov dl, 1    ; drive number
    int 13h 
    popa
    ret


readSector:
    xor ax, ax    ; make sure ds is set to 0
    mov ds, ax
    cld
    ; start putting in values:
    mov ah, 2h      ; int13h function 3
    mov al, 1       ; we want to write 1 sectors
    ; mov ch, 0     ; from cylinder number 0
    ; mov cl, 5     ; the sector number (starts from 1, not 0)
    ; mov dh, 0     ; head number 0
    xor bx, bx    
    mov es, bx      ; es should be 0
    mov bx, sector  ; 512bytes from origin address 7c00h
    ; mov dl, 1
    int 13h
    ret
