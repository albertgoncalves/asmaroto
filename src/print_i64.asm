format ELF64 executable 3

STDOUT equ 1

SYS_WRITE equ 1
SYS_EXIT  equ 60

OK    equ 0
ERROR equ 1

BUFFER_CAP equ 32

segment readable writeable

BUFFER rb BUFFER_CAP

segment readable executable

entry $
        mov     rdi, -123456789
        call    println_i64
        mov     edi, OK
        mov     eax, SYS_EXIT
        syscall

; u32 i64_to_len(i64 x)
i64_to_len:
        mov     rax, rdi            ; x
        mov     esi, 0              ; u32 len = 0;
    i64_to_len_loop:                ; do {
        inc     esi;                ; ++len;
        cqo                         ; // `rdx` in use!
        mov     rcx, 10
        idiv    rcx                 ; x /= 10
        cmp     rax, 0
        jne     i64_to_len_loop     ; } while (x != 0);
        mov     eax, esi            ; return len;
        ret

; void println_i64(i64 x)
println_i64:
        call    i64_to_len
        mov     r8d, eax                ; u32 buffer_len = i64_to_len(x);
        inc     r8d                     ; ++buffer_len;
        mov     r9d, 0                  ; buffer_offset = 0;

        cmp     rdi, 0                  ; if (x < 0) {
        jge     println_i64_positive
        inc     r8d                     ;   ++buffer_len;
        inc     r9d                     ;   ++buffer_offset;
        cmp     r8d, BUFFER_CAP
        ja      exit_error
        mov     byte [BUFFER], 45       ;   BUFFER[0] = '-';
        mov     rax, 0
        sub     rax, rdi
        mov     rdi, rax                ;   x = -x;

    println_i64_positive:               ; }
        cmp     r8d, BUFFER_CAP
        ja      exit_error

        mov     r10d, r8d                   ; i = buffer_len;

        dec     r10d                        ; --i;
        mov     byte [BUFFER + r10d], 10    ; BUFFER[i] = '\n';

    println_i64_loop:
        cmp     r10d, r9d                   ; while (i != buffer_offset) {
        je      println_i64_return

        mov     rax, rdi
        mov     rcx, 10
        xor     rdx, rdx
        div     rcx
        mov     rax, rdx
        add     rax, 48

        dec     r10d                        ;   --i;
        mov     byte [BUFFER + r10d], al    ;   BUFFER[i] = '0' + (x % 10);

        mov     rax, rdi
        cqo                                 ;   // `rdx` in use!
        mov     rcx, 10
        idiv    rcx
        mov     rdi, rax                    ;   x /= 10;

        jmp     println_i64_loop            ; }

    println_i64_return:
        mov     edx, r8d
        lea     rsi, [BUFFER]
        mov     edi, STDOUT
        mov     eax, SYS_WRITE
        syscall                 ; write(STDOUT, BUFFER, buffer_len);
        ret

; [[noreturn]] void exit_error(void)
exit_error:
        mov     edi, ERROR
        mov     eax, SYS_EXIT
        syscall
