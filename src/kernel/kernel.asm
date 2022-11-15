;
;   peoples secure computing system (PSCS)
;   kernel, 16 bit real mode.
;

bits 16

INTERRUPT_VECTOR_TABLE equ 0000h
testt: db "testt", 0xa, 0xd, 0x0
buf: resb 10
endptr: resb 10
kernel:

    mov si, loadedString

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

    mov al, 7fh
    mov bx, print_hex
    call setInterrupt

    mov al, 80h
    mov bx, unreal_bank_in
    call setInterrupt

    mov al, 81h
    mov bx, unreal_bank_out
    call setInterrupt


    ; unreal banking example copying halting string into and back out of unreal mode and printing it
    ; note this probably overwrites some important things such
    ; as stack because were copying a 28 byte string into a 512 byte area, dont do this!
    
    ; mov ebp, halting
    ; mov edx, 0x01000050

    ; call unreal_bank_in

    ; mov edx, 0x01000050
    ; mov ebp, 0x1000

    ; call unreal_bank_out

    ; mov si, 0x1000

    ; call print_string


kernel_loop:

    call getChar

    jmp kernel_loop

; Prints the value of DX as hex.
print_hex:
  mov cx,4          ; Start the counter: we want to print 4 characters
                    ; 4 bits per char, so we're printing a total of 16 bits

char_loop:
  dec cx            ; Decrement the counter

  mov ax,dx         ; copy bx into ax so we can mask it for the last chars
  shr dx,4          ; shift bx 4 bits to the right
  and ax,0xf        ; mask ah to get the last 4 bits

  mov bx, HEX_OUT   ; set bx to the memory address of our string
  add bx, 2         ; skip the '0x'
  add bx, cx        ; add the current counter to the address

  cmp ax,0xa        ; Check to see if it's a letter or number
  jl set_letter     ; If it's a number, go straight to setting the value
  add byte [bx],7   ; If it's a letter, add 7
                    ; Why this magic number? ASCII letters start 17
                    ; characters after decimal numbers. We need to cover that
                    ; distance. If our value is a 'letter' it's already
                    ; over 10, so we need to add 7 more.
  jl set_letter

set_letter:
  add byte [bx],al  ; Add the value of the byte to the char at bx

  cmp cx,0          ; check the counter, compare with 0
  je print_hex_done ; if the counter is 0, finish
  jmp char_loop     ; otherwise, loop again

print_hex_done:
  mov si, HEX_OUT   ; print the string pointed to by bx
  call print_string

  ret               ; return the function

; global variables
HEX_OUT: db '0x0000',0
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
%include "src/kernel/memory.asm"
%include "src/kernel/vga.asm"
%include "src/kernel/svga.asm"
%include "src/kernel/terminal.asm"
%include "src/kernel/disk.asm"
%include "src/kernel/fs.asm"
%include "src/bia/text.asm"

times 1474560 - ($ - $$)  db 0 ; pad to the exact ammount of bytes on a "1.44 mb" floppy disk (double 720k)
                               ; https://www.quora.com/If-the-capacity-of-a-floppy-disk-is-1-44-MB-what-is-its-exact-capacity-in-bits/answer/Joe-Zbiciak?ch=10&oid=110788345&share=1ea5be2d&srid=unZYpZ&target_type=answer
