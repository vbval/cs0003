
section .data
    prompt db "Enter your expression: "
    prompt_len equ $ - prompt

    balanced_msg db "Result: 1 (Balanced)", 10
    balanced_len equ $ - balanced_msg

    unbalanced_msg db "Result: 0 (Unbalanced)", 10
    unbalanced_len equ $ - unbalanced_msg

section .bss
    expression resb 256

section .text
    global _start

_start:

input_again:
    ; Display prompt
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, prompt_len
    int 0x80

    
    mov eax, 3
    mov ebx, 0
    mov ecx, expression
    mov edx, 255
    int 0x80

    cmp eax, 0
    jle exit_program

    
    mov esi, expression
    mov ecx, eax

find_newline:
    cmp ecx, 0
    je terminate_input

    cmp byte [esi], 10
    je terminate_input

    inc esi
    dec ecx
    jmp find_newline

terminate_input:
    mov byte [esi], 0

    ; Check parentheses
    mov esi, expression
    call check_balance

    ; Display result
    cmp eax, 1
    je print_balanced

    mov eax, 4
    mov ebx, 1
    mov ecx, unbalanced_msg
    mov edx, unbalanced_len
    int 0x80
    jmp input_again

print_balanced:
    mov eax, 4
    mov ebx, 1
    mov ecx, balanced_msg
    mov edx, balanced_len
    int 0x80
    jmp input_again


check_balance:
    xor ebx, ebx

scan:
    mov al, [esi]

    cmp al, 0
    je end_scan

    cmp al, '('
    je opening

    cmp al, ')'
    je closing

next_char:
    inc esi
    jmp scan

opening:
    push eax
    inc ebx
    jmp next_char

closing:
    cmp ebx, 0
    je invalid

    pop edx
    dec ebx
    jmp next_char

end_scan:
    cmp ebx, 0
    jne invalid

    mov eax, 1
    ret

invalid:
cleanup:
    cmp ebx, 0
    je return_false

    pop edx
    dec ebx
    jmp cleanup

return_false:
    xor eax, eax
    ret

exit_program:
    mov eax, 1
    xor ebx, ebx
    int 0x80
