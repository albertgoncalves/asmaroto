format ELF64

public _start

extrn _exit
extrn printf
extrn usleep

section '.rodata'
    string_work  db "!", 10, 0
    string_cache db ".", 10, 0
    string_i64   db "%ld", 10, 0

section '.bss' writeable
    OBJECT rq 3

section '.text' executable
    _start:
        push    rbp
        mov     rbp, rsp

        mov     qword [OBJECT], force
        mov     qword [OBJECT + 8], work
        mov     qword [OBJECT + (8 * 2)], 0

        mov     rdi, OBJECT
        mov     rax, [OBJECT]
        call    rax

        mov     rdi, OBJECT
        mov     rax, [OBJECT]
        call    rax

        mov     rdi, OBJECT
        mov     rax, [OBJECT]
        call    rax

        mov     rsi, rax
        mov     rdi, string_i64
        xor     eax, eax
        call    printf

        xor     edi, edi
        call    _exit

    work:
        mov     rdi, string_work
        xor     eax, eax
        call    printf

        mov     rdi, 500000
        call    usleep

        mov     rax, 123
        ret

    ; typedef struct {
    ;     void* (*force)(void*);
    ;     union {
    ;         void* value;
    ;         void* (*func)(void*);
    ;     } _;
    ;     void* args;
    ; } Lazy;

    force:
        push    rdi

        mov     rax, [rdi + 8]
        mov     rdi, [rdi + (8 * 2)]
        call    rax

        pop     rdi
        mov     qword [rdi], cache
        mov     qword [rdi + 8], rax

        ret

    cache:
        push    rdi

        mov     rdi, string_cache
        xor     eax, eax
        call    printf

        pop     rdi

        mov     rax, [rdi + 8]
        ret
