;
;   peoples secure computing system (PSCS)
;   kernel, 16 bit real mode.
;

bits 16

INTERRUPT_VECTOR_TABLE 		equ 0000h
testt: db "testt", 0xa, 0xd, 0x0

kernel:
    mov si, loadedString
    call print_string

    mov al, 69h
    mov bx, testint
    call setInterrupt

    int 69h

    mov dx, 0
    push dx

    call disktest

kernel_loop:

    call getChar

    jmp kernel_loop


;
;   creates a new interrupt available for user programs and kernel use
;   in: al = int number, bx = pointer to handler
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


testint:

    mov si, testt
    call print_string

    ret

;
;   in: two string pointers in bx and bp
;   out: 1 or 0 in ah
;   this took a stupid ammount of time to get working & optimize
;
compareString:

    mov ch, [bp]      ; | nasm cant compare two locations in memory
    cmp byte [bx], ch ; | to get around this we just move one into a register
    jne .false

    cmp byte [bp], 0 ; | only need to check if one of the strings has ended because
    je .end          ; | two lines above if both arent equal it will exit false

    inc bp ; | moves the pointers forward one char
    inc bx ; |

    jmp compareString

    ret

.false:
    xor ah, ah
    ret
.end:
    mov ah, 1
    ret

%include "src/kernel/vga.asm"
%include "src/kernel/svga.asm"
%include "src/kernel/terminal.asm"
%include "src/kernel/disk.asm"
%include "src/bia/text.asm"

times 1000000 - ($ - $$)  db 0 ; 1 000 000 bytes for user disk reads and writes