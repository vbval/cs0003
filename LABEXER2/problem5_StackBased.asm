;nasm -f elf32 problem5_StackBased.asm -o /tmp/problem5_StackBased.o
;ld -m elf_i386 -o /tmp/problem5_StackBased /tmp/problem5_StackBased.o
;/tmp/problem5_StackBased


section .data
    array dd 3, 1, 4, 1, 5          ;change array here
    msg1 db "Reversed Array: "
    len1 equ $ - msg1
    msg2 db "Sum: "
    len2 equ $ - msg2
    space db " "
    newline db 10

section .bss
    reversed resd 5
    sum resd 1
    buffer resb 12

section .text
    global _start

_start:
    mov esi, array
    mov ecx, 5

push_loop:
    push dword [esi]
    add esi, 4
    loop push_loop

    mov edi, reversed
    mov ecx, 5
    xor eax, eax

pop_loop:
    pop ebx
    mov [edi], ebx
    add eax, ebx
    add edi, 4
    loop pop_loop

    mov [sum], eax

    mov eax, 4
    mov ebx, 1
    mov ecx, msg1
    mov edx, len1
    int 0x80

    mov esi, reversed
    mov ecx, 5

print_array:
    push ecx
    push esi

    mov eax, [esi]
    call print_number

    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80

    pop esi
    pop ecx
    add esi, 4
    loop print_array

    call print_newline

    mov eax, 4
    mov ebx, 1
    mov ecx, msg2
    mov edx, len2
    int 0x80

    mov eax, [sum]
    call print_number
    call print_newline

    mov eax, 1
    xor ebx, ebx
    int 0x80

print_number:
    mov edi, buffer + 12
    mov ebx, 10
    xor ecx, ecx

convert_number:
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl
    inc ecx
    test eax, eax
    jnz convert_number

    mov edx, ecx
    mov ecx, edi
    mov eax, 4
    mov ebx, 1
    int 0x80
    ret

print_newline:
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret
