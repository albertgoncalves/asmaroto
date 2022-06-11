format ELF64

public _start

extrn printf

SYS_EXIT equ 60

FMT db "%f", 0xA, "%.4f", 0xA, "%.9f", 0xA, 0
X   dd -0.1234
Y   dd 0.5678
Z   dq 0.987654321

main:
    push        rbp
    mov         rbp, rsp

    mov         rdi, FMT
    push        qword [X]
    push        qword [Y]
    push        [Z]
    and         rsp, -16            ; enforce 16-byte alignment

    ; NOTE: See `https://en.wikibooks.org/wiki/X86_Assembly/SSE`.
    movss       xmm0, [rbp - 8]
    movss       xmm1, [rbp - 16]
    movsd       xmm2, [rbp - 24]
    divss       xmm0, xmm1
    cvtss2sd    xmm0, xmm0          ; `printf` requires `double`!
    cvtss2sd    xmm1, xmm1
    mov         al, 3
    call        printf

    mov         rsp, rbp
    pop         rbp
    ret

_start:
    call        main
    xor         edi, edi
    mov         eax, SYS_EXIT
    syscall
