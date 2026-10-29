
BITS 32

; ==========================================================
; FLAB3 - CERTIFICATE OF REGISTRATION (COR)
; NASM 32-BIT ASSEMBLY - LINUX
;
; MACROS, PROCEDURES, INPUT, OUTPUT, COMPUTATION
;
; Student Information: USER INPUT
; Subject Units: USER INPUT (0-99)
; Lecture Price: PHP 1000 (FIXED)
; Laboratory Price: PHP 2500 (FIXED)
;
; FORMULA:
; Total = (Lecture Units * 1000) + (Lab Units * 2500)
;
; COMPILATION:
; nasm -f elf32 FLAB3.asm -o FLAB3.o
; ld -m elf_i386 FLAB3.o -o FLAB3
; ./FLAB3
; ==========================================================

%define SUBJECT_COUNT 11
%define MAX_UNITS 99
%define LECTURE_PRICE 1000
%define LAB_PRICE 2500

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

section .data

    title db 10
          db "========================================",10
          db "       CERTIFICATE OF REGISTRATION",10
          db "========================================",10
    title_len equ $-title

    ; STUDENT INFORMATION PROMPTS

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

    ; ======================================================
    ; SUBJECTS FROM SOLAR / COR
    ; ======================================================

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

    ; SUBJECT ADDRESS ARRAY

    subjects dd s1,s2,s3,s4,s5,s6
             dd s7,s8,s9,s10,s11

    ; LAB FLAGS
    ; 1 = LABORATORY
    ; 0 = LECTURE

    lab_flags db 0,1,0,0,1,0,1,0,0,0,1

    ; ======================================================
    ; DISPLAY MESSAGES
    ; ======================================================

    student_title db 10
        db "========== STUDENT INFORMATION ==========",10
    student_title_len equ $-student_title

    subject_title db 10
        db "========== SUBJECT ENROLLMENT ==========",10
    subject_title_len equ $-subject_title

    summary_title db 10
        db "========== ENROLLED SUBJECTS ==========",10
    summary_title_len equ $-summary_title

    result_title db 10
        db "========== TUITION ASSESSMENT ==========",10
    result_title_len equ $-result_title

    units_prompt db 10
        db "Enter units for this subject (0-99): "
    units_prompt_len equ $-units_prompt

    units_label db " | Units: "
    units_label_len equ $-units_label

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

    ; FORMULA MESSAGES

    formula_title db 10
        db "========== TUITION FORMULA ==========",10
    formula_title_len equ $-formula_title

    formula_msg db "Total = (Lecture Units x 1000) + (Lab Units x 2500)",10
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

    error_units db "Invalid units! Enter 0 to 99 only.",10
    error_units_len equ $-error_units

section .bss

    ; STUDENT INFORMATION BUFFERS

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

    ; INPUT AND OUTPUT BUFFERS

    char_buffer resb 1
    input_buffer resb 32
    number_buffer resb 16

    ; SUBJECT UNITS - USER INPUT

    subject_units resd SUBJECT_COUNT

    ; COMPUTATION VARIABLES

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

    ; Initialize variables
    mov dword [total_units], 0
    mov dword [lecture_units], 0
    mov dword [laboratory_units], 0

    ; Input student information
    call get_student_info

    ; Display student information
    call display_student_info

    ; Input units for each subject
    call input_subject_units

    ; Calculate tuition using fixed prices
    call calculate_tuition

    ; Display enrolled subjects
    call display_subjects

    ; Display final assessment
    call display_assessment

    ; Display tuition formula and computation
    call display_formula

    ; Exit program
    mov eax, 1
    xor ebx, ebx
    int 0x80

; ==========================================================
; PROCEDURE: print_proc
; Linux sys_write
; ECX = message address
; EDX = message length
; ==========================================================

print_proc:
    push eax
    push ebx

    mov eax, 4
    mov ebx, 1
    int 0x80

    pop ebx
    pop eax
    ret

; ==========================================================
; PROCEDURE: read_proc
; Reads input one character at a time
; ECX = destination buffer
; EDX = buffer size
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
; Prints null-terminated string
; ECX = string address
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
; Accepts student information
; ==========================================================

get_student_info:

    print_text title, title_len

    print_text p_status, p_status_len
    read_text status, 64

    print_text p_id, p_id_len
    read_text student_id, 64

    print_text p_name, p_name_len
    read_text student_name, 128

    print_text p_college, p_college_len
    read_text college, 64

    print_text p_program, p_program_len
    read_text program, 64

    print_text p_year, p_year_len
    read_text year_level, 32

    print_text p_term, p_term_len
    read_text term, 64

    print_text p_phone, p_phone_len
    read_text phone, 64

    print_text p_zip, p_zip_len
    read_text zip, 32

    print_text p_address, p_address_len
    read_text address, 128

    print_text p_class, p_class_len
    read_text classification, 64

    ret

; ==========================================================
; PROCEDURE: display_student_info
; Displays entered student information
; ==========================================================

display_student_info:

    print_text student_title, student_title_len

    print_text p_status, p_status_len
    mov ecx, status
    call print_string
    print_text newline, 1

    print_text p_id, p_id_len
    mov ecx, student_id
    call print_string
    print_text newline, 1

    print_text p_name, p_name_len
    mov ecx, student_name
    call print_string
    print_text newline, 1

    print_text p_college, p_college_len
    mov ecx, college
    call print_string
    print_text newline, 1

    print_text p_program, p_program_len
    mov ecx, program
    call print_string
    print_text newline, 1

    print_text p_year, p_year_len
    mov ecx, year_level
    call print_string
    print_text newline, 1

    print_text p_term, p_term_len
    mov ecx, term
    call print_string
    print_text newline, 1

    print_text p_phone, p_phone_len
    mov ecx, phone
    call print_string
    print_text newline, 1

    print_text p_zip, p_zip_len
    mov ecx, zip
    call print_string
    print_text newline, 1

    print_text p_address, p_address_len
    mov ecx, address
    call print_string
    print_text newline, 1

    print_text p_class, p_class_len
    mov ecx, classification
    call print_string
    print_text newline, 1

    ret

; ==========================================================
; PROCEDURE: input_subject_units
; Allows user to enter units for 11 subjects
; ==========================================================

input_subject_units:

    print_text subject_title, subject_title_len

    mov dword [subject_index], 0

.subject_loop:

    mov esi, [subject_index]

    cmp esi, SUBJECT_COUNT
    jge .subjects_done

    ; Display subject name
    mov ecx, [subjects + esi*4]
    call print_string

    ; Ask for units
    print_text units_prompt, units_prompt_len

    ; Read units (0-99)
    call read_number

    ; Store entered units
    mov esi, [subject_index]
    mov [subject_units + esi*4], eax

    ; Add to total units
    add dword [total_units], eax

    ; Check laboratory flag
    cmp byte [lab_flags + esi], 1
    je .add_lab

    ; Add lecture units
    add dword [lecture_units], eax
    jmp .next_subject

.add_lab:
    ; Add laboratory units
    add dword [laboratory_units], eax

.next_subject:
    inc dword [subject_index]
    jmp .subject_loop

.subjects_done:
    ret

; ==========================================================
; PROCEDURE: read_number
; Converts ASCII input to integer
; Validates units from 0 to 99
; ==========================================================

read_number:

    push ebx
    push ecx
    push esi

.retry:
    read_text input_buffer, 32

    ; Reject empty input
    cmp eax, 0
    je .invalid

    mov ecx, eax
    mov esi, input_buffer

    xor eax, eax

.convert_loop:

    cmp ecx, 0
    je .conversion_done

    movzx ebx, byte [esi]

    ; Validate digit
    cmp bl, '0'
    jb .invalid

    cmp bl, '9'
    ja .invalid

    sub ebx, '0'

    ; ASCII to integer
    imul eax, eax, 10
    add eax, ebx

    ; Maximum allowed units
    cmp eax, MAX_UNITS
    ja .invalid

    inc esi
    dec ecx

    jmp .convert_loop

.conversion_done:
    pop esi
    pop ecx
    pop ebx
    ret

.invalid:
    print_text error_units, error_units_len
    jmp .retry

; ==========================================================
; PROCEDURE: calculate_tuition
;
; Lecture Tuition = Lecture Units * 1000
; Laboratory Tuition = Laboratory Units * 2500
; Total Assessment = Lecture + Laboratory
; ==========================================================

calculate_tuition:

    push ebx

    ; Calculate lecture tuition
    mov eax, [lecture_units]
    mov ebx, LECTURE_PRICE
    mul ebx

    mov [tuition_fee], eax

    ; Calculate laboratory tuition
    mov eax, [laboratory_units]
    mov ebx, LAB_PRICE
    mul ebx

    mov [laboratory_fee], eax

    ; Calculate total assessment
    mov eax, [tuition_fee]
    add eax, [laboratory_fee]

    mov [total_assessment], eax

    pop ebx
    ret

; ==========================================================
; PROCEDURE: display_subjects
; Displays subjects and entered units
; ==========================================================

display_subjects:

    print_text summary_title, summary_title_len

    xor esi, esi

.subject_loop:

    cmp esi, SUBJECT_COUNT
    jge .subjects_done

    ; Display subject
    mov ecx, [subjects + esi*4]
    call print_string

    ; Display units label
    print_text units_label, units_label_len

    ; Display entered units
    mov eax, [subject_units + esi*4]
    call print_number

    print_text newline, 1

    inc esi
    jmp .subject_loop

.subjects_done:
    ret

; ==========================================================
; PROCEDURE: display_assessment
; Displays final tuition assessment
; ==========================================================

display_assessment:

    print_text result_title, result_title_len

    ; Total units
    print_text total_units_msg, total_units_len
    mov eax, [total_units]
    call print_number
    print_text newline, 1

    ; Lecture units
    print_text lec_units_msg, lec_units_len
    mov eax, [lecture_units]
    call print_number
    print_text newline, 1

    ; Laboratory units
    print_text lab_units_msg, lab_units_len
    mov eax, [laboratory_units]
    call print_number
    print_text newline, 1

    print_text line, line_len

    ; Fixed lecture price
    print_text lec_price_msg, lec_price_len
    mov eax, LECTURE_PRICE
    call print_money
    print_text newline, 1

    ; Fixed laboratory price
    print_text lab_price_msg, lab_price_len
    mov eax, LAB_PRICE
    call print_money
    print_text newline, 1

    print_text line, line_len

    ; Lecture tuition
    print_text tuition_msg, tuition_len
    mov eax, [tuition_fee]
    call print_money
    print_text newline, 1

    ; Laboratory tuition
    print_text lab_fee_msg, lab_fee_len
    mov eax, [laboratory_fee]
    call print_money
    print_text newline, 1

    print_text line, line_len

    ; Total assessment
    print_text total_msg, total_len
    mov eax, [total_assessment]
    call print_money
    print_text newline, 1

    print_text line, line_len

    ret

; ==========================================================
; PROCEDURE: display_formula
; Displays formula and actual computation
; ==========================================================

display_formula:

    print_text formula_title, formula_title_len
    print_text formula_msg, formula_msg_len

    ; Display: Computation: (
    print_text computation_msg, computation_msg_len

    ; Display lecture units
    mov eax, [lecture_units]
    call print_number

    ; Display x 1000
    print_text multiply_msg, multiply_msg_len
    mov eax, LECTURE_PRICE
    call print_number

    ; Display ) + (
    print_text plus_msg, plus_msg_len

    ; Display laboratory units
    mov eax, [laboratory_units]
    call print_number

    ; Display x 2500
    print_text multiply_msg, multiply_msg_len
    mov eax, LAB_PRICE
    call print_number

    ; Display ) = PHP
    print_text close_msg, close_msg_len

    ; Display total assessment
    mov eax, [total_assessment]
    call print_money

    print_text newline, 1

    ret

; ==========================================================
; PROCEDURE: print_number
; Converts integer to ASCII with commas
; EAX = number to display
; ==========================================================

print_number:

    pushad

    mov edi, number_buffer + 16
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

    mov edx, number_buffer + 16
    sub edx, edi

    call print_proc

    popad
    ret

; ==========================================================
; PROCEDURE: print_money
; Displays whole pesos with .00
; ==========================================================

print_money:

    pushad

    call print_number
    print_text decimal, 3

    popad
    ret
