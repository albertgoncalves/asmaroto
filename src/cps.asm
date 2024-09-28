format ELF64

public _start

extrn _exit

extrn printf

section '.rodata'
    format_i64 db "%ld", 10, 0

section '.text' executable
    _start:
        mov     rdx, 11
        mov     rsi, 3
        mov     rdi, print
        call    ackermann_peter_cps

        xor     edi, edi
        call    _exit

    print:
        mov     rsi, rdi
        mov     rdi, format_i64
        xor     eax, eax
        call    printf
        ret

    ackermann_peter_cps:
    __if_m_eq_0:
        test    rsi, rsi
        jnz     __if_n_eq_0
        inc     rdx
        mov     rax, rdi
        mov     rdi, rdx
        jmp     rax
    __if_n_eq_0:
        test    rdx, rdx
        jnz     __else
        mov     rdx, 1
        dec     rsi
        jmp     ackermann_peter_cps
    __else:
        push    rsi
        push    rdi
        dec     rdx
        mov     rdi, ackermann_peter_cps_inner
        jmp     ackermann_peter_cps

    ackermann_peter_cps_inner:
        mov     rdx, rdi
        pop     rdi
        pop     rsi
        dec     rsi
        jmp     ackermann_peter_cps
