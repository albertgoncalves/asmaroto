format ELF64

extrn printf

public main

SYS_EXIT equ 60


; i32* x = ...;
; u32 i = 0;
; while (*x < (10 * 1000 * 1000)) {
;     if ((*x & 1) == 0) {
;         *x += 29;
;     } else {
;         *x -= 3;
;     }
;     ++i;
; }
; printf("%d, %u\n", *x, i);


section '.rodata'
    _format db "%d, %u", 0xA, 0


section '.text' executable
    main:
        push    0
        mov     r8, rsp

        xor     r9d, r9d

    _while:
        cmp     dword [r8], 10 * 1000 * 1000
        jg      _while_end

        mov     eax, [r8]
        and     eax, 1
        test    eax, eax
        jnz     _if_else

        add     dword [r8], 29
        jmp     _if_end

    _if_else:
        sub     dword [r8], 3

    _if_end:
        inc     r9d
        jmp     _while

    _while_end:
        mov     edx, r9d
        mov     esi, [r8]
        mov     edi, _format
        xor     eax, eax
        call    printf

        add     rsp, 8
        ret
