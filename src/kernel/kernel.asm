;
;   peoples secure computing system (PSCS)
;   kernel, 16 bit real mode.
;

bits 16

;ax = time to delay in 125 ms increments
;https://stackoverflow.com/questions/1858640/how-can-i-create-a-sleep-function-in-16bit-masm-assembly-x86/1862232#1862232
;converted for nasm
DELAY_TIMER:
    STI                             ; ensure interrupts are on
    PUSH    CX                      ; call-preserve CX and DS (if needed)
    PUSH    DS
    MOV     CX, 40H                 ; set DS to BIOS Data Area
    MOV     DS, CX
    MOV     CX, 583                 ; delay_factor = 1/8 * 18.2 * 256
    MUL     CX                      ; AH (ticks) = delay_time * delay_factor
    XOR     CX, CX                  ; CX = 0
    MOV     CL, AH                  ; CX = # of ticks to wait
    MOV     AH, BYTE DS:[6CH]   ; get starting tick counter
TICK_DELAY:
    HLT                             ; wait for any interrupt
    MOV     AL, BYTE DS:[6CH]   ; get current tick counter
    CMP     AL, AH                  ; still the same?
    JZ      TICK_DELAY              ; loop if the same
    MOV     AH, AL                  ; otherwise, save new tick value to AH
    LOOP    TICK_DELAY              ; loop until # of ticks (CX) has elapsed
    POP     DS
    POP     CX
    RET
INTERRUPT_VECTOR_TABLE equ 0000h
testt: db "testt", 0xa, 0xd, 0x0

kernel:
    mov si, loadedString
    call print_string

    mov al, 69h
    mov bx, testint
    call setInterrupt

    mov al, 70h
    mov bx, returnInt
    call setInterrupt

    mov al, 71h
    mov bx, clearscreen
    call setInterrupt

    mov al, 72h
    mov bx, DELAY_TIMER
    call setInterrupt


    int 69h


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
    ; pusha

    mov si, testt
    call print_string
    ; popa

    ret

returnInt:
    call donecmd
    jmp kernel_loop


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