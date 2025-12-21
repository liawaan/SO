; Simple OS Kernel
; File: kernel.asm
; Compile: nasm -f bin kernel.asm -o kernel.bin

[BITS 16]
[ORG 0x1000]

kernel_start:
    ; Setup segments
    xor ax, ax
    mov ds, ax
    mov es, ax
    
    ; Clear screen and show kernel loaded
    call clear_screen
    mov si, msg_kernel
    call print_string
    
    ; Show menu
    call show_menu

main_loop:
    ; Wait for key
    mov ah, 0x00
    int 0x16
    
    ; Check which key pressed
    cmp al, '1'
    je cmd_system_info
    
    cmp al, '2'
    je cmd_memory_info
    
    cmp al, '3'
    je cmd_calculator
    
    cmp al, '4'
    je cmd_text_editor
    
    cmp al, '5'
    je cmd_shutdown
    
    jmp main_loop

cmd_system_info:
    call clear_screen
    mov si, msg_sysinfo
    call print_string
    
    ; Get CPU info
    mov si, msg_cpu
    call print_string
    
    ; Simple CPU detection
    mov ax, 0
    cpuid
    mov si, msg_cpu_vendor
    call print_string
    
    mov si, msg_press_key
    call print_string
    mov ah, 0x00
    int 0x16
    call clear_screen
    call show_menu
    jmp main_loop

cmd_memory_info:
    call clear_screen
    mov si, msg_meminfo
    call print_string
    
    ; Get memory size (simplified)
    int 0x12
    call print_number
    mov si, msg_kb
    call print_string
    
    mov si, msg_press_key
    call print_string
    mov ah, 0x00
    int 0x16
    call clear_screen
    call show_menu
    jmp main_loop

cmd_calculator:
    call clear_screen
    mov si, msg_calc
    call print_string
    
    ; Get first number
    mov si, msg_num1
    call print_string
    call input_number
    mov [num1], ax
    
    ; Get operator
    mov si, msg_operator
    call print_string
    mov ah, 0x00
    int 0x16
    mov [operator], al
    mov ah, 0x0E
    int 0x10
    
    ; New line
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10
    
    ; Get second number
    mov si, msg_num2
    call print_string
    call input_number
    mov [num2], ax
    
    ; Calculate
    mov si, msg_result
    call print_string
    
    mov ax, [num1]
    mov bx, [num2]
    mov cl, [operator]
    
    cmp cl, '+'
    je .add
    cmp cl, '-'
    je .sub
    cmp cl, '*'
    je .mul
    cmp cl, '/'
    je .div
    jmp .end
    
.add:
    add ax, bx
    jmp .show
.sub:
    sub ax, bx
    jmp .show
.mul:
    mul bx
    jmp .show
.div:
    xor dx, dx
    div bx
    jmp .show
    
.show:
    call print_number
    
.end:
    mov si, msg_press_key
    call print_string
    mov ah, 0x00
    int 0x16
    call clear_screen
    call show_menu
    jmp main_loop

cmd_text_editor:
    call clear_screen
    mov si, msg_editor
    call print_string
    
    mov di, text_buffer
    
.loop:
    mov ah, 0x00
    int 0x16
    
    cmp al, 0x1B    ; ESC key
    je .done
    
    cmp al, 0x08    ; Backspace
    je .backspace
    
    ; Echo character
    mov ah, 0x0E
    int 0x10
    
    ; Store in buffer
    stosb
    jmp .loop
    
.backspace:
    cmp di, text_buffer
    je .loop
    dec di
    mov byte [di], 0
    
    ; Move cursor back
    mov ah, 0x0E
    mov al, 0x08
    int 0x10
    mov al, ' '
    int 0x10
    mov al, 0x08
    int 0x10
    jmp .loop
    
.done:
    call clear_screen
    call show_menu
    jmp main_loop

cmd_shutdown:
    call clear_screen
    mov si, msg_shutdown
    call print_string
    
    ; APM shutdown
    mov ax, 0x5301
    xor bx, bx
    int 0x15
    
    mov ax, 0x5307
    mov bx, 0x0001
    mov cx, 0x0003
    int 0x15
    
    ; If APM fails, just halt
    cli
    hlt

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

print_number:
    push ax
    push bx
    push cx
    push dx
    
    mov cx, 0
    mov bx, 10
    
.divide:
    xor dx, dx
    div bx
    push dx
    inc cx
    test ax, ax
    jnz .divide
    
.print:
    pop ax
    add al, '0'
    mov ah, 0x0E
    int 0x10
    loop .print
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret

input_number:
    push bx
    push cx
    
    xor bx, bx      ; Result
    mov cx, 10      ; Base
    
.loop:
    mov ah, 0x00
    int 0x16
    
    cmp al, 0x0D    ; Enter
    je .done
    
    cmp al, '0'
    jb .loop
    cmp al, '9'
    ja .loop
    
    ; Echo
    mov ah, 0x0E
    int 0x10
    
    ; Calculate
    sub al, '0'
    mov ah, 0
    push ax
    mov ax, bx
    mul cx
    mov bx, ax
    pop ax
    add bx, ax
    jmp .loop
    
.done:
    mov ax, bx
    
    ; New line
    push ax
    mov ah, 0x0E
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10
    pop ax
    
    pop cx
    pop bx
    ret

show_menu:
    mov si, msg_menu
    call print_string
    ret

msg_kernel db 'Kernel loaded successfully!', 0x0D, 0x0A, 0x0D, 0x0A, 0
msg_menu db '===== SimpleOS Menu =====', 0x0D, 0x0A
         db '1. System Information', 0x0D, 0x0A
         db '2. Memory Information', 0x0D, 0x0A
         db '3. Calculator', 0x0D, 0x0A
         db '4. Text Editor', 0x0D, 0x0A
         db '5. Shutdown', 0x0D, 0x0A
         db 0x0D, 0x0A
         db 'Choose: ', 0

msg_sysinfo db '===== System Information =====', 0x0D, 0x0A, 0
msg_cpu db 'CPU: x86 Compatible', 0x0D, 0x0A, 0
msg_cpu_vendor db 'Mode: Real Mode 16-bit', 0x0D, 0x0A, 0x0D, 0x0A, 0

msg_meminfo db '===== Memory Information =====', 0x0D, 0x0A
            db 'Base Memory: ', 0
msg_kb db ' KB', 0x0D, 0x0A, 0x0D, 0x0A, 0

msg_calc db '===== Calculator =====', 0x0D, 0x0A, 0
msg_num1 db 'First number: ', 0
msg_num2 db 'Second number: ', 0
msg_operator db 'Operator (+,-,*,/): ', 0
msg_result db 'Result: ', 0

msg_editor db '===== Text Editor =====', 0x0D, 0x0A
           db 'Type text (ESC to exit)', 0x0D, 0x0A, 0x0D, 0x0A, 0

msg_shutdown db 'Shutting down...', 0x0D, 0x0A
             db 'You can now close VirtualBox', 0x0D, 0x0A, 0

msg_press_key db 0x0D, 0x0A, 'Press any key...', 0

num1 dw 0
num2 dw 0
operator db 0
text_buffer times 1024 db 0

times 5120-($-$$) db 0  ; Pad to 10 sectors