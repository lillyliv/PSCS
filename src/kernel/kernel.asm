;
;   peoples secure computing system (PSCS)
;   kernel, 16 bit real mode.
;

bits 16

INTERRUPT_VECTOR_TABLE equ 0000h
testt: db "testt", 0xa, 0xd, 0x0
kernel:

    mov si, loadedString

    call print_string


    ; memcpy tests
    ;
    ; mov ax, 9
    ; mov bx, testt
    ; mov bp, buf
    ; call memcpy
    ; mov si, buf
    ; call print_string

    ;
    ;   interrupts for user programs to use
    ;   kernel has no use for these because the functions can be included directly
    ;


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
    mov bx, mallocHimem
    call setInterrupt

    call clearscreen

    call setupInitalCommands
    
    mov si, termChar
    call print_string
kernel_loop:

    call getChar

    jmp kernel_loop


nosound: ; Silences the speaker.
    in al,0x61
    and al,0xFC;
    out 0x61,al
    ret

sound: ; AX = frequency Starts the speaker emiting a sound of a given frequency
    mov bx,ax ; RETURNS:  AX,BX,DX = undefined
    mov dx,0x12;
    mov ax,0x34DC
    div bx
    mov bl,al
    mov al,0xB6;
    out 0x43,al
    mov al,bl
    out 0x42,al
    mov al,ah
    out 0x42,al
    in al,0x61
    or al,3
    out 0x61,al
    ret


; Prints the value of DX as hex.
; 16 bits only!
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

;ax = time to delay in roughlys 125 ms increments
;https://stackoverflow.com/questions/1858640/how-can-i-create-a-sleep-function-in-16bit-masm-assembly-x86/1862232#1862232
;converted for nasm by me
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
    MOV     AH, BYTE DS:[6CH]       ; get starting tick counter
TICK_DELAY:
    HLT                             ; wait for any interrupt
    MOV     AL, BYTE DS:[6CH]       ; get current tick counter
    CMP     AL, AH                  ; still the same?
    JZ      TICK_DELAY              ; loop if the same
    MOV     AH, AL                  ; otherwise, save new tick value to AH
    LOOP    TICK_DELAY              ; loop until # of ticks (CX) has elapsed
    POP     DS
    POP     CX
    RET

reboot:
    ; https://wiki.osdev.org/Reboot#Far_jump_to_the_reset_vector.2FTriple_fault
    jmp 0xFFFF:0
%include "src/kernel/memory.asm"
%include "src/kernel/ata.asm"
%include "src/kernel/vga.asm"
%include "src/kernel/svga.asm"
%include "src/kernel/terminal.asm"
%include "src/kernel/disk.asm"
%include "src/kernel/fs.asm"
%include "src/bia/text.asm"

times 1474560 - ($ - $$)  db 0 ; pad to the exact ammount of bytes on a "1.44 mb" floppy disk (double 720k)
                               ; https://www.quora.com/If-the-capacity-of-a-floppy-disk-is-1-44-MB-what-is-its-exact-capacity-in-bits/answer/Joe-Zbiciak?ch=10&oid=110788345&share=1ea5be2d&srid=unZYpZ&target_type=answer
