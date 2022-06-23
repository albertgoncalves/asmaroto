format ELF64

public _start

extrn printf

extrn f

section '.rodata'
    MSG db "Printed from main file!", 0xA, 0

section '.text' executable

_start:
        call    f

        mov     rdi, MSG
        xor     eax, eax
        call    printf

        mov     rdi, 0
        mov     eax, 60
        syscall
