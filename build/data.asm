
;boot sector to notify user if they try to boot from their PSCS Data Disk

org 7C00h


jmp notbootable

times $$ + 3 - $ nop

db "PDD", 0
nbd: db "Boot from your PSCS OS disk; this is a data disk", 0


notbootable:
    mov si,nbd
    mov dx, 0
    call print_string

    jmp $
print_string:
    ; mov dl, 0
	pusha

    ; mov dh, 2
    ; mov dl, 1
    mov  bh, 1        ; DisplayPage
    mov  ah, 02h      ; BIOS.SetCursorPosition
    int  10h

	mov ah, 0Eh
	mov bx, 0007h	; gray colour, black background
print_string_loop:
	lodsb
	cmp al, 0		; strings are 0-terminated
	je print_string_done
	int 10h
	jmp print_string_loop
print_string_done:
	popa
    inc dh
	ret


times 512 - 2 - ($ - $$)  db 0		; pad to 512 bytes minus one word for boot magic
 
dw 0AA55h		; BIOS expects this signature at the end of the boot sector


times 1474560 - ($ - $$)  db 0 ; one floppy drive of zeros for the data drive
                               ; see https://www.quora.com/If-the-capacity-of-a-floppy-disk-is-1-44-MB-what-is-its-exact-capacity-in-bits/answer/Joe-Zbiciak?ch=10&oid=110788345&share=1ea5be2d&srid=unZYpZ&target_type=answer
                               ; as to why this exact number