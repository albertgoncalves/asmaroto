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

string  equ string0
len     equ (len0 + len1)

segment readable executable

entry $
    mov     edx,    len         ; CPU zero extends 32-bit operation to 64-bit,
                                ; so we can use less bytes than `mov rdx ...`
    lea     rsi,    [string]
    mov     edi,    1           ; STDOUT
    mov     eax,    1           ; sys_write
    syscall

    xor     edi,    edi         ; exit code 0
    mov     eax,    60          ; sys_exit
    syscall

segment readable writeable

string0 db  "Hello, 64-bit"
len0    =   $ - string0

string1 db  " world!", 0xA
len1    =   $ - string1
