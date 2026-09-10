; Everything that comes after a semicolon (;) is a comment

; Define the constants 'RED', 'GREEN' and 'BLUE'
; They must be accessible from other source files

; Define the variable 'base_color' with the default value of 0xFFFFFF00
; It must be accessible from other source files

default rel

section .rodata
    global RED
    global GREEN
    global BLUE
    RED   dd 0xFF000000
    GREEN dd 0x00FF0000
    BLUE  dd 0x0000FF00

section .data
    global base_color
    base_color dd 0xFFFFFF00


section .text
; You should implement functions in the .text section

; these are done at file scope, not within functions.
extern combining_function

; the global directive makes a function visible to the test files
global get_color_value
get_color_value:
    ; This function takes the address for a color as parameter
    ; It must return the 32-bit value associated with the color

    mov eax, dword [rdi]   ; load 32-bit value into eax, you can't use lea for this because you are actually writing to the address stored as data in rdi.
                           ; also, you can't use memory prefixes in a lea instuction.

    ret

global add_base_color
add_base_color:
    ; TODO: define the 'add_base_color' function
    ; This function takes the address for a color as parameter
    ; It saves the 32-bit value associated with this color in the variable 'base_color'
    ; This variable must be accessible from other source files
    ; This function has no return value

    mov eax, dword[rdi]
    mov dword [base_color], eax

    ret

global make_color_combination
make_color_combination:
    ; TODO: define the 'make_color_combination' function
    ; This function takes the following parameters:
    ; - The address where the 32-bit value for the combined color should be stored.
    ; - The address of a secondary color in the color table. <--- rsi value
    ; It should call 'combining_function' with the 32-bit value for base and secondary colors and store the result in the passed address
    ; This function has no return value

    push rdi              ; save destination pointer <--- this "pushes" data off the stack, so the stack is aligned in 16bit registers and doesn't seg fault.

    mov eax, dword[base_color]     ; eax = base color value
    mov esi, dword[rsi]            ; esi = secondary color value
    mov edi, eax              ; edi = first argument (base color)

    call combining_function   ; rax = result

    pop rdi                ; restore destination pointer <--- this just "pops" the pushed data back onto the stack
    mov [rdi], eax            ; store result into destination

    ret

%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif
