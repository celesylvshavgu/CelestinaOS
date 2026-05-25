[org 0x7c00]
[bits 16]

_start:
    mov [BOOT_DRIVE], dl

    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00

init_hardware_a20:
    call Check_a20
    cmp ax, 1
    je a20_done

    in al, 0x92
    or al, 2
    out 0x92, al

    call Check_a20
    cmp ax, 1
    je a20_done

    mov ax, 0x2401
    int 0x15

a20_done:
    mov dx, 0x03C8
    mov al, 61
    out dx, al

    mov dx, 0x03C9
    mov al, 63
    out dx, al
    mov al, 42
    out dx, al
    mov al, 55
    out dx, al

    mov ax, 0x1301
    mov bx, 0x000D
    mov cx, msg_len
    mov dx, 0x0000
    mov bp, msg
    int 0x10

    mov bx, 0x9000
    mov ah, 0x02
    mov al, 4
    mov ch, 0x00
    mov dh, 0x00
    mov cl, 0x02
    mov dl, [BOOT_DRIVE]
    int 0x13
    jc disk_error

    cli
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 1
    mov cr0, eax
    jmp 0x08:0x9000

disk_error:
    mov ax, 0x0600
    mov bh, 0x47
    xor cx, cx
    mov dx, 0x184f
    int 0x10
.err_loop:
    hlt
    jmp .err_loop

Check_a20:
    pushf
    push ds
    push es
    push di
    push si

    xor ax, ax
    mov ds, ax
    not ax
    mov es, ax
    mov di, 0x0500
    mov si, 0x0510

    mov al, byte [es:di]
    push ax
    mov al, byte [ds:si]
    push ax

    mov byte [es:di], 0x00
    mov byte [ds:si], 0xff
    cmp byte [es:di], 0xff
    je .a20_disabled

    mov ax, 1
    jmp .a20_restore

.a20_disabled:
    mov ax, 0

.a20_restore:
    pop bx
    mov byte [ds:si], bl
    pop bx
    mov byte [es:di], bl

    pop si
    pop di
    pop es
    pop ds
    popf
    ret

align 4
gdt_start:
    dd 0x0, 0x0
gdt_code:
    dw 0xFFFF, 0x0000
    db 0x00, 10011010b, 11001111b, 0x00
gdt_data:
    dw 0xFFFF, 0x0000
    db 0x00, 10010010b, 11001111b, 0x00
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

BOOT_DRIVE: db 0
msg: db "The OS is booting up...", 0x0D, 0x0A
msg_len equ $ - msg

times 510-($-$$) db 0
dw 0xaa55
