;
;   regmemswap swaps the value in a register and a memory location
;   bp = ptr, al = val
;
regmemswap:
    xchg byte al, [bp]
    ret
regmemswapWord:
    xchg word ax, [bp]
    ret

;
; in:  si = source pointer, di = destination pointer, cx = length in bytes
;
memcpy:
    rep movsb

    ret

;
; allocate memory in high mem (above 1 MiB)
; in: ebx = ammount of 512 byte chunks to allocate (not working yet, only allocates one chunk at a time)
; out: esi = pointer to start of allocated memory
;
; if there is not enough free memory esi will be 0
;
; mallocLowmem probably will not be coming anytime soon because low memory is basically the wild west currently
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
                        ; https://wiki.osdev.org/Memory_Map_(x86)
    mul ecx

    add eax, ecx

    mov esi, eax
    mov byte memoryTableHi[edi], 1
.fail:
    ret

; ebx = pointer to deallocate
deallocHimem:

.fail:
    ret
memoryTableHi: resb 1024 ; big enough table for 512k of dynamically allocated mem