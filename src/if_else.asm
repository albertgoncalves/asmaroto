format ELF64

public main

extrn printf

section '.rodata'
    BRANCH_IF   db "[  if  ]", 0xA, 0
    BRANCH_ELSE db "[ else ]", 0xA, 0
    DONE        db "Done!", 0xA, 0

section '.text' executable
    main:
        push    rbp
        mov     rbp, rsp

        mov     rax, 123

        ; cmp     rax, 123
        ; jnz     branch_else
        test    rax, rax        ; if (rax != 0) { ...
        jz      branch_else
    ; branch_if:
        mov     rdi, BRANCH_IF
        jmp     branch_end
    branch_else:
        mov     rdi, BRANCH_ELSE
    branch_end:
        xor     eax, eax
        call    printf

        mov     rdi, DONE
        xor     eax, eax
        call    printf

        xor     eax, eax
        mov     rsp, rbp
        pop     rbp
        ret
