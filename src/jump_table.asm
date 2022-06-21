format ELF64

public _start

extrn printf

section '.rodata'
    TABLE   dq t0, t1
    STR_I32 db '%d', 0xA, 0
    STR_T0  db '@t0', 0xA, 0
    STR_T1  db '@t1', 0xA, 0

section '.text' executable

f:
        jmp     [TABLE + (rdi * 8)]

    t0:
        mov     rdi, STR_T0
        xor     eax, eax
        call    printf
        mov     eax, 123
        jmp     f_end
    t1:
        mov     rdi, STR_T1
        xor     eax, eax
        call    printf
        mov     eax, -456
        jmp     f_end

    f_end:
        ret

_start:
        mov     rdi, 0
        ; mov     rdi, 1
        call    f

        mov     rsi, rax
        mov     rdi, STR_I32
        xor     eax, eax
        call    printf

        mov     rdi, rax
        mov     eax, 60
        syscall
