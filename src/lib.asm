format ELF64

section '.text' executable

public _start

extrn printf
extrn c_func

SYS_EXIT equ 60

FMT_ASM db "  [.asm]", 0xA, "This value was computed in `.c`: %d", 0xA, 0
FMT_C   db "Hello, world!"
LEN_C   =  $ - FMT_C

_start:
    mov     edi, -456   ; x0
    mov     esi, 450    ; x1
    mov     edx, 6      ; x2
    mov     ecx, 246    ; x3
    mov     r8, FMT_C   ; char* chars
    mov     r9d, LEN_C  ; u32   len
    call    c_func

    mov     rdi, FMT_ASM
    mov     esi, eax
    ; NOTE: See `https://stackoverflow.com/questions/6212665/why-is-eax-zeroed-before-a-call-to-printf`.
    xor     eax, eax
    call    printf

    xor     edi, edi         ; exit code 0
    mov     eax, SYS_EXIT
    syscall
