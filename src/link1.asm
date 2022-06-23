format ELF64

extrn printf

public f

section '.rodata'
    MSG db "Printed from linked file!", 0xA, 0

section '.text' executable

f:
        mov     rdi, MSG
        xor     eax, eax
        call    printf

        ret
