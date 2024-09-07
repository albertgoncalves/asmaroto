format ELF64

public _start

extrn printf
extrn _exit

section '.rodata'
    format_string db "%d", 10, 0

section '.text' executable
    _start:
        call    f

        xor     edi,    edi
        call    _exit

    ; function f() {
    ;     var x = 0;
    ;     var y = 0;
    ;
    ;     for (;;) {
    ;         if (x > 10) {
    ;             break;
    ;         }
    ;         y += x;
    ;         x += 1;
    ;     }
    ;
    ;     console.log(y);
    ; }

    f:
        mov     rcx,    0   ; x
        mov     rdx,    0   ; y
        ; jmp     __0__

    __0__:
        cmp     rcx,    10
        jg      __2__
        ; jmp     __1__

    __1__:
        add     rdx,    rcx
        ; add     rcx,    1
        inc     rcx
        jmp     __0__

    __2__:
        push    rdx
        mov     rdi,    format_string
        mov     rsi,    rdx
        xor     eax,    eax
        call    printf
        pop     rdx

        ret
