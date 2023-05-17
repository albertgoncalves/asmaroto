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

_string db 72, 101, 108, 108, 111, 44, 32, 119, 111, 114, 108, 100, 33, 0
_format db "[pid: %d]", 0xA, "%s", 0xA, 0
