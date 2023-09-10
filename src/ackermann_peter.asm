format ELF64

extrn printf

public main

SYS_EXIT equ 60


section '.rodata'
    _format db "%ld (%lu)", 0xA, 0


section '.text' executable
    main:
        push    rbp
        mov     rbp, rsp

        xor     rdx, rdx

        mov     rdi, 3
        mov     rsi, 10
        call    ackermann_peter

        mov     rsi, rax
        mov     rdi, _format
        xor     eax, eax
        call    printf

        mov     rsp, rbp
        pop     rbp
        ret


    ackermann_peter:
        inc     rdx

        test    rdi, rdi
        jnz     _else_0

        mov     rax, rsi
        inc     rax

        ret

    _else_0:
        test    rsi, rsi
        jnz     _else_1

        dec     rdi
        mov     rsi, 1
        jmp     ackermann_peter

    _else_1:
        push    rdi

        dec     rsi
        call    ackermann_peter

        mov     rsi, rax
        pop     rdi
        dec     rdi

        jmp     ackermann_peter
