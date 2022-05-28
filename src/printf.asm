format ELF64

section '.text' executable

public main

extrn getpid
extrn printf

main:
    push    rbp

    call    getpid
    mov     rsi,    rax

    mov     rdi,    _format
    mov     rdx,    _string
    xor     eax,    eax
    call    printf

    pop     rbp
    ret

section '.data' writeable

_format db "[pid: %d]", 0xA, "%s", 0xA, 0
_string db "Hello, world!"
