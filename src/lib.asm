format ELF64

section '.text' executable

public _start

extrn printf
extrn c_func

SYS_EXIT equ 60

FMT db "This value was computed in `.c`: %d", 0xA, 0

_start:
    mov     edi, -456
    call    c_func

    mov     rdi, FMT
    mov     esi, eax
    xor     rax, rax
    call    printf

    xor     edi,    edi         ; exit code 0
    mov     eax,    SYS_EXIT
    syscall
