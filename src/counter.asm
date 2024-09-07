format ELF64

public _start

extrn _exit

extrn printf

extrn malloc
extrn free

section '.rodata'
    format_i64 db "%ld", 10, 0

section '.text' executable
    _start:
        push    rbp
        mov     rbp, rsp

        call    __2__

        mov     rsp, rbp
        pop     rbp

        xor     edi, edi
        call    _exit

; var __0__ = (function(__env__) {
;     var k = __env__[1];
;     var n = __env__[0];
;     var m = n[0];
;     n[0] = n[0] + k[0];
;     k[0] = k[0] + 1;
;     return m;
; });

    __0__:                              ; var __0__ = (function(__env__) {
        push    rbp
        mov     rbp, rsp

        push    rdi                     ;   # stack: [..., __env__]

        mov     rax, [rsp]              ; var k = __env__[1];
        mov     rax, [rax + 8]
        push    rax                     ;   # stack: [..., __env__, k]

        mov     rax, [rsp + 8]          ; var n = __env__[0];
        mov     rax, [rax]
        push    rax                     ;   # stack: [..., __env__, k, n]

        mov     rax, [rsp]              ; var m = n[0];
        mov     rax, [rax]
        push    rax                     ;   # stack: [..., __env__, k, n, m]

        mov     rax, [rsp + 8]          ; n[0] = n[0] + k[0];
        mov     rax, [rax]

        mov     rcx, [rsp + (8 * 2)]
        mov     rcx, [rcx]

        add     rax, rcx
        mov     rcx, [rsp + 8]
        mov     [rcx], rax

        mov     rax, [rsp + (8 * 2)]    ; k[0] = k[0] + 1;
        mov     rax, [rax]
        inc     rax
        mov     rcx, [rsp + (8 * 2)]
        mov     [rcx], rax

        mov     rax, [rsp]              ; return m;

        mov     rsp, rbp
        pop     rbp

        ret                             ; })

; var __1__ = (function(k, __env__) {
;     k = [k];
;     var n = [0];
;     return [__0__, [n, k]];
; });

    __1__:                              ; var __1__ = (function(k, __env__) {
        push    rbp
        mov     rbp, rsp

        push    rdi                     ;   # stack: [..., k]

        mov     rdi, 8
        call    malloc
        mov     rcx, [rsp]
        mov     [rax], rcx              ; k = [k];
        mov     [rsp], rax              ;   # stack: [..., [k]]

        mov     rdi, 8
        call    malloc
        mov     rcx, 0
        mov     [rax], rcx              ; var n = [0];
        push    rax                     ;   # stack: [..., [k], n]

        mov     rdi, 8 * 2              ; return [__0__, [n, k]];
        call    malloc

        mov     rcx, [rsp]
        mov     [rax], rcx

        mov     rcx, [rsp + 8]
        mov     [rax + 8], rcx

        mov     [rsp + 8], rax          ;   # stack: [..., [n, [k]], n]
        add     rsp, 8                  ;   # stack: [..., [n, [k]]]

        mov     rdi, 8 * 2              ; return [__0__, [n, k]];
        call    malloc
        mov     rcx, __0__
        mov     [rax], rcx
        mov     rcx, [rsp]
        mov     [rax + 8], rcx

        mov     rsp, rbp
        pop     rbp

        ret                             ; })

; var __2__ = (function(__env__) {
;     var counter = [__1__, []];
;     var instance0 = counter[0](1, counter[1]);
;     var instance1 = counter[0](2, counter[1]);
;     console.log(instance0[0](instance0[1]));
;     console.log(instance1[0](instance1[1]));
;     console.log(instance0[0](instance0[1]));
;     console.log(instance1[0](instance1[1]));
;     console.log(instance0[0](instance0[1]));
;     console.log(instance1[0](instance1[1]));
;     console.log(instance0[0](instance0[1]));
;     console.log(instance1[0](instance1[1]));
; });

    __2__:                              ; var __2__ = (function(__env__) {
        push    rbp
        mov     rbp, rsp

        mov     rdi, 8 * 2              ; var counter = [__1__, []];
        call    malloc
        mov     rcx, __1__
        mov     [rax], rcx
        mov     rcx, 0
        mov     [rax + 8], rcx
        push    rax                     ;   # stack: [..., counter]

        mov     rsi, [rsp]              ; var instance0 = counter[0](1, counter[1]);
        mov     rsi, [rsi + 8]
        mov     rdi, 1
        mov     rax, [rsp]
        mov     rax, [rax]
        call    rax
        push    rax                     ;   # stack: [..., counter, instance0]

        mov     rsi, [rsp + 8]          ; var instance1 = counter[0](2, counter[1]);
        mov     rsi, [rsi + 8]
        mov     rdi, 2
        mov     rax, [rsp + 8]
        mov     rax, [rax]
        call    rax
        push    rax                     ;   # stack: [..., counter, instance0, instance1]

        mov     rdi, [rsp + 8]          ; console.log(instance0[0](instance0[1]));
        mov     rdi, [rdi + 8]
        mov     rax, [rsp]
        mov     rax, [rax]
        call    rax
        mov     rsi, rax
        mov     rdi, format_i64
        xor     eax, eax
        call    printf

        mov     rdi, [rsp]              ; console.log(instance1[0](instance1[1]));
        mov     rdi, [rdi + 8]
        mov     rax, [rsp]
        mov     rax, [rax]
        call    rax
        mov     rsi, rax
        mov     rdi, format_i64
        xor     eax, eax
        call    printf

        mov     rdi, [rsp + 8]          ; console.log(instance0[0](instance0[1]));
        mov     rdi, [rdi + 8]
        mov     rax, [rsp]
        mov     rax, [rax]
        call    rax
        mov     rsi, rax
        mov     rdi, format_i64
        xor     eax, eax
        call    printf

        mov     rdi, [rsp]              ; console.log(instance1[0](instance1[1]));
        mov     rdi, [rdi + 8]
        mov     rax, [rsp]
        mov     rax, [rax]
        call    rax
        mov     rsi, rax
        mov     rdi, format_i64
        xor     eax, eax
        call    printf

        mov     rdi, [rsp + 8]          ; console.log(instance0[0](instance0[1]));
        mov     rdi, [rdi + 8]
        mov     rax, [rsp]
        mov     rax, [rax]
        call    rax
        mov     rsi, rax
        mov     rdi, format_i64
        xor     eax, eax
        call    printf

        mov     rdi, [rsp]              ; console.log(instance1[0](instance1[1]));
        mov     rdi, [rdi + 8]
        mov     rax, [rsp]
        mov     rax, [rax]
        call    rax
        mov     rsi, rax
        mov     rdi, format_i64
        xor     eax, eax
        call    printf

        mov     rdi, [rsp + 8]          ; console.log(instance0[0](instance0[1]));
        mov     rdi, [rdi + 8]
        mov     rax, [rsp]
        mov     rax, [rax]
        call    rax
        mov     rsi, rax
        mov     rdi, format_i64
        xor     eax, eax
        call    printf

        mov     rdi, [rsp]              ; console.log(instance1[0](instance1[1]));
        mov     rdi, [rdi + 8]
        mov     rax, [rsp]
        mov     rax, [rax]
        call    rax
        mov     rsi, rax
        mov     rdi, format_i64
        xor     eax, eax
        call    printf

        mov     rsp, rbp
        pop     rbp

        ret                             ; })
