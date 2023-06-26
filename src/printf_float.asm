format ELF64

extrn printf

public main

SYS_EXIT equ 60


section '.rodata'
    _format db "%d, %.1f, %.1f", 0xA, 0


section '.data'
    X dd -123
    Y dd 0xC2F60000
    Z dq 0xC05EC00000000000


section '.text' executable
    main:
        push        rbp
        mov         rbp,    rsp

        and         rsp,    -16

        movsd       xmm1,   QWORD [Z]

        movss       xmm0,   DWORD [Y]
        cvtss2sd    xmm0,   xmm0

        mov         esi,    DWORD [X]

        mov         rdi,    _format
        mov         al,     2
        call        printf

        mov         rsp,    rbp
        pop         rbp
        ret
