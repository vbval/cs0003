
BITS 32


; nasm -f elf32 FP.asm -o FP.o &&
; ld -m elf_i386 FP.o -o FP &&
; ./FP

; ==========================================
; RAMEN HOUSE - ORDERING AND BILLING SYSTEM
; NASM 32-BIT LINUX ASSEMBLY
; ==========================================

%define SYS_EXIT  1
%define SYS_READ  3
%define SYS_WRITE 4
%define SYS_OPEN  5
%define SYS_CLOSE 6

%define O_RDONLY 0
%define O_WRONLY_CREAT_TRUNC 577

; ==========================================
; MACROS
; ==========================================

%macro say 2
    pushad
    mov eax, SYS_WRITE
    mov ebx, 1
    mov ecx, %1
    mov edx, %2
    int 0x80
    popad
%endmacro

%macro literal 1
    say %1, %1_len
%endmacro

section .data

banner db 10
       db '========================================',10
       db '              RAMEN HOUSE',10
       db '========================================',10
       db '          (  )     (  )',10
       db '           ) (     ) (',10
       db '         _____________',10
       db '        /             \',10
       db '       |  RAMEN HOUSE  |',10
       db '       |  ~~~~~~~~~~~  |',10
       db '        \_____________/',10
       db '       RAMEN ORDERING SYSTEM',10
       db '========================================',10
banner_len equ $-banner

mainmenu db 10
         db '============= MAIN MENU =============',10
         db ' [1] View Ramen Menu',10
         db ' [2] Place an Order',10
         db ' [3] View Current Cart',10
         db ' [4] Remove an Order',10
         db ' [5] Checkout and Save Receipt',10
         db ' [6] Read Saved Receipt',10
         db ' [7] Exit',10
         db '=====================================',10
         db 'Enter your choice: '
mainmenu_len equ $-mainmenu

foodmenu db 10
         db '============= RAMEN MENU ============',10
         db ' [1] Shoyu Ramen      PHP 180',10
         db ' [2] Miso Ramen       PHP 200',10
         db ' [3] Tonkotsu Ramen   PHP 250',10
         db ' [4] Spicy Ramen      PHP 220',10
         db ' [5] Veggie Ramen     PHP 170',10
         db '=====================================',10
foodmenu_len equ $-foodmenu

itemprompt db 'Enter ramen number (1-5): '
itemprompt_len equ $-itemprompt

removeprompt db 'Enter ramen number to remove (1-5): '
removeprompt_len equ $-removeprompt

invalid db 'Invalid input. Please try again.',10
invalid_len equ $-invalid

added db 'Ramen successfully added to cart!',10
added_len equ $-added

removed db 'One ramen order removed from cart!',10
removed_len equ $-removed

notfound db 'This ramen is not in your cart.',10
notfound_len equ $-notfound

maxqty db 'Maximum quantity of 99 reached.',10
maxqty_len equ $-maxqty

empty db 'Your cart is empty.',10
empty_len equ $-empty

carthead db 10
         db '============= YOUR CART =============',10
carthead_len equ $-carthead

lineprefix db '  x '
lineprefix_len equ $-lineprefix

atprice db ' @ PHP '
atprice_len equ $-atprice

subtotaltext db ' = PHP '
subtotaltext_len equ $-subtotaltext

totaltext db 'TOTAL: PHP '
totaltext_len equ $-totaltext

paymenttext db 'PAYMENT: PHP '
paymenttext_len equ $-paymenttext

changetext db 'CHANGE: PHP '
changetext_len equ $-changetext

payprompt db 'Enter payment in PHP: '
payprompt_len equ $-payprompt

insufficient db 'Insufficient payment. Please try again.',10
insufficient_len equ $-insufficient

saved db 'Receipt saved to ramen_receipt.txt.',10
      db 'Cart has been cleared.',10
saved_len equ $-saved

fileerror db 'Could not access ramen_receipt.txt.',10
fileerror_len equ $-fileerror

bye db 10
    db 'Thank you for visiting Ramen House!',10
    db 'Please come again!',10
bye_len equ $-bye

newline db 10
newline_len equ $-newline

receiptname db 'ramen_receipt.txt',0

receiptbanner db 10
              db '==== RAMEN HOUSE RECEIPT ====',10
receiptbanner_len equ $-receiptbanner

receiptend db '=============================',10
receiptend_len equ $-receiptend

names dd name1,name2,name3,name4,name5

name1 db ' Shoyu Ramen',0
name2 db ' Miso Ramen',0
name3 db ' Tonkotsu Ramen',0
name4 db ' Spicy Ramen',0
name5 db ' Veggie Ramen',0

prices dd 180,200,250,220,170

section .bss

inputbuf   resb 128
quantities resd 5
numberbuf  resb 16
numlen     resd 1
filefd     resd 1
payment    resd 1
change     resd 1
readbuf    resb 2048

section .text
global _start

; ==========================================
; MAIN PROGRAM
; ==========================================

_start:

    literal banner

.menu:

    literal mainmenu

    call read_number

    cmp eax,1
    je .view

    cmp eax,2
    je .order

    cmp eax,3
    je .cart

    cmp eax,4
    je .remove

    cmp eax,5
    je .checkout

    cmp eax,6
    je .read

    cmp eax,7
    je .exit

    literal invalid
    jmp .menu

.view:

    literal foodmenu
    jmp .menu

.order:

    call place_order
    jmp .menu

.cart:

    call show_cart
    jmp .menu

.remove:

    call remove_order
    jmp .menu

.checkout:

    call checkout
    jmp .menu

.read:

    call read_receipt
    jmp .menu

.exit:

    literal bye

    mov eax,SYS_EXIT
    xor ebx,ebx
    int 0x80

; ==========================================
; READ NUMBER
; ==========================================

read_number:

    push ebx
    push ecx
    push edx
    push esi
    push edi

    xor esi,esi
    xor edx,edx
    xor edi,edi

.next:

    push edx

    mov eax,SYS_READ
    xor ebx,ebx
    mov ecx,inputbuf
    mov edx,1
    int 0x80

    pop edx

    cmp eax,1
    jne .finish

    mov bl,[inputbuf]

    cmp bl,10
    je .finish

    cmp bl,13
    je .next

    cmp bl,'0'
    jb .markbad

    cmp bl,'9'
    ja .markbad

    cmp edi,0
    jne .next

    sub bl,'0'

    cmp esi,429496729
    ja .markbad
    jb .safe

    cmp bl,5
    ja .markbad

.safe:

    imul esi,esi,10

    movzx ebx,bl
    add esi,ebx

    inc edx
    jmp .next

.markbad:

    mov edi,1
    jmp .next

.finish:

    cmp edx,0
    je .bad

    cmp edi,0
    jne .bad

    mov eax,esi
    jmp .return

.bad:

    mov eax,-1

.return:

    pop edi
    pop esi
    pop edx
    pop ecx
    pop ebx
    ret

; ==========================================
; FORMAT NUMBER
; ==========================================

format_number:

    pushad

    mov edi,numberbuf+15
    xor ecx,ecx
    mov ebx,10

.repeat:

    xor edx,edx
    div ebx

    add dl,'0'
    dec edi

    mov [edi],dl
    inc ecx

    test eax,eax
    jnz .repeat

    mov [numlen],ecx

    mov esi,edi
    mov edi,numberbuf

.copy:

    mov al,[esi]
    mov [edi],al

    inc esi
    inc edi

    loop .copy

    popad
    ret

; ==========================================
; PRINT NUMBER
; ==========================================

print_number:

    call format_number

    mov edx,[numlen]
    say numberbuf,edx

    ret

; ==========================================
; WRITE FILE
; ==========================================

write_file:

    pushad

    mov esi,eax
    mov edi,ecx
    mov ebp,edx

.again:

    test ebp,ebp
    jz .done

    mov eax,SYS_WRITE
    mov ebx,esi
    mov ecx,edi
    mov edx,ebp

    int 0x80

    test eax,eax
    jle .done

    add edi,eax
    sub ebp,eax

    jmp .again

.done:

    popad
    ret

; ==========================================
; OUTPUT BOTH
; ==========================================

output_both:

    pushad

    mov esi,eax
    mov edi,ecx
    mov ebp,edx

    say edi,ebp

    cmp esi,0
    jl .done

    mov eax,esi
    mov ecx,edi
    mov edx,ebp

    call write_file

.done:

    popad
    ret

; ==========================================
; OUTPUT STRING
; ==========================================

output_z:

    pushad

    mov edi,ecx
    xor edx,edx

.count:

    cmp byte [edi+edx],0
    je .donecount

    inc edx
    jmp .count

.donecount:

    call output_both

    popad
    ret

; ==========================================
; OUTPUT NUMBER
; ==========================================

output_number:

    pushad

    mov esi,eax
    mov eax,ebx

    call format_number

    mov eax,esi
    mov ecx,numberbuf
    mov edx,[numlen]

    call output_both

    popad
    ret

; ==========================================
; PLACE ORDER
; Automatically adds ONE ramen to cart
; ==========================================

place_order:

    literal foodmenu
    literal itemprompt

    call read_number

    cmp eax,1
    jb .bad

    cmp eax,5
    ja .bad

    dec eax
    mov esi,eax

    ; Check maximum quantity

    cmp dword [quantities+esi*4],99
    jae .maximum

    ; Automatically add 1 order

    inc dword [quantities+esi*4]

    literal added
    ret

.maximum:

    literal maxqty
    ret

.bad:

    literal invalid
    ret

; ==========================================
; REMOVE ORDER
; Removes ONE unit of selected ramen
; ==========================================

remove_order:

    call get_total

    test eax,eax
    jz .empty

    literal carthead

    mov eax,-1
    call show_items

    literal removeprompt

    call read_number

    cmp eax,1
    jb .bad

    cmp eax,5
    ja .bad

    dec eax
    mov esi,eax

    ; Check if item exists in cart

    cmp dword [quantities+esi*4],0
    je .notfound

    ; Remove one unit

    dec dword [quantities+esi*4]

    literal removed
    ret

.notfound:

    literal notfound
    ret

.empty:

    literal empty
    ret

.bad:

    literal invalid
    ret

; ==========================================
; GET TOTAL
; ==========================================

get_total:

    push ebx
    push ecx
    push edx

    xor eax,eax
    xor ecx,ecx

.loop:

    mov ebx,[quantities+ecx*4]

    imul ebx,[prices+ecx*4]

    add eax,ebx

    inc ecx

    cmp ecx,5
    jb .loop

    pop edx
    pop ecx
    pop ebx

    ret

; ==========================================
; SHOW ITEMS
; ==========================================

show_items:

    pushad

    mov esi,eax
    xor ebp,ebp

.loop:

    mov ebx,[quantities+ebp*4]

    test ebx,ebx
    jz .next

    mov eax,esi
    mov ecx,lineprefix
    mov edx,lineprefix_len

    call output_both

    mov ebx,[quantities+ebp*4]
    mov eax,esi

    call output_number

    mov eax,esi
    mov ecx,[names+ebp*4]

    call output_z

    mov eax,esi
    mov ecx,atprice
    mov edx,atprice_len

    call output_both

    mov eax,esi
    mov ebx,[prices+ebp*4]

    call output_number

    mov eax,esi
    mov ecx,subtotaltext
    mov edx,subtotaltext_len

    call output_both

    mov ebx,[quantities+ebp*4]

    imul ebx,[prices+ebp*4]

    mov eax,esi

    call output_number

    mov eax,esi
    mov ecx,newline
    mov edx,1

    call output_both

.next:

    inc ebp

    cmp ebp,5
    jb .loop

    mov eax,esi
    mov ecx,totaltext
    mov edx,totaltext_len

    call output_both

    call get_total

    mov ebx,eax
    mov eax,esi

    call output_number

    mov eax,esi
    mov ecx,newline
    mov edx,1

    call output_both

    popad
    ret

; ==========================================
; SHOW CART
; ==========================================

show_cart:

    call get_total

    test eax,eax
    jz .empty

    literal carthead

    mov eax,-1
    call show_items

    ret

.empty:

    literal empty
    ret

; ==========================================
; CHECKOUT
; ==========================================

checkout:

    call get_total

    test eax,eax
    jz .empty

    mov edi,eax

    literal payprompt

    call read_number

    cmp eax,-1
    je .badpay

    cmp eax,edi
    jb .insufficient

    mov [payment],eax

    sub eax,edi
    mov [change],eax

    ; Create receipt file

    mov eax,SYS_OPEN
    mov ebx,receiptname
    mov ecx,O_WRONLY_CREAT_TRUNC
    mov edx,0644o

    int 0x80

    test eax,eax
    js .error

    mov [filefd],eax
    mov esi,eax

    ; Print receipt heading

    mov ecx,receiptbanner
    mov edx,receiptbanner_len

    call output_both

    ; Print ordered items

    mov eax,esi
    call show_items

    ; Print payment

    mov eax,esi
    mov ecx,paymenttext
    mov edx,paymenttext_len

    call output_both

    mov eax,esi
    mov ebx,[payment]

    call output_number

    mov eax,esi
    mov ecx,newline
    mov edx,1

    call output_both

    ; Print change

    mov eax,esi
    mov ecx,changetext
    mov edx,changetext_len

    call output_both

    mov eax,esi
    mov ebx,[change]

    call output_number

    mov eax,esi
    mov ecx,newline
    mov edx,1

    call output_both

    ; Receipt ending

    mov eax,esi
    mov ecx,receiptend
    mov edx,receiptend_len

    call output_both

    ; Close receipt file

    mov eax,SYS_CLOSE
    mov ebx,[filefd]

    int 0x80

    ; Clear cart

    mov dword [quantities],0
    mov dword [quantities+4],0
    mov dword [quantities+8],0
    mov dword [quantities+12],0
    mov dword [quantities+16],0

    literal saved
    ret

.empty:

    literal empty
    ret

.badpay:

    literal invalid
    ret

.insufficient:

    literal insufficient
    ret

.error:

    literal fileerror
    ret

; ==========================================
; READ RECEIPT
; ==========================================

read_receipt:

    mov eax,SYS_OPEN
    mov ebx,receiptname
    mov ecx,O_RDONLY
    xor edx,edx

    int 0x80

    test eax,eax
    js .error

    mov [filefd],eax

.readloop:

    mov eax,SYS_READ
    mov ebx,[filefd]
    mov ecx,readbuf
    mov edx,2048

    int 0x80

    test eax,eax
    jle .close

    mov edx,eax

    say readbuf,edx

    jmp .readloop

.close:

    mov eax,SYS_CLOSE
    mov ebx,[filefd]

    int 0x80
    ret

.error:

    literal fileerror
    ret


; END OF PROGRAM