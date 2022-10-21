;
;   peoples secure computing system (PSCS)
;   bootloader, inspired by SnowDrop os
;   http://sebastianmihai.com/snowdrop/
;

bits 16
org 7C00h

jmp load_kernel
times $$ + 3 - $ nop

STACK_SEGMENT equ 1000h ; 1000h in memory, this is below the bootloader and kernel.

loadedString:	db "Peoples Secure Computing System loaded!", 0xa, 0xd, 0x0
initialLoading:	db "Peoples Secure Computing System loading...", 0xa, 0xd, 0x0
loadedSector: db "10 extra floppy sectors loaded, this should be enough.", 0xa, 0xd, 0x0
halting: db "halting (not a good sign)", 0xa, 0xd, 0x0
clean: db "                                                                                ", 0xa, 0xd, 0x0 
; 80 column spaces to clear screen, theres definitally a better way to do this but this works fine

load_kernel:

    cli

    mov ax, STACK_SEGMENT
    mov ss, ax
    xor sp, sp

    sti
    push cs
    pop ds

    mov  ax, 0003h    ; BIOS video mode 80x25 16-color text
    int  10h


    mov dx, 0
    mov si, initialLoading
    call print_string


    ; https://en.wikipedia.org/wiki/INT_13H
    ; thank god wikipedia exists

    ; between this line and "jmp 7e00h" loads some sectors from floppy with CHS method and loads it into 7e00h in memory
    ; 7e00h is exactly 512 bytes after our 512 byte bootsector in memory, so it lines up perfectly.

   xor ax, ax    ; make sure ds is set to 0
   mov ds, ax
   cld
   ; start putting in values:
   mov ah, 2h    ; int13h function 2
   mov al, 10    ; we want to read 10 sectors
   mov ch, 0     ; from cylinder number 0
   mov cl, 2     ; the sector number 2 - second sector (starts from 1, not 0)
   mov dh, 0     ; head number 0
   xor bx, bx    
   mov es, bx    ; es should be 0
   mov bx, 7e00h ; 512bytes from origin address 7c00h
   int 13h
   jmp 7e00h     ; jump to the next sector

halt:
    mov si, halting
    call print_string
    jmp $


;si = pointer to string (null terminated)
;bx in stack for row/col
;dh for row, dl for column in bx
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

;dh=row
;dl=col
movecursor:

    mov bh, 0
    mov ah, 02h
    int 10h

    ret

clearscreen:
    mov dh, 0
    
clearscreenloop:

    mov si, clean
    call print_string

    cmp dh, 25
    jne clearscreenloop

    ret

times 512 - 2 - ($ - $$)  db 0		; pad to 512 bytes minus one word for boot magic
 
dw 0AA55h		; BIOS expects this signature at the end of the boot sector

finalize_load_kernel:
    mov si, loadedSector
    call print_string

    call kernel
    jmp halt

%include "src/kernel/kernel.asm"