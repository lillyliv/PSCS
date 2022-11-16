
sector: times 512 db 0

; ch = cyl num, cl = sect num, dh = head num, dl = drive number (BE CAUTIOUS WITH DRIVE ZERO)
writeSector:
    pusha
    cld
    mov ah, 3h
    mov al, 1
    xor bx, bx    
    mov es, bx
    mov bx, sector
    int 13h 
    popa
    ret


readSector:
    pusha
    cld
    mov ah, 2h
    mov al, 1
    xor bx, bx    
    mov es, bx
    mov bx, sector
    int 13h
    popa
    ret
