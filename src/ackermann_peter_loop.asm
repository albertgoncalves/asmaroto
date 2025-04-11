format ELF64

public _start

extrn _exit

extrn printf

section '.rodata'
    format_u32  db "%u (%zu)", 10, 0

section '.bss' writeable
    MEMORY rd 16384

section '.text' executable
    _start:
        push    rbp
        mov     rbp, rsp

        mov     esi, 10                     ; n
        mov     edi, 3                      ; m
        call    ackermann_peter_loop

        mov     esi, eax
        mov     rdi, format_u32
        xor     eax, eax
        call    printf

        xor     edi, edi
        call    _exit


    ackermann_peter_loop:
        xor     rcx, rcx                    ; len
        xor     rdx, rdx                    ; counter

    __if_m_eq_0:
        inc     rdx

        test    edi, edi                    ; m == 0
        jnz     __if_n_eq_0

        inc     esi                         ; n += 1

        test    rcx, rcx                    ; len == 0
        jnz     __pop_stack

        mov     eax, esi                    ;
        ret                                 ; return n

    __pop_stack:
        dec     rcx
        mov     edi, [MEMORY + (rcx * 4)]   ; m = MEMORY[--len]

        jmp     __if_m_eq_0                 ; continue

    __if_n_eq_0:
        test    esi, esi                    ; n == 0
        jnz     __else

        dec     edi                         ; m -= 1
        mov     esi, 1                      ; n = 1
        jmp     __if_m_eq_0                 ; continue

    __else:
        lea     eax, [edi - 1]              ;
        mov     [MEMORY + (rcx * 4)], eax   ;
        inc     rcx                         ; MEMORY[len++] = m - 1

        dec     esi                         ; n -= 1
        jmp     __if_m_eq_0
