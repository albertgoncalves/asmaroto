format ELF64

public _start

extrn _exit

extrn printf

; function one() {
;     return 1;
; }
;
; function add(a, b) {
;     return a + b;
; }
;
; function main() {
;     var a = -2;
;     var b = one();
;     var c = add(a, b);
;     console.log(c);
; }
;
; main();

; function one(k) {
;     k(1);
; }
;
; function add(k, a, b) {
;     k(a + b);
; }
;
; function main(k) {
;     var a = -2;
;     one(function(b) {
;         add(function(c) {
;             console.log(c);
;             k();
;         }, a, b);
;     });
; }
;
; main(function() {});

section '.rodata'
    format_i64 db "%ld", 10, 0

section '.text' executable
    _start:
        mov     rdi, __exit__
        jmp     __main__

    __one__:
        mov     rax, rdi
        mov     rdi, 1
        jmp     rax

    __add__:
        add     rsi, rdx
        mov     rax, rdi
        mov     rdi, rsi
        jmp     rax

    __main__:
        push    rdi
        push    -2

        mov     rdi, __0__
        jmp     __one__
    __0__:
        mov     rdx, rdi
        pop     rsi
        mov     rdi, __1__
        jmp     __add__
    __1__:
        mov     rsi, rdi
        mov     rdi, format_i64
        xor     eax, eax
        call    printf
        pop     rax
        jmp     rax

    __exit__:
        xor     edi, edi
        call    _exit
