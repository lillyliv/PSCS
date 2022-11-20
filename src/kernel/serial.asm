; https://wiki.osdev.org/Serial_Ports

; #define PORT 0x3f8          // COM1
 
; static int init_serial() {
;    outb(PORT + 1, 0x00);    // Disable all interrupts
;    outb(PORT + 3, 0x80);    // Enable DLAB (set baud rate divisor)
;    outb(PORT + 0, 0x03);    // Set divisor to 3 (lo byte) 38400 baud
;    outb(PORT + 1, 0x00);    //                  (hi byte)
;    outb(PORT + 3, 0x03);    // 8 bits, no parity, one stop bit
;    outb(PORT + 2, 0xC7);    // Enable FIFO, clear them, with 14-byte threshold
;    outb(PORT + 4, 0x0B);    // IRQs enabled, RTS/DSR set
;    outb(PORT + 4, 0x1E);    // Set in loopback mode, test the serial chip
;    outb(PORT + 0, 0xAE);    // Test serial chip (send byte 0xAE and check if serial returns same byte)
 
;    // Check if serial is faulty (i.e: not same byte as sent)
;    if(inb(PORT + 0) != 0xAE) {
;       return 1;
;    }
 
;    // If serial is not faulty set it in normal operation mode
;    // (not-loopback with IRQs enabled and OUT#1 and OUT#2 bits enabled)
;    outb(PORT + 4, 0x0F);
;    return 0;
; }

failed: db "failed", 0
;converted to nasm by me
init_serial:
    mov al, 0x00
    mov dx, 0x3f9
    out byte dx, al ; Disable all interrupts
    mov al, 0x80
    mov dx, 0x3fb
    out byte dx, al ; Enable DLAB (set baud rate divisor)
    mov al, 0x03
    mov dx, 0x3f8
    out byte dx, al ; Set divisor to 3 (lo byte) 38400 baud
    mov al, 0x00
    mov dx, 0x3f9
    out byte dx, al ;                  (hi byte)
    mov al, 0x03
    mov dx, 0x3fb
    out byte dx, al ; 8 bits, no parity, one stop bit
    mov al, 0xc7
    mov dx, 0x3fa
    out byte dx, al ; Enable FIFO, clear them, with 14-byte threshold
    mov al, 0x0b
    mov dx, 0x3fd
    out byte dx, al ; IRQs enabled, RTS/DSR set
    ; mov al, 0x1e
    ; mov dx, 0x3fd
    ; out byte dx, al ; Set in loopback mode, test the serial chip

    ; mov al, 0xae
    ; mov dx, 0x3fd
    ; out byte dx, al
    ; xor ax, ax
    ; in al, dx
    ; mov dx, ax
    ; call print_hex
    ; cmp al, 0xae
    ; jne .fail

    ; mov al, 0x0f
    ; mov dx, 0x3fd
    ; out byte dx, al ; (not-loopback with IRQs enabled and OUT#1 and OUT#2 bits enabled)

    ; mov al, "a"
    ; mov dx, 0x3f8
    ; out byte dx, al
    ret
.fail
    mov si, failed
    call print_string
    ret

; log ascii in al to serial console
serialLogByte:
    pusha
    mov dx, 0x3f8
    out byte dx, al
    popa
    ret