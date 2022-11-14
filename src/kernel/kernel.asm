;
;   peoples secure computing system (PSCS)
;   kernel, 16 bit real mode.
;

bits 16

INTERRUPT_VECTOR_TABLE equ 0000h
testt: db "testt", 0xa, 0xd, 0x0
buf: resb 10

num: dw 69
endptr: resb 10
kernel:

    cli
    push ds                ; save real mode
 
   lgdt [gdtinfo]         ; load gdt register
 
   mov  eax, cr0          ; switch to pmode by
   or al,1                ; set pmode bit
   mov  cr0, eax
 
   jmp $+2                ; tell 386/486 to not crash
 
   mov  bx, 0x08          ; select descriptor 1
   mov  ds, bx            ; 8h = 1000b
 
   and al,0xFE            ; back to realmode
   mov  cr0, eax          ; by toggling bit again

   mov eax, 0x00100008      ; note 32 bit offset
   mov word [ds:eax], loadedString

   mov word si, ds:eax
 
   pop ds                 ; get back old segment
   sti

   call print_string



    mov ax, 9
    mov bx, testt
    mov bp, buf
    call memcpy
    mov si, buf
    call print_string

    mov al, 70h
    mov bx, returnInt
    call setInterrupt

    mov al, 71h
    mov bx, clearscreen
    call setInterrupt

    mov al, 72h
    mov bx, DELAY_TIMER
    call setInterrupt

    mov al, 73h
    mov bx, print_string
    call setInterrupt

    mov al, 74h
    mov bx, writeSector
    call setInterrupt

    mov al, 75h
    mov bx, readSector
    call setInterrupt

    mov al, 76h
    mov bx, readFile
    call setInterrupt

    mov al, 77h
    mov bx, writeFile
    call setInterrupt

    mov al, 78h
    mov bx, getAlStore
    call setInterrupt

    mov al, 79h
    mov bx, getSectorPointer
    call setInterrupt

    mov al, 7ah
    mov bx, memcpy
    call setInterrupt

    mov al, 7bh
    mov bx, movecursor
    call setInterrupt

    mov al, 7ch
    mov bx, getFilesize
    call setInterrupt

    mov al, 7dh
    mov bx, startVGA
    call setInterrupt

    mov al, 7eh
    mov bx, putPixel
    call setInterrupt

    mov ax, num
    mov dx, endptr
    call sixteen_bit_int_to_ascii

    mov si, dx
    call print_string


kernel_loop:

    call getChar

    jmp kernel_loop
;
; in:  bx = source pointer, bp = destination pointer, ax = length in bytes
;

currentPos: dw 0
length: dw 0

memcpy:
    mov word [length], ax
.loop:

    mov byte al, [bx]
    mov byte [bp], al

    mov word ax, [length]
    cmp word [currentPos], ax
    je .end

    inc word bx
    inc word bp
    inc word [currentPos]

    jmp .loop

.end:
    ret

; ============================================================================================
; Converts unsigned integer to NULL terminated ASCII string

;	ENTRY:	AX = 16 bit value to be converted
;		DX = Pointer to destination buffer (must be at least 5 bytes in length)

;	LEAVE:	AX = Pointer to first character of conversion
;		DX = Unchanged and points to ASCII string padded with blanks.
; --------------------------------------------------------------------------------------------

sixteen_bit_int_to_ascii:
	I2A_16	push	di			; Preserve base pointer
		push	dx
		mov	dx, ax
	
	; This creates a buffer with leading spaces.  Could be changed to '00' if leading
	; zero's are prefered.
	
		mov	ax, '  '		; Pad buffer with spaces
		stosw
		stosw
		mov	byte [di], 0		; Teminate with NULL
		dec	di			; Bump back to last byte of string
		
	; It might be a better idea to check flag before changing, but in this case I'm
	; going to assume all routines change to auto increment before completing.
	
		std				; Auto decrement
	
	; Cycle until DX is null, but should it be zero at least one '0' will be written.
		
	 .Next	mov	 al, dl			; Get next byte 
	 	and	 al, 15			; Strip high nibble
	 	or	 al, '0'		; Make ASCII
	 	cmp	 al, 58			; and determine if greater than '9'
	 	jb	$ + 4			; Branch if between '0' & '9'
	 	
	 	add	 al, 7			; Makes character 'A' - 'F'
	 	
	 	stosb				; Write ASCII character to buffer
		shr	dx, 4			; Shift next nibble into AL
		jnz	.Next			; and continue if not zero
		
		cld				; Set default direction	
	 	pop	dx			; Restore original contents
		mov	ax, di			; Copy pointer
		inc	ax			; and bump so there are no leading spaces
		pop	di			; Pointer with leading spaces
		ret
; ax=interrupt number
; bx=pointer to function
;
setInterrupt:

    mov di, bx

    xor ah, ah				; AX := interrupt number
	shl ax, 2				; each interrupt vector is 4 bytes long
	mov si, ax				; SI := byte offset of user-specified entry
	
	mov ax, INTERRUPT_VECTOR_TABLE
	mov ds, ax				; DS := IVT segment
	; DS:SI now points to 2-word interrupt vector
	
	mov word bx, [ds:si]	; BX := old handler offset
	mov word dx, [ds:si+2]	; DX := old handler segment
	; DX:BX now points to the old interrupt handler
	
	; now install new interrupt handler
	; pushf
	cli						; ensure we don't get interrupted in-between
							; the two instructions below
	mov word [ds:si], di	; offset of new interrupt handler
	mov word [ds:si+2], es	; segment of new interrupt handler

    ret

%include "src/kernel/vga.asm"
%include "src/kernel/svga.asm"
%include "src/kernel/terminal.asm"
%include "src/kernel/disk.asm"
%include "src/kernel/fs.asm"
%include "src/bia/text.asm"

times 1474560 - ($ - $$)  db 0 ; pad to the exact ammount of bytes on a "1.44 mb" floppy disk (double 720k)
                               ; https://www.quora.com/If-the-capacity-of-a-floppy-disk-is-1-44-MB-what-is-its-exact-capacity-in-bits/answer/Joe-Zbiciak?ch=10&oid=110788345&share=1ea5be2d&srid=unZYpZ&target_type=answer
