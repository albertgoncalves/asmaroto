format ELF64

extrn printf

public main

SYS_EXIT equ 60


section '.rodata'
    _format db "%ld", 0xA, 0


section '.data' writeable
    x dq 0


; #include <stdint.h>
; #include <stdio.h>
;
; static void f(int64_t* x) {
;     while (*x < 1000) {
;         if ((*x & 1) == 0) {
;             *x += 29;
;         } else {
;             *x += -3;
;         }
;     }
; }
;
; int32_t main(void) {
;     int64_t x = 0;
;     f(&x);
;     printf("%ld\n", x);
;     return 0;
; }


section '.text' executable
    main:
        mov     rdi, x
        call    f

        mov     rsi, qword [x]
        mov     rdi, _format
        xor     eax, eax
        call    printf

        ret

    f:
    _while_start:
        cmp     qword [rdi], 1000
        jge     _while_end

        mov     r8, qword [rdi]
        and     r8, 1
        test    r8, r8
        jnz     _if_else

        add     qword [rdi], 29
        jmp     _if_end

    _if_else:
        add     qword [rdi], -3

    _if_end:
        jmp     _while_start

    _while_end:
        ret
