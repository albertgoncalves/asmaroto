format ELF64 executable 3

; fasm demonstration of writing 64-bit ELF executable
; (thanks to Franti|¡ek G|¡bri|¡)

; syscall numbers: /usr/src/linux/include/asm-x86_64/unistd.h
; parameters order:
;   r9    ; 6th param
;   r8    ; 5th param
;   r10   ; 4th param
;   rdx   ; 3rd param
;   rsi   ; 2nd param
;   rdi   ; 1st param
;   eax   ; syscall_number
;   syscall

STRING  equ STRING0
LEN     equ (LEN0 + LEN1)

STDOUT    equ 1
SYS_WRITE equ 1
SYS_EXIT  equ 60

segment readable executable

entry $
    mov     edx,    LEN         ; CPU zero extends 32-bit operation to 64-bit,
                                ; so we can use less bytes than `mov rdx ...`
    lea     rsi,    [STRING]
    mov     edi,    STDOUT
    mov     eax,    SYS_WRITE
    syscall

    xor     edi,    edi         ; exit code 0
    mov     eax,    SYS_EXIT
    syscall

segment readable writeable

STRING0 db  "Hello, 64-bit"
LEN0    =   $ - STRING0

STRING1 db  " world!", 0xA
LEN1    =   $ - STRING1
