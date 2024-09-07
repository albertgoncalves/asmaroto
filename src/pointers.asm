format ELF64

public _start

extrn _exit
extrn free
extrn malloc
extrn printf

section '.rodata'
    string        db "Hi!", 0
    decimal       dq 2189640
    format_i64    db "%ld", 10, 0
    format_string db "%s",  10, 0

section '.text' executable
    _start:
        push    rbp
        mov     rbp, rsp

        ;;

        mov     rdi, 8 * 2
        call    malloc
        push    rax                     ; [..., p0]

        mov     rdi, 8 * 3
        call    malloc
        push    rax                     ; [..., p0, p1]

        mov     rax, [rsp + 8]          ; rax = p0
        mov     rcx, [rsp]              ; rcx = p1

        mov     [rax + 8], rcx          ; p0[1] = p1

        mov     rax, -123
        mov     [rcx + (8 * 2)], rax    ; p1[2] = -123

        mov     rax, [rsp + 8]          ; rax = p0
        mov     rax, [rax + 8]          ; rax = rax[1]
        mov     rax, [rax + (8 * 2)]    ; rax = rax[2]

        mov     rsi, rax
        mov     rdi, format_i64
        xor     eax, eax
        call    printf

        mov     rdi, [rsp]
        call    free

        mov     rdi, [rsp + 8]
        call    free

        ;;

        mov     rsi, string
        mov     rdi, format_string
        xor     eax, eax
        call    printf

        ;;

        mov     rsi, decimal
        mov     rdi, format_string
        xor     eax, eax
        call    printf

        ;;

        push    2189640

        mov     rsi, rsp
        mov     rdi, format_string
        xor     eax, eax
        call    printf

        ;;

        mov     rdi, 8
        call    malloc
        push    rax
        mov     rcx, 2189640
        mov     [rax], rcx

        mov     rsi, rax
        mov     rdi, format_string
        xor     eax, eax
        call    printf

        mov     rdi, [rsp]
        call    free

        ;;

        mov     rsp, rbp
        pop     rbp

        xor     edi,    edi
        call    _exit
