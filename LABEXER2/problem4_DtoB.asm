;ld -m elf_i386 problem4_DtoB.o -o problem4_DtoB ./problem4_DtoB
; ./problem4_DtoB
;nasm -f elf32 problem4_DtoB.asm -o problem4_DtoB.o && ld -m elf_i386 problem4_DtoB.o -o problem4_DtoB && ./problem4_DtoB

section .data
    num dw 42                   ;change into any number for output
    msg db "Binary: "
    msgLen equ $ - msg
    newline db 10

section .bss
    binary resb 16

section .text
    global _start

_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg
    mov edx, msgLen
    int 0x80

    movzx eax, word [num]
    mov ebx, 2
    xor ecx, ecx

convert:
    xor edx, edx
    div ebx
    push edx
    inc ecx

    cmp eax, 0
    jne convert

    mov esi, binary
    mov edi, ecx

display:
    pop eax
    add al, '0'
    mov [esi], al
    inc esi
    loop display

    mov eax, 4
    mov ebx, 1
    mov ecx, binary
    mov edx, edi
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    mov eax, 1
    xor ebx, ebx
    int 0x80
