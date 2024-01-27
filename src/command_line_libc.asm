format ELF64

public main

extrn printf

section '.rodata'
    _format db "%s", 0xA, 0

section '.text' executable
    main:
        push    rbp
        mov     rbp, rsp

        mov     rsi, [rsi + (rdi * 8) - 8]
        mov     rdi, _format
        xor     eax, eax
        call    printf

        xor     eax, eax

        mov     rsp, rbp
        pop     rbp
        ret
