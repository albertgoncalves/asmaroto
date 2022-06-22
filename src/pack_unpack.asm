format ELF64

public _start

extrn printf

OK      equ 0
ERROR   equ 1

BUFFER_CAP equ 48

section '.rodata'
    FMT_I64_2 db "%ld %ld", 0xA, 0
    FMT_I64_3 db "%ld %ld %ld", 0xA, 0
    TABLE     dq unpack_0, unpack_1, unpack_2

section '.bss' writeable
    BUFFER rb BUFFER_CAP

section '.data' writeable
    BUFFER_LEN dq 0

section '.text' executable

pack2:
        mov     rax, BUFFER
        mov     r11, [BUFFER_LEN]
        add     rax, r11

        add     r11, 2 * 8
        cmp     r11, BUFFER_CAP
        ja      pack3_error

        mov     qword [BUFFER + r11 - (8 * 1)], rsi
        mov     qword [BUFFER + r11 - (8 * 2)], rdi
        mov     qword [BUFFER_LEN], r11
        ret

    pack2_error:
        mov     edi, ERROR
        mov     eax, 60
        syscall

pack3:
        mov     rax, BUFFER
        mov     r11, [BUFFER_LEN]
        add     rax, r11

        add     r11, 3 * 8
        cmp     r11, BUFFER_CAP
        ja      pack3_error

        mov     qword [BUFFER + r11 - (8 * 1)], rdx
        mov     qword [BUFFER + r11 - (8 * 2)], rsi
        mov     qword [BUFFER + r11 - (8 * 3)], rdi
        mov     qword [BUFFER_LEN], r11
        ret

    pack3_error:
        mov     edi, ERROR
        mov     eax, 60
        syscall

unpack:
        push    rbp
        mov     rbp, rsp

        push    rdi

        mov     r10, [rbp - 8]
        mov     r10, [r10]
        jmp     [TABLE + (r10 * 8)]

    unpack_0:
        push    qword [rdi + (8 * 0)]
        push    qword [rdi + (8 * 1)]

        mov     rsi, [rbp - (8 * 2)]
        mov     rdx, [rbp - (8 * 3)]
        mov     rdi, FMT_I64_2
        xor     eax, eax
        call    printf

        jmp     unpack_end

    unpack_1:
        mov     edi, ERROR
        mov     eax, 60
        syscall

    unpack_2:
        push    qword [rdi + (8 * 0)]
        push    qword [rdi + (8 * 1)]
        push    qword [rdi + (8 * 2)]

        mov     rsi, [rbp - (8 * 2)]
        mov     rdx, [rbp - (8 * 3)]
        mov     rcx, [rbp - (8 * 4)]
        mov     rdi, FMT_I64_3
        xor     eax, eax
        call    printf
        jmp     unpack_end

    unpack_end:
        leave
        ret

_start:
        mov     rdi, 0
        mov     rsi, -123
        call    pack2

        mov     rdi, rax
        call    unpack

        add     [BUFFER_LEN], 8

        mov     rdi, 2
        mov     rsi, -456
        mov     rdx, 123
        call    pack3

        mov     rdi, rax
        call    unpack

        mov     rdi, OK
        mov     eax, 60
        syscall
