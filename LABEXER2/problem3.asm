section .data
    p_eax db "EAX: "
    l_eax equ $ - p_eax
    p_ebx db "EBX: "
    l_ebx equ $ - p_ebx
    p_ecx db "ECX: "
    l_ecx equ $ - p_ecx
    p_edx db "EDX: "
    l_edx equ $ - p_edx
    msg   db "Done. ESP offset = 0 bytes.", 10
    l_msg equ $ - msg

section .bss
    buf resb 8

section .text
    global _start

_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, p_eax
    mov edx, l_eax
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, buf
    mov edx, 7
    int 0x80
    movzx eax, byte [buf]
    sub eax, '0'
    push eax

    mov eax, 4
    mov ebx, 1
    mov ecx, p_ebx
    mov edx, l_ebx
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, buf
    mov edx, 7
    int 0x80
    movzx ebx, byte [buf]
    sub ebx, '0'
    push ebx

    mov eax, 4
    mov ebx, 1
    mov ecx, p_ecx
    mov edx, l_ecx
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, buf
    mov edx, 7
    int 0x80
    movzx ecx, byte [buf]
    sub ecx, '0'
    push ecx

    mov eax, 4
    mov ebx, 1
    mov ecx, p_edx
    mov edx, l_edx
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, buf
    mov edx, 7
    int 0x80
    movzx edx, byte [buf]
    sub edx, '0'

    pop ecx
    pop ebx
    pop eax

    call calculate_foo

    mov eax, 4
    mov ebx, 1
    mov ecx, msg
    mov edx, l_msg
    int 0x80

    mov eax, 1
    xor ebx, ebx
    int 0x80

calculate_foo:
    push eax
    push ebx
    push ecx
    push edx

    add eax, ebx
    imul ecx, edx
    xor ebx, edx

    pop edx
    pop ecx
    pop ebx
    pop eax
    ret