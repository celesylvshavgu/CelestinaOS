[org 0x9000]
[bits 32]

_start:
    mov ax, 0x10
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x70000
    mov esp, ebp

    mov edi, 0xB8000
    mov ecx, 2000
    mov ax, 0x0720

.clear_loop:
    mov [edi], ax
    add edi, 2
    loop .clear_loop

    mov esi, kmsg
    mov edi, 0xB8000
    mov ah, 0x0D

.print_loop:
    lodsb
    cmp al, 0
    je .lockout
    mov [edi], al
    mov [edi+1], ah
    add edi, 2
    jmp .print_loop

.lockout:
    cli
.hang:
    hlt
    jmp .hang

kmsg: db "CelestinaOS v1.0 is running in 32-bit Protected Mode! Holy shit, it didn't trip and fall this time!! haha.", 0
