WEIGHT_OF_EMPTY_BOX equ 500
TRUCK_HEIGHT equ 300
PAY_PER_BOX equ 5
PAY_PER_TRUCK_TRIP equ 220

section .text

global get_box_weight
get_box_weight:
    ; This function takes the following parameters:
    ; - The number of items for the first product in the box, as a 16-bit non-negative integer
    ; - The weight of each item of the first product, in grams, as a 16-bit non-negative integer
    ; - The number of items for the second product in the box, as a 16-bit non-negative integer
    ; - The weight of each item of the second product, in grams, as a 16-bit non-negative integer
    ; The function must return the total weight of a box, in grams, as a 32-bit non-negative integer

    mov ax, di
    mov r8w, dx ; saves dx so it's not overwritten by the first mul
    mul si ; result: dx:ax / full 32-bit product

    movzx edx, dx ; edx contains dx as its lower half, so to clear the garbage that might be in its upper half you move the register into the 16-bit one, essentially this line makes edx=0000_dx

    shl edx, 16 ; shift left, makes edx= dx_0000
    movzx eax, ax ; same concept, moving ax's value into eax, making eax=0000_ax
    or eax, edx ; or compares the bits, so it'll combine the two together since edx=dx_0000 and eax=0000_ax, so the 0's will be or-ed with the actual data

    mov r10d, eax ; need to move to prevent lower bits from getting clobbered by mul in next step

    mov ax, r8w
    mul cx ; dx:ax = count2 * weight2

    movzx edx, dx
    shl edx, 16
    movzx esi, ax
    or esi, edx ; this will then hold whole product like earlier

    mov eax, r10d ; move product1 back into eax to add correct

    add eax, esi
    add eax, WEIGHT_OF_EMPTY_BOX ; add everything together to return eax

    ret

global max_number_of_boxes
max_number_of_boxes:
    ; TODO: define the 'max_number_of_boxes' function
    ; This function takes the following parameter:
    ; - The height of the box, in centimeters, as a 8-bit non-negative integer
    ; The function must return how many boxes can be stacked vertically, as a 8-bit non-negative integer

    mov ax, TRUCK_HEIGHT ; load truck height into AX
    div dil ; I was wrong, it divides by ax which in my previous was uninit. dil is taken parameter, leading to the correct formula of AX / DIL, AL = result

    ret

global items_to_be_moved
items_to_be_moved:
    ; TODO: define the 'items_to_be_moved' function
    ; This function takes the following parameters:
    ; - The number of items still unaccounted for a product, as a 32-bit non-negative integer
    ; - The number of items for the product in a box, as a 32-bit non-negative integer
    ; The function must return how many items remain to be moved, after counting those in the box, as a 32-bit integer

    sub edi, esi ; edi = edi - esi
    mov eax, edi ; eax = edi

    ret

global calculate_payment
calculate_payment:
    ; TODO: define the 'calculate_payment' function
    ; This function takes the following parameters:
    ; - The upfront payment, as a 64-bit non-negative integer (rdi) /done
    ; - The total number of boxes moved, as a 32-bit non-negative integer (esi) /done
    ; - The number of truck trips made, as a 32-bit non-negative integer (edx) /done
    ; - The number of lost items, as a 32-bit non-negative integer (ecx) /done
    ; - The value of each lost item, as a 64-bit non-negative integer (r8) /used
    ; - The number of other workers to split the payment/debt with you, as a 8-bit positive integer (r9b)
    ; The function must return how much you should be paid, or pay, at the end, as a 64-bit integer (possibly negative)
    ; Remember that you get your share and also the remainder of the division

    mov r11d, edx ; needs to be moved to save the data (truck trips) from clobber by mul
    mov eax, esi
    mov r10d, PAY_PER_BOX
    mul r10d ; edx:eax = boxes * PAY_PER_BOX

    mov r12d, eax ; move into 32-bit to auto 0 out upper register, as well as save it from clobber by next multiplication, r12 is box-earnings

    mov eax, r11d ; truck trips
    mov r10d, PAY_PER_TRUCK_TRIP
    mul r10d ; edx:eax = trip-earnings

    mov r13d, eax ; trip-earnings preserved

    add r12, r13 ; box + trip
    sub r12, rdi ; total (box + trip) + upfront

    mov eax, ecx ; number of lost items
    mul r8 ; rdx*eax(rax)

    sub r12, rax ; sub is dest - source; total - lost

    movzx r14d, r9b ; move number of workers into r14d

    add r14d, 1 ; add yourself

    mov rax, r12 ; dividend into rax to divide, r12 is net total right now
    cqo ; zero out rdx before the divide to get rid of garbage CQO BECAUSE IT'S SIGNED
    idiv r14 ; rax quotient:rdx remainder IDIV BECAUSE IT'S SIGNED

    add rax, rdx

    ret

%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif
