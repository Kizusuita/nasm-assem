C2 equ 2
C3 equ 3
C4 equ 4
C5 equ 5
C6 equ 6
C7 equ 7
C8 equ 8
C9 equ 9
C10 equ 10
CJ equ 11
CQ equ 12
CK equ 13
CA equ 14

TRUE equ 1
FALSE equ 0

section .text

; You should implement functions in the .text section

; the global directive makes a function visible to the test files
global value_of_card
value_of_card:
    ; This function takes as parameter a number representing a card
    ; The function should return the numerical value of the passed-in card

    cmp dil, 14 ; check if ace
    je .ace

    cmp dil, 11 ; check if number card
    jl .number_card

    ; if face card (not number or ace)
    mov eax, 10
    ret

    .ace:
    mov eax, 1
    ret

    .number_card:
    movzx eax, dil ; movzx to 0 out upper reg correctly
    ret

global higher_card
higher_card:
    ; This function takes as parameters two numbers each representing a card
    ; The function should return which card has the higher value
    ; If both have the same value, both should be returned
    ; If one is higher, the second one should be 0


    mov r8d, edi ; save original value of card1 to return later

    call value_of_card ; card1 held in rdi, eax = value_card1
    mov r9d, eax ; move eax(sil) into r8d to save it from clobber from the next value call

    mov edi, esi ; move card2 into first register to call value
    call value_of_card ; find value card2, stored in eax right now

    cmp r9d, eax ; compare 2 card values
    je .equal ; if equal
    jg .greater ; if a > b

    ; if neither, a < b
    mov eax, esi ; ret second card
    xor edx, edx ; zero out second reg
    ret

    .equal:
    mov eax, r8d ; first card
    mov edx, esi ; second card
    ret

    .greater:
    mov eax, r8d ; ret first card
    xor edx, edx ; zero out second reg
    ret

global value_of_ace
value_of_ace:
    ; This function takes as parameters two numbers each representing a card
    ; The function should return the value of an upcoming ace
     cmp dil, 14
    je .ace_hand ; special ace case, if ace already in hand return     1 immediately

    cmp sil, 14
    je .ace_hand ; same, just checking other number

    call value_of_card
    mov r8d, eax ; preserve value of card1 to compute card2
    mov edi, esi ; move second value into first
    call value_of_card
    ; so eax stores computed value of card2, r8d stores computed value of card1

    add eax, r8d ; eax = eax + r8d
    add eax, 11 ; adds the 11 to see if it would bust the hand

    cmp eax, 21 ; a = eax b = 21, a - b
    jg .bust

    ; Hand total is less than 21 when adding 11
    mov eax, 11
    ret

    .bust:
    mov eax, 1 ; 11 would be too much, so ace = 1
    ret

    .ace_hand:
    mov eax, 1 ; ret 1
    xor edx, edx
    ret

global is_blackjack
is_blackjack:
    ; This function takes as parameters two numbers each representing a card
    ; The function should return TRUE if the two cards form a blackjack, and FALSE otherwise
    cmp dil, 14
    je .ace_in_hand ; check if ace is in hand prior to value

    cmp sil, 14
    je .ace_in_hand ; same, just checking other number

    call value_of_card
    mov r8d, eax
    mov edi, esi
    call value_of_card

    ; again above, calc value of card1 = r8d, calc value of card2 = eax

    add eax, r8d ; if 21 then BJ

    cmp eax, 21
    je .blackjack ; if equal

    ; if not then
    mov eax, 0 ; false
    ret

    .blackjack:
    mov eax, 1 ; true
    ret

    .ace_in_hand:
    call value_of_card
    mov r8d, eax
    mov edi, esi
    call value_of_card

    cmp r8d, 10 ; if king/queen/jack, blackjack
    je .blackjack

    cmp eax, 10 ; check other card
    je .blackjack

    mov eax, 0 ; not king/queen/jack
    ret

global can_split_pairs
can_split_pairs:
    ; This function takes as parameters two numbers each representing a card
    ; The function should return TRUE if the two cards can be split into two pairs, and FALSE otherwise

    call value_of_card
    mov r8d, eax
    mov edi, esi
    call value_of_card
    ; calculating values again

    cmp r8d, eax ; a - b, a = r8d b = eax
    je .split

    ; if not equal
    mov eax, 0 ; can't split
    ret

    .split:
    mov eax, 1 ; can split
    ret

    ret

global can_double_down
can_double_down:
    ; This function takes as parameters two numbers each representing a card
    ; The function should return TRUE if the two cards form a hand that can be doubled down, and FALSE otherwise

    call value_of_card
    mov r8d, eax
    mov edi, esi
    call value_of_card
    ; again values lol
    ; card1 = r8d, card2 = eax

    add eax, r8d ; total of card value in hand

    cmp eax, 11
    jle .less_than_11

    ; if it's greater than 11, then no
    mov eax, 0
    ret

    ;so if it's less than 11 but greater than 9, it has to be 9, 10, 11 and return TRUE
    .less_than_11:
    cmp eax, 9
    jge .g_than_9

    mov eax, 0 ; if not g than 9, ret 0
    ret

    .g_than_9:
    mov eax, 1
    ret


%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif
