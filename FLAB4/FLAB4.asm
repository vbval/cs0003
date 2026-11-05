
BITS 32

section .data

    ; GEORGETTE EATERY MENU

    menu db 10
         db "+..............Georgette EATERY..............+", 10
         db "| A. Rice : Plain Rice                       |", 10
         db "| B. Rice : Java Rice                        |", 10
         db "| C. Ulam 1: (Fish)                          |", 10
         db "| D. Ulam 2: (Pork)                          |", 10
         db "| E. Ulam 3: (Vegetables)                    |", 10
         db "| F. Dessert: Saging con yelo                |", 10
         db "+...........................................+", 10
    menu_len equ $ - menu

    ; MESSAGES

    ask_order db "Enter your order: "
    ask_order_len equ $ - ask_order

    ask_again db "Do you want to order again? [Y/N]: "
    ask_again_len equ $ - ask_again

    thank_you db "Thank you! Please come again!", 10
    thank_you_len equ $ - thank_you

    invalid_msg db "Invalid choice! Please try again.", 10
    invalid_len equ $ - invalid_msg

    receipt_title db 10, "Receipt", 10
    receipt_title_len equ $ - receipt_title

    file_error db "Error opening receipt file!", 10
    file_error_len equ $ - file_error

    ; FOOD ITEMS AND PRICES

    itemA db "Plain Rice: Php 5.00", 10
    itemA_len equ $ - itemA

    itemB db "Java Rice: Php 10.00", 10
    itemB_len equ $ - itemB

    itemC db "Fish: Php 35.00", 10
    itemC_len equ $ - itemC

    itemD db "Pork: Php 50.00", 10
    itemD_len equ $ - itemD

    itemE db "Vegetables: Php 20.00", 10
    itemE_len equ $ - itemE

    itemF db "Saging con yelo: Php 60.00", 10
    itemF_len equ $ - itemF

    ordered_msg db "You ordered "
    ordered_len equ $ - ordered_msg

    filename db "receipt.txt", 0

section .bss

    choice resb 16
    again resb 16
    file_descriptor resd 1
    read_descriptor resd 1
    buffer resb 1024
    selected_item resd 1
    selected_len resd 1

section .text
    global _start

; MACROS

%macro print 2
    mov eax, 4
    mov ebx, 1
    mov ecx, %1
    mov edx, %2
    int 0x80
%endmacro

%macro input 2
    mov eax, 3
    mov ebx, 0
    mov ecx, %1
    mov edx, %2
    int 0x80
%endmacro

; MAIN PROGRAM

_start:

    ; Create receipt.txt
    mov eax, 5
    mov ebx, filename
    mov ecx, 577
    mov edx, 0644o
    int 0x80

    cmp eax, 0
    jl file_open_error

    mov [file_descriptor], eax

main_loop:

    call display_menu

    print ask_order, ask_order_len
    input choice, 16

    call process_order

    cmp eax, 0
    je main_loop

ask_repeat:

    print ask_again, ask_again_len
    input again, 16

    mov al, [again]

    cmp al, 'Y'
    je main_loop

    cmp al, 'y'
    je main_loop

    cmp al, 'N'
    je finish

    cmp al, 'n'
    je finish

    print invalid_msg, invalid_len
    jmp ask_repeat

; PROCEDURE: DISPLAY MENU

display_menu:

    print menu, menu_len

    ret

; PROCEDURE: PROCESS ORDER

process_order:

    mov al, [choice]

    cmp al, 'A'
    je order_A
    cmp al, 'a'
    je order_A

    cmp al, 'B'
    je order_B
    cmp al, 'b'
    je order_B

    cmp al, 'C'
    je order_C
    cmp al, 'c'
    je order_C

    cmp al, 'D'
    je order_D
    cmp al, 'd'
    je order_D

    cmp al, 'E'
    je order_E
    cmp al, 'e'
    je order_E

    cmp al, 'F'
    je order_F
    cmp al, 'f'
    je order_F

    print invalid_msg, invalid_len

    xor eax, eax
    ret

; ORDER A - PLAIN RICE

order_A:

    mov dword [selected_item], itemA
    mov dword [selected_len], itemA_len

    jmp save_order

; ORDER B - JAVA RICE

order_B:

    mov dword [selected_item], itemB
    mov dword [selected_len], itemB_len

    jmp save_order

; ORDER C - FISH

order_C:

    mov dword [selected_item], itemC
    mov dword [selected_len], itemC_len

    jmp save_order

; ORDER D - PORK

order_D:

    mov dword [selected_item], itemD
    mov dword [selected_len], itemD_len

    jmp save_order

; ORDER E - VEGETABLES

order_E:

    mov dword [selected_item], itemE
    mov dword [selected_len], itemE_len

    jmp save_order


; ORDER F - SAGING CON YELO

order_F:

    mov dword [selected_item], itemF
    mov dword [selected_len], itemF_len

    jmp save_order

; PROCEDURE: SAVE ORDER

save_order:

    ; Display ordered item
    print ordered_msg, ordered_len

    mov eax, 4
    mov ebx, 1
    mov ecx, [selected_item]
    mov edx, [selected_len]
    int 0x80

    ; Write order to receipt.txt
    mov eax, 4
    mov ebx, [file_descriptor]
    mov ecx, [selected_item]
    mov edx, [selected_len]
    int 0x80

    mov eax, 1
    ret

; FINISH ORDERING

finish:

    print thank_you, thank_you_len

    ; Close receipt.txt
    mov eax, 6
    mov ebx, [file_descriptor]
    int 0x80

    ; Display receipt
    call display_receipt

    ; Exit program
    mov eax, 1
    xor ebx, ebx
    int 0x80

; PROCEDURE: DISPLAY RECEIPT

display_receipt:

    ; Open receipt.txt for reading
    mov eax, 5
    mov ebx, filename
    mov ecx, 0
    int 0x80

    cmp eax, 0
    jl file_open_error

    mov [read_descriptor], eax

    print receipt_title, receipt_title_len

read_file:

    ; Read receipt file
    mov eax, 3
    mov ebx, [read_descriptor]
    mov ecx, buffer
    mov edx, 1024
    int 0x80

    cmp eax, 0
    jle close_read_file

    ; Display file contents
    mov edx, eax
    mov eax, 4
    mov ebx, 1
    mov ecx, buffer
    int 0x80

    jmp read_file

close_read_file:

    mov eax, 6
    mov ebx, [read_descriptor]
    int 0x80

    ret

; FILE ERROR HANDLING

file_open_error:

    print file_error, file_error_len

    mov eax, 1
    mov ebx, 1
    int 0x80