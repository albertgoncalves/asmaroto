format ELF64

public _start

extrn _exit

extrn printf


section '.rodata'
    format_i64 db "%ld (%zu)", 0xA, 0


section '.text' executable
    _start:
        push    rbp
        mov     rbp, rsp

        xor     rdx, rdx

        mov     rsi, 10
        mov     rdi, 3
        call    ackermann_peter

        mov     rsi, rax
        mov     rdi, format_i64
        xor     eax, eax
        call    printf

        xor     edi, edi
        call    _exit

    ackermann_peter:
        inc     rdx

    __if_m_eq_0:
        test    rdi, rdi
        jnz     __if_n_eq_0
        mov     rax, rsi
        inc     rax
        ret
    __if_n_eq_0:
        test    rsi, rsi
        jnz     __else
        dec     rdi
        mov     rsi, 1
        jmp     ackermann_peter
    __else:
        push    rdi
        dec     rsi
        call    ackermann_peter
        mov     rsi, rax
        pop     rdi
        dec     rdi
        jmp     ackermann_peter
