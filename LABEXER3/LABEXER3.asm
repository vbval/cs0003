
BITS 32


; nasm -f elf32 -o LABEXER3.o LABEXER3.asm
; ld -m elf_i386 -o LABEXER3 LABEXER3.o
; ./LABEXER3

; ==========================================================
; FLAB3 - COR MENU-DRIVEN SYSTEM
; NASM 32-BIT ASSEMBLY - LINUX
;
; 1. Input
; 2. Output
; 3. Write to COR.txt
; 4. Read from COR.txt
; 5. Exit
;
; Lecture: PHP 1000 per unit (FIXED)
; Lab:     PHP 2500 per unit (FIXED)
; ==========================================================

%define SUBJECT_COUNT 11
%define LECTURE_PRICE 1000
%define LAB_PRICE 2500
%define MAX_UNITS 99

; ==========================================================
; MACROS
; ==========================================================

%macro print_text 2
    mov ecx, %1
    mov edx, %2
    call print_proc
%endmacro

%macro read_text 2
    mov ecx, %1
    mov edx, %2
    call read_proc
%endmacro

%macro input_field 3
    print_text %1, %1_len
    read_text %2, %3
%endmacro

%macro output_field 2
    print_text %1, %1_len
    mov ecx, %2
    call print_string
    print_text newline, 1
%endmacro

section .data

; ==========================================================
; MAIN MENU
; ==========================================================

menu db 10
     db "========================================",10
     db "                  COR",10
     db "========================================",10
     db "1. Input",10
     db "2. Output",10
     db "3. Write",10
     db "4. Read",10
     db "5. Exit",10,10
     db "Enter your choice: "
menu_len equ $-menu

invalid_choice db "Invalid choice! Please select 1-5.",10
invalid_choice_len equ $-invalid_choice

no_data db "No student information available.",10
no_data_len equ $-no_data

input_done db 10,"Student information saved in memory!",10
input_done_len equ $-input_done

write_done db 10,"COR successfully written to COR.txt!",10
write_done_len equ $-write_done

read_title db 10,"========== SAVED COR FILE ==========",10
read_title_len equ $-read_title

file_error db "Error: Cannot open or create COR.txt.",10
file_error_len equ $-file_error

read_error db "Error while reading COR.txt.",10
read_error_len equ $-read_error

exit_msg db 10,"Thank you for using the COR System!",10
exit_msg_len equ $-exit_msg

filename db "COR.txt",0

; ==========================================================
; STUDENT INFORMATION
; ==========================================================

title db 10
      db "========================================",10
      db "       CERTIFICATE OF REGISTRATION",10
      db "========================================",10
title_len equ $-title

student_title db 10
    db "========== STUDENT INFORMATION ==========",10
student_title_len equ $-student_title

p_status db "Enrollment Status : "
p_status_len equ $-p_status

p_id db "Student Number    : "
p_id_len equ $-p_id

p_name db "Student Name      : "
p_name_len equ $-p_name

p_college db "College           : "
p_college_len equ $-p_college

p_program db "Program           : "
p_program_len equ $-p_program

p_year db "Year Level        : "
p_year_len equ $-p_year

p_term db "Term / School Year: "
p_term_len equ $-p_term

p_phone db "Phone Number      : "
p_phone_len equ $-p_phone

p_zip db "Zip Code          : "
p_zip_len equ $-p_zip

p_address db "Address           : "
p_address_len equ $-p_address

p_class db "Classification    : "
p_class_len equ $-p_class

; ==========================================================
; SUBJECTS FROM COR
; ==========================================================

s1 db "CCS0021  - INFORMATION MANAGEMENT (LEC)",0
s2 db "CCS0021L - INFORMATION MANAGEMENT (LAB)",0
s3 db "CS0001   - DISCRETE STRUCTURES 1",0
s4 db "CS0003   - COMPUTER SYSTEMS & ARCHITECTURE",0
s5 db "CS0003L  - COMPUTER SYSTEMS & ARCHITECTURE (LAB)",0
s6 db "CS0070   - OBJECT ORIENTED PROGRAMMING",0
s7 db "CS0070L  - OBJECT ORIENTED PROGRAMMING-LAB",0
s8 db "GED0021  - SPECIALIZED ENGLISH PROGRAM 2",0
s9 db "GED0055  - MATHEMATICAL ANALYSIS",0
s10 db "GED0081  - COLLEGE PHYSICS 1 LECTURE",0
s11 db "GED0081L - COLLEGE PHYSICS 1 LABORATORY",0

subjects dd s1,s2,s3,s4,s5,s6
         dd s7,s8,s9,s10,s11

; 1 = Laboratory, 0 = Lecture
lab_flags db 0,1,0,0,1,0,1,0,0,0,1

subject_title db 10
    db "========== SUBJECT ENROLLMENT ==========",10
subject_title_len equ $-subject_title

summary_title db 10
    db "========== ENROLLED SUBJECTS ==========",10
summary_title_len equ $-summary_title

units_prompt db 10,"Enter units (0-99): "
units_prompt_len equ $-units_prompt

units_label db " | Units: "
units_label_len equ $-units_label

error_units db "Invalid units! Enter 0 to 99 only.",10
error_units_len equ $-error_units

; ==========================================================
; TUITION ASSESSMENT
; ==========================================================

result_title db 10
    db "========== TUITION ASSESSMENT ==========",10
result_title_len equ $-result_title

total_units_msg db "Total Units          : "
total_units_len equ $-total_units_msg

lec_units_msg db "Lecture Units        : "
lec_units_len equ $-lec_units_msg

lab_units_msg db "Laboratory Units     : "
lab_units_len equ $-lab_units_msg

lec_price_msg db "Lecture Price/Unit   : PHP "
lec_price_len equ $-lec_price_msg

lab_price_msg db "Laboratory Price/Unit: PHP "
lab_price_len equ $-lab_price_msg

tuition_msg db "Lecture Tuition Fee  : PHP "
tuition_len equ $-tuition_msg

lab_fee_msg db "Laboratory Tuition   : PHP "
lab_fee_len equ $-lab_fee_msg

total_msg db "TOTAL ASSESSMENT     : PHP "
total_len equ $-total_msg

; ==========================================================
; FORMULA
; ==========================================================

formula_title db 10
    db "========== TUITION FORMULA ==========",10
formula_title_len equ $-formula_title

formula_msg db "Total = (Lecture Units x 1000) + "
            db "(Lab Units x 2500)",10
formula_msg_len equ $-formula_msg

computation_msg db "Computation: ("
computation_msg_len equ $-computation_msg

multiply_msg db " x "
multiply_msg_len equ $-multiply_msg

plus_msg db ") + ("
plus_msg_len equ $-plus_msg

close_msg db ") = PHP "
close_msg_len equ $-close_msg

line db "----------------------------------------",10
line_len equ $-line

newline db 10
decimal db ".00"

; File descriptor for output.
; 1 = terminal, other value = open COR.txt
output_fd dd 1

section .bss

; ==========================================================
; STUDENT BUFFERS
; ==========================================================

status resb 64
student_id resb 64
student_name resb 128
college resb 64
program resb 64
year_level resb 32
term resb 64
phone resb 64
zip resb 32
address resb 128
classification resb 64

; ==========================================================
; INPUT / OUTPUT BUFFERS
; ==========================================================

char_buffer resb 1
input_buffer resb 32
number_buffer resb 16
file_buffer resb 1024

menu_choice resd 1
file_descriptor resd 1
has_data resd 1

subject_units resd SUBJECT_COUNT

total_units resd 1
lecture_units resd 1
laboratory_units resd 1

tuition_fee resd 1
laboratory_fee resd 1
total_assessment resd 1

subject_index resd 1

section .text
global _start

; ==========================================================
; MAIN PROGRAM
; ==========================================================

_start:

    mov dword [has_data], 0
    mov dword [output_fd], 1

main_menu:

    print_text menu, menu_len

    read_text input_buffer, 32

    ; Exit on end of input
    cmp eax, 0
    je exit_program

    ; Require exactly one menu character
    cmp eax, 1
    jne invalid_menu

    mov al, [input_buffer]
    movzx eax, al
    mov [menu_choice], eax

    cmp eax, '1'
    je option_input

    cmp eax, '2'
    je option_output

    cmp eax, '3'
    je option_write

    cmp eax, '4'
    je option_read

    cmp eax, '5'
    je exit_program

invalid_menu:

    print_text invalid_choice, invalid_choice_len
    jmp main_menu

; ==========================================================
; OPTION 1 - INPUT
; ==========================================================

option_input:

    call reset_values
    call get_student_info
    call input_subject_units
    call calculate_tuition

    mov dword [has_data], 1

    print_text input_done, input_done_len

    jmp main_menu

; ==========================================================
; OPTION 2 - OUTPUT
; ==========================================================

option_output:

    cmp dword [has_data], 1
    jne no_information

    mov dword [output_fd], 1
    call display_full_cor

    jmp main_menu

; ==========================================================
; OPTION 3 - WRITE TO FILE
; ==========================================================

option_write:

    cmp dword [has_data], 1
    jne no_information

    call write_file
    jmp main_menu

; ==========================================================
; OPTION 4 - READ FROM FILE
; ==========================================================

option_read:

    call read_file
    jmp main_menu

; ==========================================================
; OPTION 5 - EXIT
; ==========================================================

exit_program:

    print_text exit_msg, exit_msg_len

    mov eax, 1
    xor ebx, ebx
    int 0x80

no_information:

    print_text no_data, no_data_len
    jmp main_menu

; ==========================================================
; PROCEDURE: reset_values
; ==========================================================

reset_values:

    mov dword [total_units], 0
    mov dword [lecture_units], 0
    mov dword [laboratory_units], 0

    mov dword [tuition_fee], 0
    mov dword [laboratory_fee], 0
    mov dword [total_assessment], 0

    mov dword [has_data], 0

    ret

; ==========================================================
; PROCEDURE: print_proc
; Uses Linux sys_write
; ECX = text address
; EDX = text length
; ==========================================================

print_proc:

    push eax
    push ebx

    mov eax, 4
    mov ebx, [output_fd]
    int 0x80

    pop ebx
    pop eax
    ret

; ==========================================================
; PROCEDURE: read_proc
; Reads input character by character
; ECX = destination
; EDX = buffer size
; Returns EAX = length
; ==========================================================

read_proc:

    push ebx
    push ecx
    push edx
    push esi
    push edi

    mov esi, ecx
    mov edi, edx
    dec edi

    xor ebx, ebx

.read_loop:

    push ebx

    mov eax, 3
    mov ebx, 0
    mov ecx, char_buffer
    mov edx, 1
    int 0x80

    pop ebx

    cmp eax, 1
    jne .read_done

    mov al, [char_buffer]

    cmp al, 10
    je .read_done

    cmp al, 13
    je .read_loop

    cmp ebx, edi
    jae .read_loop

    mov [esi+ebx], al

    inc ebx
    jmp .read_loop

.read_done:

    mov byte [esi+ebx], 0
    mov eax, ebx

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx

    ret

; ==========================================================
; PROCEDURE: print_string
; Prints a null-terminated string
; ==========================================================

print_string:

    pushad

    mov esi, ecx
    xor edx, edx

.find_length:

    cmp byte [esi+edx], 0
    je .print_now

    inc edx
    jmp .find_length

.print_now:

    call print_proc

    popad
    ret

; ==========================================================
; PROCEDURE: get_student_info
; ==========================================================

get_student_info:

    print_text title, title_len

    input_field p_status, status, 64
    input_field p_id, student_id, 64
    input_field p_name, student_name, 128
    input_field p_college, college, 64
    input_field p_program, program, 64
    input_field p_year, year_level, 32
    input_field p_term, term, 64
    input_field p_phone, phone, 64
    input_field p_zip, zip, 32
    input_field p_address, address, 128
    input_field p_class, classification, 64

    ret

; ==========================================================
; PROCEDURE: display_student_info
; ==========================================================

display_student_info:

    print_text student_title, student_title_len

    output_field p_status, status
    output_field p_id, student_id
    output_field p_name, student_name
    output_field p_college, college
    output_field p_program, program
    output_field p_year, year_level
    output_field p_term, term
    output_field p_phone, phone
    output_field p_zip, zip
    output_field p_address, address
    output_field p_class, classification

    ret

; ==========================================================
; PROCEDURE: input_subject_units
; ==========================================================

input_subject_units:

    print_text subject_title, subject_title_len

    mov dword [subject_index], 0

.subject_loop:

    mov esi, [subject_index]

    cmp esi, SUBJECT_COUNT
    jge .done

    mov ecx, [subjects+esi*4]
    call print_string

    print_text units_prompt, units_prompt_len

    call read_number

    mov esi, [subject_index]
    mov [subject_units+esi*4], eax

    add dword [total_units], eax

    cmp byte [lab_flags+esi], 1
    je .add_lab

    add dword [lecture_units], eax
    jmp .next

.add_lab:

    add dword [laboratory_units], eax

.next:

    inc dword [subject_index]
    jmp .subject_loop

.done:
    ret

; ==========================================================
; PROCEDURE: read_number
; Validates integers from 0 to 99
; ==========================================================

read_number:

    push ebx
    push ecx
    push esi

.retry:

    read_text input_buffer, 32

    cmp eax, 0
    je .invalid

    mov ecx, eax
    mov esi, input_buffer
    xor eax, eax

.convert:

    cmp ecx, 0
    je .done

    movzx ebx, byte [esi]

    cmp bl, '0'
    jb .invalid

    cmp bl, '9'
    ja .invalid

    sub ebx, '0'

    imul eax, eax, 10
    add eax, ebx

    cmp eax, MAX_UNITS
    ja .invalid

    inc esi
    dec ecx

    jmp .convert

.invalid:

    print_text error_units, error_units_len
    jmp .retry

.done:

    pop esi
    pop ecx
    pop ebx

    ret

; ==========================================================
; PROCEDURE: calculate_tuition
; ==========================================================

calculate_tuition:

    push ebx

    ; Lecture units x 1000
    mov eax, [lecture_units]
    mov ebx, LECTURE_PRICE
    mul ebx

    mov [tuition_fee], eax

    ; Laboratory units x 2500
    mov eax, [laboratory_units]
    mov ebx, LAB_PRICE
    mul ebx

    mov [laboratory_fee], eax

    ; Total
    mov eax, [tuition_fee]
    add eax, [laboratory_fee]

    mov [total_assessment], eax

    pop ebx
    ret

; ==========================================================
; PROCEDURE: display_subjects
; ==========================================================

display_subjects:

    print_text summary_title, summary_title_len

    push esi
    xor esi, esi

.subject_loop:

    cmp esi, SUBJECT_COUNT
    jge .done

    mov ecx, [subjects+esi*4]
    call print_string

    print_text units_label, units_label_len

    mov eax, [subject_units+esi*4]
    call print_number

    print_text newline, 1

    inc esi
    jmp .subject_loop

.done:

    pop esi
    ret

; ==========================================================
; PROCEDURE: display_assessment
; ==========================================================

display_assessment:

    print_text result_title, result_title_len

    print_text total_units_msg, total_units_len
    mov eax, [total_units]
    call print_number
    print_text newline, 1

    print_text lec_units_msg, lec_units_len
    mov eax, [lecture_units]
    call print_number
    print_text newline, 1

    print_text lab_units_msg, lab_units_len
    mov eax, [laboratory_units]
    call print_number
    print_text newline, 1

    print_text line, line_len

    print_text lec_price_msg, lec_price_len
    mov eax, LECTURE_PRICE
    call print_money
    print_text newline, 1

    print_text lab_price_msg, lab_price_len
    mov eax, LAB_PRICE
    call print_money
    print_text newline, 1

    print_text line, line_len

    print_text tuition_msg, tuition_len
    mov eax, [tuition_fee]
    call print_money
    print_text newline, 1

    print_text lab_fee_msg, lab_fee_len
    mov eax, [laboratory_fee]
    call print_money
    print_text newline, 1

    print_text line, line_len

    print_text total_msg, total_len
    mov eax, [total_assessment]
    call print_money
    print_text newline, 1

    print_text line, line_len

    ret

; ==========================================================
; PROCEDURE: display_formula
; ==========================================================

display_formula:

    print_text formula_title, formula_title_len
    print_text formula_msg, formula_msg_len

    print_text computation_msg, computation_msg_len

    mov eax, [lecture_units]
    call print_number

    print_text multiply_msg, multiply_msg_len

    mov eax, LECTURE_PRICE
    call print_number

    print_text plus_msg, plus_msg_len

    mov eax, [laboratory_units]
    call print_number

    print_text multiply_msg, multiply_msg_len

    mov eax, LAB_PRICE
    call print_number

    print_text close_msg, close_msg_len

    mov eax, [total_assessment]
    call print_money

    print_text newline, 1

    ret

; ==========================================================
; PROCEDURE: display_full_cor
; Used by both Output and Write
; ==========================================================

display_full_cor:

    print_text title, title_len

    call display_student_info
    call display_subjects
    call display_assessment
    call display_formula

    ret

; ==========================================================
; PROCEDURE: write_file
; Creates/overwrites COR.txt
; Linux sys_creat = 8
; Linux sys_close = 6
; ==========================================================

write_file:

    ; Create file with permissions 0644
    mov eax, 8
    mov ebx, filename
    mov ecx, 0644
    int 0x80

    test eax, eax
    js .error

    mov [file_descriptor], eax

    ; Redirect program output to COR.txt
    mov [output_fd], eax

    ; Write the complete COR using
    ; the existing output procedures
    call display_full_cor

    ; Restore terminal output
    mov dword [output_fd], 1

    ; Close file
    mov eax, 6
    mov ebx, [file_descriptor]
    int 0x80

    print_text write_done, write_done_len
    ret

.error:

    mov dword [output_fd], 1
    print_text file_error, file_error_len
    ret

; ==========================================================
; PROCEDURE: read_file
; Opens COR.txt and displays saved contents
;
; sys_open  = 5
; sys_read  = 3
; sys_close = 6
; ==========================================================

read_file:

    ; Open file for reading
    mov eax, 5
    mov ebx, filename
    mov ecx, 0
    xor edx, edx
    int 0x80

    test eax, eax
    js .error

    mov [file_descriptor], eax

    print_text read_title, read_title_len

.read_loop:

    ; Read up to 1024 bytes
    mov eax, 3
    mov ebx, [file_descriptor]
    mov ecx, file_buffer
    mov edx, 1024
    int 0x80

    cmp eax, 0
    je .done

    js .read_failed

    ; Save number of bytes read
    push eax

    ; Display bytes to terminal
    mov edx, eax
    mov ecx, file_buffer
    mov ebx, 1
    mov eax, 4
    int 0x80

    pop eax

    jmp .read_loop

.read_failed:

    print_text read_error, read_error_len

.done:

    mov eax, 6
    mov ebx, [file_descriptor]
    int 0x80

    ret

.error:

    print_text file_error, file_error_len
    ret

; ==========================================================
; PROCEDURE: print_number
; Converts integer to ASCII with commas
; ==========================================================

print_number:

    pushad

    mov edi, number_buffer+16
    mov ebx, 10

    xor esi, esi

.number_loop:

    xor edx, edx
    div ebx

    add dl, '0'

    dec edi
    mov [edi], dl

    inc esi

    cmp eax, 0
    je .number_done

    ; Insert comma after every 3 digits
    mov ecx, esi

    push eax
    push edx

    mov eax, ecx
    xor edx, edx
    mov ecx, 3
    div ecx

    mov ecx, edx

    pop edx
    pop eax

    cmp ecx, 0
    jne .number_loop

    dec edi
    mov byte [edi], ','

    jmp .number_loop

.number_done:

    mov ecx, edi
    mov edx, number_buffer+16
    sub edx, edi

    call print_proc

    popad
    ret

; ==========================================================
; PROCEDURE: print_money
; Displays number with .00
; ==========================================================

print_money:

    pushad

    call print_number
    print_text decimal, 3

    popad
    ret