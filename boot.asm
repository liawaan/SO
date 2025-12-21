; Simple OS Bootloader
; File: boot.asm
; Compile: nasm -f bin boot.asm -o boot.bin

[BITS 16]
[ORG 0x7C00]

start:
    ; Setup segments
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    
    ; Clear screen
    call clear_screen
    
    ; Display welcome message
    mov si, msg_welcome
    call print_string
    
    ; Load kernel from disk (sector 2)
    mov si, msg_loading
    call print_string
    
    mov ah, 0x02        ; Read sectors
    mov al, 10          ; Number of sectors to read
    mov ch, 0           ; Cylinder 0
    mov cl, 2           ; Start from sector 2
    mov dh, 0           ; Head 0
    mov bx, 0x1000      ; Load to 0x1000
    int 0x13
    
    jc disk_error
    
    mov si, msg_ok
    call print_string
    
    ; Jump to kernel
    jmp 0x1000

disk_error:
    mov si, msg_error
    call print_string
    jmp $

clear_screen:
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    ret

print_string:
    mov ah, 0x0E
.loop:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .loop
.done:
    ret

msg_welcome db 'SimpleOS v1.0', 0x0D, 0x0A, 0x0D, 0x0A, 0
msg_loading db 'Loading kernel...', 0
msg_ok db ' OK', 0x0D, 0x0A, 0
msg_error db ' ERROR!', 0x0D, 0x0A, 0

times 510-($-$$) db 0
dw 0xAA55