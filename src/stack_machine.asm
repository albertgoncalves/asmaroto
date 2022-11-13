format ELF64

public main

extrn printf

SYS_EXIT equ 60

OK    equ 0
ERROR equ 1

macro STACK_SYSCALL2 {
        pop     rdi
        pop     rax
        syscall
}

macro STACK_PRINT_STR {
        pop     rdi
        mov     rax, 0
        call    printf
}

macro STACK_PRINTLN_I64 {
        pop     rsi
        mov     rdi, FORMAT_I64
        mov     rax, 0
        call    printf
}

macro STACK_COPY offset {
        mov     rax, [rsp + (offset * 8)]
        push    rax
}

macro STACK_DROP count {
        add     rsp, 8 * count
}

macro STACK_ADD {
        pop     rdx
        pop     rax
        add     rax, rdx
        jo      exit_overflow
        push    rax
}

macro STACK_SUB {
        pop     rdx
        pop     rax
        sub     rax, rdx
        jo      exit_overflow
        push    rax
}

macro STACK_IDIV {
        pop     rcx
        pop     rax
        cqo
        idiv    rcx
        push    rax
}

macro STACK_IMOD {
        pop     rcx
        pop     rax
        mov     r8, rcx
        cqo
        idiv    rcx
        add     r8, rdx
        push    r8
}

section '.text' executable

exit_overflow:
        push        OVERFLOW
        STACK_PRINT_STR

        push        SYS_EXIT    ; [SYS_EXIT]
        push        ERROR       ; [SYS_EXIT, ERROR]
        STACK_SYSCALL2          ; []

main:
        push        rbp
        mov         rbp, rsp

        push        -151        ; [-151]
        push        0           ; [-151, 0]
        STACK_COPY  1           ; [-151, 0, -151]
        push        12          ; [-151, 0, -151, 12]
        STACK_ADD               ; [-151, 0, -151+12]
        STACK_PRINTLN_I64       ; [-151, 0]

        STACK_COPY  1           ; [-151, 0, -151]
        push        12          ; [-151, 0, -151, 12]
        STACK_SUB               ; [-151, 0, (-151)-12]
        STACK_PRINTLN_I64       ; [-151, 0]

        push        -1

        STACK_COPY  2           ; [-151, 0, -1, -151]
        push        12          ; [-151, 0, -1, -151, 12]
        STACK_IDIV              ; [-151, 0, -1, -151/12]
        STACK_PRINTLN_I64       ; [-151, 0, -1]

        STACK_DROP  1           ; [-151, 0]

        push        -151        ; [-151, 0, -151]
        push        12          ; [-151, 0, -151, 12]
        STACK_IMOD              ; [-151, 0, -151%12]

        STACK_COPY  0           ; [-151, 0, -151%12, -151%12]
        STACK_PRINTLN_I64       ; [-151, 0, -151%12]

        STACK_DROP  3           ; []

        push        rbp         ; [rbp]
        push        rsp         ; [rbp, rsp]
        STACK_SUB               ; [rbp-rsp]
        STACK_PRINTLN_I64       ; []

        mov     rsp, rbp
        pop     rbp
        ret

        push        SYS_EXIT    ; [SYS_EXIT]
        push        OK          ; [SYS_EXIT, OK]
        STACK_SYSCALL2          ; []

section '.rodata'

FORMAT_I64 db "%d", 10, 0
OVERFLOW   db "Overflow!", 10, 0
