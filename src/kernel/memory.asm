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
; mallocate in high mem
; in: ebx = ammount of 512 byte chunks to allocate (not working yet, only allocates one chunk at a time)
; out: esi = pointer to start of allocated memory
;
mallocHimem:
    xor edi, edi
    xor esi, esi
.loop:
    cmp word edi, 1024
    je .fail

    cmp byte memoryTableHi[edi], 0
    je .end

    inc edi

    jmp .loop

.end:
    mov eax, 512
    mul edi

    mov ecx, 0x00100000 ; memory allocation starts at the very start of hi mem which is 14 mib before the ISA hole
    mul ecx

    add eax, ecx

    mov esi, eax
    mov byte memoryTableHi[edi], 1
    ret

.fail:
    ret

memoryTableHi: resb 1024 ; big enough table for 512k of dynamically allocated mem