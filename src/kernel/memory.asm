;
; in:  bx = source pointer, bp = destination pointer, ax = length in bytes
;

currentPos: dw 0
length: dw 0

memcpy:
    mov word [length], ax
.loop:

    mov byte al, [ds:bx]
    mov byte [ds:bp], al

    mov word ax, [length]
    cmp word [currentPos], ax
    je .end

    inc word bx
    inc word bp
    inc word [currentPos]

    jmp .loop

.end:
    ret

;
; moves 512 byte sections of memory in to extended memory with unreal mode (requires 32 bit cpu)
;
; in: ebp = ptr in low memory, edx = ptr in hi memory
;
unreal_bank_in:
    cli
    push ds                ; save real mode
 
    lgdt [gdtinfo]         ; load gdt register
    
    mov  eax, cr0          ; switch to pmode by
    or al,1                ; set pmode bit
    mov  cr0, eax
    
    jmp $+2                ; tell 386/486 to not crash
    
    mov  bx, 0x08          ; select descriptor 1
    mov  ds, bx            ; 8h = 1000b
    
    and al, 0xFE            ; back to realmode
    mov  cr0, eax          ; by toggling bit again

    mov	ecx, 512
    mov	esi, ebp
    mov	edi, edx
    cld
    rep	movsb

    xor si, si
    
    pop ds                 ; get back old segment
    sti

    ret


;
; moves 512 byte sections of memory out of extended memory with unreal mode (requires 32 bit cpu)
;
; in: edx = ptr in low memory, ebp = ptr in hi memory
;
unreal_bank_out:
    cli
    push ds                ; save real mode
 
    lgdt [gdtinfo]         ; load gdt register
    
    mov  eax, cr0          ; switch to pmode by
    or al,1                ; set pmode bit
    mov  cr0, eax
    
    jmp $+2                ; tell 386/486 to not crash
    
    mov  bx, 0x08          ; select descriptor 1
    mov  ds, bx            ; 8h = 1000b
    
    and al, 0xFE            ; back to realmode
    mov  cr0, eax          ; by toggling bit again

    mov	ecx, 512
    mov	edi, ebp
    mov	esi, edx
    cld
    rep	movsb

    xor si, si
    
    pop ds                 ; get back old segment
    sti

    ret
