format ELF64

public main

extrn printf

OK       equ 0
ERROR    equ 1

EXIT     equ 60

HEAP_CAP equ 512

section '.rodata'
    FMT db 0xA, "rsp - rbp  : %ld", 0xA, "stack[-4:] : [ %ld, %ld, %ld, %ld ]", 0xA, 0

section '.bss' writeable
    HEAP_BUFFER rq HEAP_CAP

    PREV_RSP    rq 1
    PREV_RBP    rq 1

section '.text' executable

macro PRINT_STACK {
    mov     rdi, FMT

    mov     rsi, rsp
    sub     rsi, rbp

    mov     rdx, [rsp + (8 * 3)]
    mov     rcx, [rsp + (8 * 2)]
    mov     r8, [rsp + 8]
    mov     r9, [rsp]

    xor     eax, eax
    call    printf
}

main:
    mov     rbp, rsp

    push    5
    push    6

    sub     rsp, 8 * 3

    mov     qword [rsp + (8 * 2)], 7
    mov     qword [rsp + 8], 8

    add     rsp, 8

    mov     qword [PREV_RSP], rsp
    mov     qword [PREV_RBP], rbp

    ;;

    lea     rsp, [HEAP_BUFFER + (HEAP_CAP * 8)]
    mov     rbp, rsp

    sub     rsp, 16

    mov     qword [rsp + 8], 0
    mov     qword [rsp], 1

    push    2

    push    -1
    add     rsp, 8

    push    3
    push    4

    PRINT_STACK

    ;;

    mov     rsp, qword [PREV_RSP]
    mov     rbp, qword [PREV_RBP]

    PRINT_STACK

    ;;

    mov     edi, OK
    mov     eax, EXIT
    syscall
