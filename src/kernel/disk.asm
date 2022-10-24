sector: times 512 db 0
teststr: db "hellolmfao", 0xa, 0xd, 0x0

disktest:
    xor ax, ax    ; make sure ds is set to 0
    mov ds, ax
    cld
    ; start putting in values:
    mov ah, 2h    ; int13h function 3
    mov al, 1     ; we want to write 1 sectors
    mov ch, 0     ; from cylinder number 0
    mov cl, 6     ; the sector number 2 - second sector (starts from 1, not 0)
    mov dh, 0     ; head number 0
    xor bx, bx    
    mov es, bx    ; es should be 0
    mov bx, sector ; 512bytes from origin address 7c00h
    int 13h


    mov si, [sector]
    cmp si, 0
    je .nodata
    call print_string
    jmp .end
.nodata:
    

    mov ax, teststr
    mov [sector], ax

    xor ax, ax    ; make sure ds is set to 0
    mov ds, ax
    cld
    ; start putting in values:
    mov ah, 3h    ; int13h function 3
    mov al, 1     ; we want to write 1 sectors
    mov ch, 0     ; from cylinder number 0
    mov cl, 6     ; the sector number 2 - second sector (starts from 1, not 0)
    mov dh, 0     ; head number 0
    xor bx, bx    
    mov es, bx    ; es should be 0
    mov bx, sector ; 512bytes from origin address 7c00h
    int 13h 
    jmp .end
.end:
    ret