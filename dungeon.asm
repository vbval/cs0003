;machine problem 2
;Vhinzenz Vielle Ellys B. Valencia
;NASM 32-bit Linux - int 0x80
;nasm -f elf32 DungeonAdventure.asm -o DungeonAdventure.o
;ld -m elf_i386 DungeonAdventure.o -o DungeonAdventure
;./DungeonAdventure

%macro PRINT 2
    mov eax, 4
    mov ebx, 1
    mov ecx, %1
    mov edx, %2
    int 0x80
%endmacro

section .data

welcome db 10
        db "=======================================",10
        db "       DUNGEON OF THE LOST KING",10
        db "=======================================",10
        db "              |>>>>",10
        db "              |",10
        db "          _  _|_  _",10
        db "         |;|_|;|_|;|",10
        db "         \.    .  /",10
        db "          \:  .  /",10
        db "           ||:   |",10
        db "           ||:.  |",10
        db "           ||:  .|",10
        db "       ENTER IF YOU DARE!",10
        db "=======================================",10

welcomeLen equ $-welcome

namePrompt db 10,"Enter your hero name: "
namePromptLen equ $-namePrompt

classMenu db 10,"Choose your character:",10
          db "[1] Warrior",10
          db "[2] Mage",10
          db "[3] Archer",10
          db "Enter choice: "
classMenuLen equ $-classMenu

mainMenu db 10,"========== MAIN MENU ==========",10
         db "[1] Explore Dungeon",10
         db "[2] View Character Status",10
         db "[3] Use Health Potion",10
         db "[4] View Inventory",10
         db "[5] Exit Game",10
         db "Enter choice: "
mainMenuLen equ $-mainMenu

combatMenu db 10,"[1] Attack",10
           db "[2] Defend",10
           db "[3] Use Potion",10
           db "[4] Run",10
           db "Enter choice: "
combatMenuLen equ $-combatMenu


goblinArt db 10,"===== GOBLIN CHAMBER =====",10
          db '          ,      ,',10
          db '         /(.-""-.)\',10
          db '     |\  \/      \/  /|',10
          db '     | \ / =.  .= \ / |',10
          db "      \  \   ^    /  /",10
          db "       \  '-----'  /",10
          db "A GOBLIN APPEARS!",10

goblinArtLen equ $-goblinArt

chestArt db 10,"===== TREASURE CHAMBER =====",10
         db "        __________",10
         db "       /_________/|",10
         db "      |  _____  | |",10
         db "      | |  ?  | | |",10
         db "      | |_____| | /",10
         db "      |_________|/",10
         db "[1] Open Chest",10
         db "[2] Leave Chest",10
         db "Enter choice: "
chestArtLen equ $-chestArt

dragonArt db 10,"===== DRAGON'S LAIR =====",10
          db "           / \ //\",10
          db "      |\___/|     \",10
          db "      /0 0  \      |",10
          db "     /   ^   \    /",10
          db "    / \___/   \  /",10
          db "    \__________\/",10
          db "THE DRAGON AWAKENS!",10
dragonArtLen equ $-dragonArt

warrior db "Warrior"
warriorLen equ $-warrior
mage db "Mage"
mageLen equ $-mage
archer db "Archer"
archerLen equ $-archer

helloMsg db 10,"Welcome, "
helloLen equ $-helloMsg

space db " "
newline db 10

invalidMsg db "Invalid selection! Try again.",10
invalidLen equ $-invalidMsg

healthMsg db "Health: "
healthLen equ $-healthMsg
attackMsg db "Attack: "
attackLen equ $-attackMsg
potionMsg db "Potions: "
potionLen equ $-potionMsg
goldMsg db "Gold: "
goldLen equ $-goldMsg
roomMsg db "Current Room: "
roomLen equ $-roomMsg

statusTitle db 10,"===== CHARACTER STATUS =====",10
statusTitleLen equ $-statusTitle
inventoryTitle db 10,"===== INVENTORY =====",10
inventoryTitleLen equ $-inventoryTitle

attackText db "You attacked the enemy!",10
attackTextLen equ $-attackText
defendText db "You defend against the next attack!",10
defendTextLen equ $-defendText
enemyText db "The enemy attacks!",10
enemyTextLen equ $-enemyText

enemyHealthMsg db "Enemy Health: "
enemyHealthLen equ $-enemyHealthMsg

potionUsed db "Potion used! Restored up to 20 health.",10
potionUsedLen equ $-potionUsed
noPotion db "No potions remaining!",10
noPotionLen equ $-noPotion

runMsg db "You escaped! Returning to main menu.",10
runLen equ $-runMsg
enemyDead db "Enemy defeated!",10
enemyDeadLen equ $-enemyDead

chestOpen db "You opened the chest and gained 50 gold!",10
chestOpenLen equ $-chestOpen
chestLeave db "You left the treasure behind.",10
chestLeaveLen equ $-chestLeave

victoryMsg db 10,"================================",10
           db "            VICTORY!",10
           db "================================",10
           db "CONGRATULATIONS, "
victoryLen equ $-victoryMsg

victoryEnd db 10,"You defeated the dragon and escaped!",10
           db "YOU ARE A HERO!",10
victoryEndLen equ $-victoryEnd

gameOverMsg db 10,"========== GAME OVER ==========",10
            db "Your hero has fallen.",10
            db "The dungeon remains undefeated.",10
            db "BETTER LUCK NEXT TIME!",10
gameOverLen equ $-gameOverMsg

exitMsg db 10,"Thank you for playing!",10
exitLen equ $-exitMsg

section .bss

heroName resb 32
nameLength resd 1
input resb 64
numberBuffer resb 16

playerClass resd 1
health resd 1
maxHealth resd 1
attack resd 1
potions resd 1
gold resd 1
room resd 1

enemyHealth resd 1
enemyDamage resd 1
defending resd 1
battleResult resd 1
gameResult resd 1
choice resd 1

section .text
global _start

_start:
    call display_welcome
    call get_player_info

main_loop:
    cmp dword [health], 0
    jle player_lost

    cmp dword [gameResult], 1
    je player_won

    call display_main_menu
    call read_number

    cmp eax, 1
    je explore_option
    cmp eax, 2
    je status_option
    cmp eax, 3
    je potion_option
    cmp eax, 4
    je inventory_option
    cmp eax, 5
    je exit_program

    call invalid_input
    jmp main_loop

explore_option:
    call explore_dungeon
    jmp main_loop

status_option:
    call display_status
    jmp main_loop

potion_option:
    call use_potion
    jmp main_loop

inventory_option:
    call display_inventory
    jmp main_loop

player_lost:
    mov dword [gameResult], 2
    call display_game_result
    jmp exit_program

player_won:
    call display_game_result
    jmp exit_program

; ----------------------------------
; WELCOME SCREEN
; ----------------------------------

display_welcome:
    PRINT welcome, welcomeLen
    ret

; ----------------------------------
; PLAYER REGISTRATION
; ----------------------------------

get_player_info:
    PRINT namePrompt, namePromptLen

    mov eax, 3
    mov ebx, 0
    mov ecx, heroName
    mov edx, 32
    int 0x80

    cmp eax, 0
    jle exit_program

    mov esi, eax
    xor edi, edi

find_name_end:
    cmp edi, esi
    jge name_done

    cmp byte [heroName+edi], 10
    je name_done

    inc edi
    jmp find_name_end

name_done:
    mov [nameLength], edi

choose_class:
    PRINT classMenu, classMenuLen
    call read_number

    cmp eax, 1
    jl invalid_class
    cmp eax, 3
    jg invalid_class

    mov [playerClass], eax
    call initialize_character

    PRINT helloMsg, helloLen

    cmp dword [playerClass], 1
    je welcome_warrior
    cmp dword [playerClass], 2
    je welcome_mage

    PRINT archer, archerLen
    jmp welcome_name

welcome_warrior:
    PRINT warrior, warriorLen
    jmp welcome_name

welcome_mage:
    PRINT mage, mageLen

welcome_name:
    PRINT space, 1

    mov eax, 4
    mov ebx, 1
    mov ecx, heroName
    mov edx, [nameLength]
    int 0x80

    PRINT newline, 1
    ret

invalid_class:
    call invalid_input
    jmp choose_class

; ----------------------------------
; CHARACTER INITIALIZATION
; ----------------------------------

initialize_character:
    mov dword [gold], 0
    mov dword [room], 1
    mov dword [gameResult], 0

    cmp dword [playerClass], 1
    je init_warrior

    cmp dword [playerClass], 2
    je init_mage

init_archer:
    mov dword [health], 85
    mov dword [maxHealth], 85
    mov dword [attack], 25
    mov dword [potions], 2
    ret

init_warrior:
    mov dword [health], 100
    mov dword [maxHealth], 100
    mov dword [attack], 20
    mov dword [potions], 2
    ret

init_mage:
    mov dword [health], 70
    mov dword [maxHealth], 70
    mov dword [attack], 30
    mov dword [potions], 3
    ret

; ----------------------------------
; MAIN MENU
; ----------------------------------

display_main_menu:
    PRINT mainMenu, mainMenuLen
    ret

; ----------------------------------
; EXPLORE DUNGEON
; ----------------------------------

explore_dungeon:
    cmp dword [room], 1
    je goblin_room

    cmp dword [room], 2
    je treasure_room

    cmp dword [room], 3
    je dragon_room

    ret

goblin_room:
    PRINT goblinArt, goblinArtLen

    mov dword [enemyHealth], 30
    mov dword [enemyDamage], 10

    call battle_enemy

    cmp dword [battleResult], 1
    jne explore_done

    mov dword [room], 2
    jmp explore_done

treasure_room:
    PRINT chestArt, chestArtLen

    call read_number

    cmp eax, 1
    je open_chest

    cmp eax, 2
    je leave_chest

    call invalid_input
    jmp treasure_room

open_chest:
    add dword [gold], 50
    PRINT chestOpen, chestOpenLen
    mov dword [room], 3
    jmp explore_done

leave_chest:
    PRINT chestLeave, chestLeaveLen
    mov dword [room], 3
    jmp explore_done

dragon_room:
    PRINT dragonArt, dragonArtLen

    mov dword [enemyHealth], 60
    mov dword [enemyDamage], 15

    call battle_enemy

    cmp dword [battleResult], 1
    jne explore_done

    mov dword [gameResult], 1
    mov dword [room], 4

explore_done:
    ret

; ----------------------------------
; BATTLE SYSTEM
; ----------------------------------

battle_enemy:
    mov dword [battleResult], 0
    mov dword [defending], 0

battle_loop:
    cmp dword [health], 0
    jle battle_lost

    cmp dword [enemyHealth], 0
    jle battle_won

    PRINT enemyHealthMsg, enemyHealthLen
    mov eax, [enemyHealth]
    call print_number
    PRINT newline, 1

    PRINT healthMsg, healthLen
    mov eax, [health]
    call print_number
    PRINT newline, 1

    PRINT combatMenu, combatMenuLen
    call read_number

    cmp eax, 1
    je battle_attack

    cmp eax, 2
    je battle_defend

    cmp eax, 3
    je battle_potion

    cmp eax, 4
    je battle_run

    call invalid_input
    jmp battle_loop

battle_attack:
    PRINT attackText, attackTextLen

    mov eax, [attack]
    sub dword [enemyHealth], eax

    cmp dword [enemyHealth], 0
    jle battle_won

    call enemy_turn
    jmp battle_loop

battle_defend:
    PRINT defendText, defendTextLen
    mov dword [defending], 1

    call enemy_turn
    jmp battle_loop

battle_potion:
    call use_potion
    jmp battle_loop

battle_run:
    PRINT runMsg, runLen
    mov dword [battleResult], 0
    ret

; ----------------------------------
; ENEMY ATTACK
; ----------------------------------

enemy_turn:
    PRINT enemyText, enemyTextLen

    mov eax, [enemyDamage]

    cmp dword [defending], 1
    jne normal_damage

    sub eax, 5

    cmp eax, 0
    jge normal_damage

    xor eax, eax

normal_damage:
    sub dword [health], eax
    mov dword [defending], 0

    cmp dword [health], 0
    jg enemy_turn_done

    mov dword [health], 0

enemy_turn_done:
    ret

battle_won:
    PRINT enemyDead, enemyDeadLen
    mov dword [enemyHealth], 0
    mov dword [battleResult], 1
    ret

battle_lost:
    mov dword [health], 0
    mov dword [battleResult], 2
    ret

; ----------------------------------
; HEALTH POTION
; ----------------------------------

use_potion:
    cmp dword [potions], 0
    jle potion_empty

    dec dword [potions]
    add dword [health], 20

    mov eax, [maxHealth]

    cmp dword [health], eax
    jle potion_finished

    mov [health], eax

potion_finished:
    PRINT potionUsed, potionUsedLen
    ret

potion_empty:
    PRINT noPotion, noPotionLen
    ret

; ----------------------------------
; CHARACTER STATUS
; ----------------------------------

display_status:
    PRINT statusTitle, statusTitleLen

    PRINT healthMsg, healthLen
    mov eax, [health]
    call print_number
    PRINT newline, 1

    PRINT attackMsg, attackLen
    mov eax, [attack]
    call print_number
    PRINT newline, 1

    PRINT potionMsg, potionLen
    mov eax, [potions]
    call print_number
    PRINT newline, 1

    PRINT roomMsg, roomLen
    mov eax, [room]
    call print_number
    PRINT newline, 1

    ret

; ----------------------------------
; INVENTORY
; ----------------------------------

display_inventory:
    PRINT inventoryTitle, inventoryTitleLen

    PRINT goldMsg, goldLen
    mov eax, [gold]
    call print_number
    PRINT newline, 1

    PRINT potionMsg, potionLen
    mov eax, [potions]
    call print_number
    PRINT newline, 1

    ret

; ----------------------------------
; GAME RESULT
; ----------------------------------

display_game_result:
    cmp dword [gameResult], 1
    je show_victory

    PRINT gameOverMsg, gameOverLen
    ret

show_victory:
    PRINT victoryMsg, victoryLen

    mov eax, 4
    mov ebx, 1
    mov ecx, heroName
    mov edx, [nameLength]
    int 0x80

    PRINT newline, 1
    PRINT victoryEnd, victoryEndLen

    PRINT goldMsg, goldLen
    mov eax, [gold]
    call print_number
    PRINT newline, 1

    PRINT healthMsg, healthLen
    mov eax, [health]
    call print_number
    PRINT newline, 1

    ret

; ----------------------------------
; INPUT READER
; Returns valid number in EAX
; Returns -1 for invalid input
; ----------------------------------

read_number:
    mov eax, 3
    mov ebx, 0
    mov ecx, input
    mov edx, 64
    int 0x80

    cmp eax, 0
    jle exit_program

    mov esi, eax
    xor edi, edi
    xor eax, eax
    xor ebx, ebx

parse_input:
    cmp edi, esi
    jge parse_done

    mov bl, [input+edi]

    cmp bl, 10
    je parse_done

    cmp bl, '0'
    jl bad_number

    cmp bl, '9'
    jg bad_number

    sub bl, '0'

    imul eax, eax, 10
    jo bad_number

    movzx edx, bl
    add eax, edx
    jc bad_number

    inc edi
    jmp parse_input

parse_done:
    cmp edi, 0
    je bad_number
    ret

bad_number:
    mov eax, -1
    ret

; ----------------------------------
; PRINT POSITIVE INTEGER
; Input: EAX
; ----------------------------------

print_number:
    pushad

    mov edi, numberBuffer+15
    mov byte [edi], 0

    mov ebx, 10

convert_loop:
    xor edx, edx
    div ebx

    add dl, '0'
    dec edi
    mov [edi], dl

    cmp eax, 0
    jne convert_loop

    mov ecx, edi
    mov edx, numberBuffer+15
    sub edx, edi

    mov eax, 4
    mov ebx, 1
    int 0x80

    popad
    ret

; ----------------------------------
; INVALID INPUT
; ----------------------------------

invalid_input:
    PRINT invalidMsg, invalidLen
    ret

; ----------------------------------
; EXIT PROGRAM
; ----------------------------------

exit_program:
    PRINT exitMsg, exitLen

    mov eax, 1
    xor ebx, ebx
    int 0x80