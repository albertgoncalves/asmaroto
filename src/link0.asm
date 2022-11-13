format ELF64

public main
public MSG1

extrn printf

extrn f

section '.rodata'
    MSG0 db "Printed from main file!", 0xA, 0
    MSG1 db "Printed from linked file!", 0xA, 0

section '.text' executable

main:
        call    f

        mov     rdi, MSG0
        xor     eax, eax
        call    printf

        mov     rdi, 0
        mov     eax, 60
        syscall
