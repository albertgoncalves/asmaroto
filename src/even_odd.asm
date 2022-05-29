format ELF64

public main

extrn printf

BUFFER_CAP equ 1024

section '.text' executable

macro PROLOGUE {
        push    rbp     ; ==    sub     rsp,    8
                        ;       mov     [rsp],  rbp
        mov     rbp,    rsp
        sub     rsp,    8           ; 16-byte alignment
}

macro EPILOGUE {
        add     rsp,    8
        mov     rsp,    rbp

        pop     rbp     ; ==    mov     rbp,    [rsp]
                        ;       add     rsp,    8
        ret
}

main:
        PROLOGUE

        sub     rsp,            16
        mov     qword [rsp],    456789

        mov     rdi,            [rsp]
        call    is_even

        cmp     rax,            1
        je      main_if_eq_1

        mov     rdx,            STR_ODD
        jmp     main_if_end
    main_if_eq_1:
        mov     rdx,            STR_EVEN

    main_if_end:
        mov     rdi,            STR_FMT
        mov     rsi,            [rsp]
        xor     rax,            rax
        call    printf

        xor     rax,            rax
        add     rsp,            16
        EPILOGUE

is_even:
        PROLOGUE
    is_even_body:
        cmp     rdi,        0
        je      is_even_ret
        sub     rdi,        1
        jmp     is_odd_body
    is_even_ret:
        mov     rax,        1
        EPILOGUE

is_odd:
        PROLOGUE
    is_odd_body:
        cmp     rdi,        0
        je      is_odd_ret
        sub     rdi,        1
        jmp     is_even_body
    is_odd_ret:
        mov     rax,        0
        EPILOGUE

section '.data' writeable

STR_FMT  db "%d is %s", 0xA, 0
STR_EVEN db "even", 0
STR_ODD  db "odd", 0

section '.bss' writeable

BUFFER rb BUFFER_CAP
