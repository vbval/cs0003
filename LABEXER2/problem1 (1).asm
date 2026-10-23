section .data
    prompt    db "Enter word: "
    prompt_len equ $ - prompt
    newline   db 10

section .bss
    buf       resb 64
    len       resd 1

section .text
    global _start

_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, buf
    mov edx, 63
    int 0x80

    dec eax
    jle _exit
    mov [len], eax

    xor ecx, ecx
.push_loop:
    movzx ebx, byte [buf + ecx]
    push ebx
    inc ecx
    cmp ecx, [len]
    jl .push_loop

    xor ecx, ecx
.pop_loop:
    pop ebx
    mov [buf + ecx], bl
    inc ecx
    cmp ecx, [len]
    jl .pop_loop

    mov eax, 4
    mov ebx, 1
    mov ecx, buf
    mov edx, [len]
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

_exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80