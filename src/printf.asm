format ELF64

public _start

extrn getpid
extrn printf
extrn _exit


section '.text' executable
    _start:
        call    getpid
        mov     rsi,    rax

        mov     rdi,    _format
        mov     rdx,    _string
        xor     eax,    eax
        call    printf

        xor     edi,    edi
        call    _exit


section '.rodata'
    _string db 72, 101, 108, 108, 111, 44, 32, 119, 111, 114, 108, 100, 33, 0
    _format db "[pid: %d]", 0xA, "%s", 0xA, 0
