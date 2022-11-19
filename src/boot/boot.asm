;
;   peoples secure computing system (PSCS)
;   bootloader, inspired by SnowDrop os
;   http://sebastianmihai.com/snowdrop/
org 7C00h

jmp load_kernel
loadedString:	db "Peoples Secure Computing System loaded!", 0xa, 0xd, 0x0
initialLoading:	db "Peoples Secure Computing System loading...", 0xa, 0xd, 0x0
loadedSector: db "20 extra floppy sectors loaded, this should be enough.", 0xa, 0xd, 0x0
halting: db "halting (not a good sign)", 0xa, 0xd, 0x0
unrealEnabled: db "Unreal mode enabled, you now have access to your entire 4gb of ram!", 0xa, 0xd, 0x0
unreal_mode_enabled: db 1
enable_A20:
        cli
 
        call    a20wait
        mov     al,0xAD
        out     0x64,al
 
        call    a20wait
        mov     al,0xD0
        out     0x64,al
 
        call    a20wait2
        in      al,0x60
        push    eax
 
        call    a20wait
        mov     al,0xD1
        out     0x64,al
 
        call    a20wait
        pop     eax
        or      al,2
        out     0x60,al
 
        call    a20wait
        mov     al,0xAE
        out     0x64,al
 
        call    a20wait
        sti
        ret
 
a20wait:
        in      al,0x64
        test    al,2
        jnz     a20wait
        ret
 
 
a20wait2:
        in      al,0x64
        test    al,1
        jz      a20wait2
        ret

load_kernel:
    ; push cs
    ; pop ds

    xor ax, ax
    cli

    mov ds, ax             ; DS=0
    mov ss, ax             ; stack starts at seg 0
    mov sp, 0x4000         ; stack at 0x4000

    sti

    mov  ax, 3    ; BIOS video mode 80x25 16-color text
    int  10h

    cmp byte [unreal_mode_enabled], 1
    jne .nounreal


    call enable_A20

   cli                    ; no interrupts
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
    
    pop ds                 ; get back old segment

    sti
    mov bx, 0
    mov si, unrealEnabled
    call print_string

.nounreal:
    mov bx, 0
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
   mov al, 20    ; we want to read 10 sectors
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
;dh for row, dl for column
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
gdtinfo:
   dw gdt_end - gdt - 1   ;last byte in table
   dd gdt                 ;start of table
 
gdt         dd 0,0        ; entry 0 is always unused
flatdesc    db 0xff, 0xff, 0, 0, 0, 10010010b, 11001111b, 0
gdt_end:
 
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

;dh=row
;dl=col
movecursor:

    mov bh, 0
    mov ah, 02h
    int 10h

    ret

clearscreen:
    mov ax, 3
    int 10h
    ret
returnInt:
    call donecmd
    jmp kernel_loop

times 512 - 2 - ($ - $$)  db 0		; pad to 512 bytes minus one word for boot magic
dw 0AA55h		; BIOS expects this signature at the end of the boot sector

finalize_load_kernel:
    mov si, loadedSector
    call print_string

    call kernel
    jmp halt

%include "src/kernel/kernel.asm"