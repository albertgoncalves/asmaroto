format ELF64

public main

extrn getpid
extrn printf

N equ 456789

section '.data' writeable

STR_FMT  db "%d is %s", 0xA, 0
STR_EVEN db "even", 0
STR_ODD  db "odd", 0

section '.text' executable

main:
        push    rbp

        mov     rdi,    N
        call    is_even

        cmp     rax,    0
        je      eq_0
        mov     rdx,    STR_EVEN
        jmp     ne_0
    eq_0:
        mov     rdx,    STR_ODD
    ne_0:
        mov     rdi,    STR_FMT
        mov     rsi,    N
        xor     rax,    rax
        call    printf

        pop     rbp
        ret

is_even:
        push    rbp
    is_even_tco:
        cmp     rdi,    0
        je      is_even_zero
        sub     rdi,    1
        jmp     is_odd_tco
    is_even_zero:
        mov     rax,    1
        pop     rbp
        ret

is_odd:
        push    rbp
    is_odd_tco:
        cmp     rdi,    0
        je      is_odd_zero
        sub     rdi,    1
        jmp     is_even_tco
    is_odd_zero:
        mov     rax,    0
        pop     rbp
        ret
