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
    OBJECT rq 4

section '.text' executable
    _start:
        push    rbp
        mov     rbp, rsp

        mov     qword [OBJECT], work
        mov     qword [OBJECT + 8], 0
        mov     qword [OBJECT + (8 * 2)], force

        mov     rdi, OBJECT
        mov     rax, [OBJECT + (8 * 2)]
        call    rax

        mov     rdi, OBJECT
        mov     rax, [OBJECT + (8 * 2)]
        call    rax

        mov     rdi, OBJECT
        mov     rax, [OBJECT + (8 * 2)]
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

    ; Lazy {
    ;     func:  (void*) -> void*
    ;     args:  void*,
    ;     force: (Lazy*) -> void*
    ;     value: void*,
    ; }

    force:
        push    rdi

        mov     rax, [rdi]
        mov     rdi, [rdi + 8]
        call    rax

        pop     rdi
        mov     qword [rdi + (8 * 3)], rax
        mov     qword [rdi + (8 * 2)], cache

        ret

    cache:
        push    rdi

        mov     rdi, string_cache
        xor     eax, eax
        call    printf

        pop     rdi

        mov     rax, [rdi + (8 * 3)]
        ret
