;
;   peoples secure computing system (PSCS)
;   bootloader, inspired by SnowDrop os
;   http://sebastianmihai.com/snowdrop/
;
;   I put a bunch of functions in here because
;   this will not be overwritten and is fixed size

bits 16
org 7C00h

jmp load_kernel
times $$ + 3 - $ nop

loadedString:	db "Peoples Secure Computing System loaded!", 0xa, 0xd, 0x0
initialLoading:	db "Peoples Secure Computing System loading...", 0xa, 0xd, 0x0
loadedSector: db "10 extra floppy sectors loaded, this should be enough.", 0xa, 0xd, 0x0
halting: db "halting (not a good sign)", 0xa, 0xd, 0x0
clean: db "                                                                                ", 0xa, 0xd, 0x0 
; 80 column spaces to clear screen, theres definitally a better way to do this but this works fine

load_kernel:
    ; push cs
    ; pop ds

    xor ax, ax
    cli

    mov ss, ax
    mov sp, 0x4000

    sti

    mov  ax, 3    ; BIOS video mode 80x25 16-color text
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

returnInt:
    call donecmd
    jmp kernel_loop

;
;   creates a new interrupt available for user programs and kernel use
;   in: al = int number, bx = pointer to handler
;
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

times 512 - 2 - ($ - $$)  db 0		; pad to 512 bytes minus one word for boot magic
 
dw 0AA55h		; BIOS expects this signature at the end of the boot sector

finalize_load_kernel:
    mov si, loadedSector
    call print_string

    call kernel
    jmp halt

%include "src/kernel/kernel.asm"