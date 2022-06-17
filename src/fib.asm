format ELF64

public _start

extrn printf

SYS_EXIT equ 60

section '.data' writeable

FMT db "%ld", 0xA, 0

section '.text' executable

;   u64 fib(u64 n) {
;       return _fib(n, 0, 1);
;   }
fib:
        mov     rsi, 0      ; a
        mov     rdx, 1      ; b
        call    _fib
        ret

;   u64 _fib(u64 n, u64 a, u64 b) {
;       if (n == 0) {
;           return a;
;       }
;       return _fib(n - 1, b, a + b)
;   }
_fib:
        test    rdi, rdi    ; if (n == 0) {
        jz      _fib_ret    ;     return a;
                            ; }
        push    rsi         ; c = a;
        mov     rsi, rdx    ; a = b;

        add     rdx, [rsp]  ; b += c;
        dec     rdi         ; n -= 1;

        add     rsp, 8

        jmp     _fib
        ; call    _fib
        ; ret

    _fib_ret:
        mov     rax, rsi
        ret                 ; return a

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
