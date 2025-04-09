format ELF64

public _start

extrn _exit

extrn printf

section '.rodata'
    format_i64 db "%ld (%zu)", 10, 0

section '.text' executable
    _start:
        push    rbp
        mov     rbp, rsp

        xor     rcx, rcx

        mov     rdx, 10
        mov     rsi, 3
        mov     rdi, print
        call    ackermann_peter_cps

        xor     edi, edi
        call    _exit

    print:
        mov     rdx, rcx
        mov     rsi, rdi
        mov     rdi, format_i64
        xor     eax, eax
        call    printf

        mov     rsp, rbp
        pop     rbp

        ret

    ; ackermann_peter(return, m, n)
    ackermann_peter_cps_inner:
        mov     rdx, rdi                        ; n = ...
        pop     rdi                             ; pop(return)
        pop     rsi                             ; pop(m)

        dec     rsi                             ;
        ; jmp     ackermann_peter_cps           ; ackermann_peter(return, m - 1, n)

    ackermann_peter_cps:
        inc     rcx                             ; ++counter

    __if_m_eq_0:
        test    rsi, rsi                        ; m == 0
        jnz     __if_n_eq_0

        inc     rdx                             ;
        mov     rax, rdi                        ;
        mov     rdi, rdx                        ;
        jmp     rax                             ; return(n + 1)

    __if_n_eq_0:
        test    rdx, rdx                        ; n == 0
        jnz     __else

        mov     rdx, 1                          ;
        dec     rsi                             ;
        jmp     ackermann_peter_cps             ; ackermann_peter(return, m - 1, 1)

    __else:
        push    rsi                             ; push(m)
        push    rdi                             ; push(return)

        dec     rdx                             ;
        mov     rdi, ackermann_peter_cps_inner  ;
        jmp     ackermann_peter_cps             ; ackermann_peter(..., m, n - 1)
