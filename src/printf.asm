format ELF64

section '.text' executable

public main

extrn getpid
extrn printf

SYS_EXIT equ 60

main:
    call    getpid
    mov     rsi,    rax

    mov     rdi,    _format
    mov     rdx,    _string
    xor     eax,    eax
    call    printf

    xor     edi,    edi
    mov     eax,    SYS_EXIT
    syscall

section '.rodata'

_format db "[pid: %d]", 0xA, "%s", 0xA, 0
_string db "Hello, world!"
