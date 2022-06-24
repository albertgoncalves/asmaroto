format ELF64

extrn printf
extrn MSG1

public f

section '.text' executable

f:
        mov     rdi, MSG1
        xor     eax, eax
        call    printf

        ret
