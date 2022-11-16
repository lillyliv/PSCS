;
;   The PSCS Filesystem is inspired by USTAR and FAT12
;   https://wiki.osdev.org/USTAR   https://wiki.osdev.org/FAT#FAT_12
;   This filesystem is meant to be modified in place however
;

; filemetadata structure
; 0-2 sector magic word ("df" ascii)
; 3 data cylinder
; 4 data sector
; 5 data head
; 6-100 filename 
; 101 filesize (measured in 512 byte sectors)
; 102-152 owner (username can only be 50 bytes)
; 153-511 reserved

alstore: resb 1

getAlStore:
    mov bp, alstore
    ret

; in: ch=metadata cylinder, cl=sector, dh=head, dl=drive

getFilesize:
    call readSector
    mov bp, [sector + 101]
    ret

getSectorPointer:
    mov bp, sector
    ret

;
; reads a 512 byte block from a file to sector pointer
; in: ch=metadata cylinder, cl=sector, dh=head, dl=drive, al=block number
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
; writes a 512 byte block to a file from the sector pointer
; in: ch=metadata cylinder, cl=sector, dh=head, dl=drive, al=block number
; out: ax=escape code (1 success, 0 fail)
;
writeFile:
    call writeSector
    ret



getFileFromTable:
    ret