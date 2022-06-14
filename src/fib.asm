format ELF64

public _start

extrn printf

SYS_EXIT equ 60

section '.data' writeable

FMT db "%ld", 0xA, 0

section '.text' executable

fib:
        mov     rcx, 0      ; a
        mov     rdx, 1      ; b
    fib_loop:
        mov     rax, rcx    ; c = a

        test    rdi, rdi
        jz      fib_ret

        add     rax, rdx    ; c = a + b
        mov     rcx, rdx    ; a = b
        mov     rdx, rax    ; b = c

        dec     rdi

        jmp     fib_loop
        ; call    fib_loop
        ; ret

    fib_ret:
        ret                 ; return c

_start:
        mov     rdi, 50
        call    fib

        mov     rdi, FMT
        mov     rsi, rax
        xor     eax, eax
        call    printf

        xor     edi, edi
        mov     eax, SYS_EXIT
        syscall
