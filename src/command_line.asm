format ELF64

public _start

extrn printf
extrn _exit

section '.rodata'
    format_string db "%s", 10, 0

section '.text' executable
    _start:
        ; NOTE: See `https://wiki.osdev.org/System_V_ABI`.
        push    r12
        push    r13
        push    r14

        ; NOTE: See `https://board.flatassembler.net/topic.php?t=2852`.
        mov     r12,    [rsp + (8 * 3)] ; argc
        lea     r13,    [rsp + (8 * 4)] ; argv
        xor     r14,    r14

    while_start:
        cmp     r12,    r14
        jz      while_end

        mov     rsi,    [r13 + (r14 * 8)]
        mov     rdi,    format_string
        xor     eax,    eax
        call    printf

        inc     r14
        jmp     while_start

    while_end:
        xor     edi,    edi
        call    _exit
