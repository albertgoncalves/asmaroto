format ELF64

public main

extrn free
extrn malloc
extrn printf

OK       equ 0
ERROR    equ 1

EXIT     equ 60

HEAP_CAP equ (512 * 8)

section '.rodata'
    FMT           db 0xA, "%s", 0xA
    _FMT0         db "  rsp - rbp  : %ld", 0xA
    _FMT1         db "  stack[-4:] : [ %ld, %ld, %ld, %ld ]", 0xA, 0

    STACK_DEFAULT db "default", 0
    STACK_BSS     db "bss", 0
    STACK_MALLOC  db "malloc", 0

section '.bss' writeable
    HEAP_BUFFER rb HEAP_CAP

    PREV_RSP    rq 1
    PREV_RBP    rq 1

section '.text' executable

macro PRINT_STACK string {
    mov     rdi, FMT

    mov     rsi, string

    mov     rdx, rsp
    sub     rdx, rbp

    mov     rcx, [rsp + (8 * 3)]
    mov     r8, [rsp + (8 * 2)]
    mov     r9, [rsp + 8]

    mov     rax, [rsp]
    push    rax

    xor     eax, eax
    call    printf

    add     rsp, 8
}

main:
    mov     rbp, rsp

    push    9
    push    10

    sub     rsp, 8 * 3

    mov     qword [rsp + (8 * 2)], 11
    mov     qword [rsp + 8], 12

    add     rsp, 8

    mov     qword [PREV_RSP], rsp
    mov     qword [PREV_RBP], rbp

    ;;

    lea     rsp, [HEAP_BUFFER + HEAP_CAP]
    mov     rbp, rsp

    sub     rsp, 16

    mov     qword [rsp + 8], 0
    mov     qword [rsp], 1

    push    2

    push    -1
    add     rsp, 8

    push    3
    push    4

    PRINT_STACK STACK_BSS

    ;;

    mov     rdi, HEAP_CAP
    call    malloc

    test    rax, rax
    jz      error

    lea     rsp, [rax + HEAP_CAP]
    mov     rbp, rsp

    push    rax

    push    5
    push    6
    push    7
    push    8

    PRINT_STACK STACK_MALLOC

    add     rsp, 8 * 4

    pop     rdi
    call    free

    ;;

    mov     rsp, qword [PREV_RSP]
    mov     rbp, qword [PREV_RBP]

    PRINT_STACK STACK_DEFAULT

    ;;

    mov     edi, OK
    mov     eax, EXIT
    syscall

error:
    mov     edi, ERROR
    mov     eax, EXIT
    syscall
