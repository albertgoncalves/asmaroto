format ELF64 executable 3

entry main

    OK          equ 0
    ERROR       equ 1
    STDOUT      equ 1
    SYS_WRITE   equ 1
    SYS_EXIT    equ 60

segment readable
    MSG0 db "first", 0xA
    LEN0 = $ - MSG0
    MSG1 db "second", 0xA
    LEN1 = $ - MSG1

segment readable executable

main:
        ; NOTE: See `https://en.wikibooks.org/wiki/X86_Assembly/FASM_Syntax#Anonymous_Labels`.
        jmp     @f
        mov     rdi, ERROR
        mov     rax, SYS_EXIT
        syscall

    @@:
        mov     rdi, STDOUT
        lea     rsi, [MSG0]
        mov     rdx, LEN0
        mov     rax, SYS_WRITE
        syscall

        jmp     .end

    @@:
        mov     rdi, OK
        mov     rax, SYS_EXIT
        syscall

    .end:
        mov     rdi, STDOUT
        lea     rsi, [MSG1]
        mov     rdx, LEN1
        mov     rax, SYS_WRITE
        syscall

        jmp     @b
