format ELF64

public main

public CURRENT_THREAD

extrn printf

extrn new_thread
extrn scheduler
extrn push_thread

SYS_EXIT equ 60

section '.rodata'
    HELLO0      db "Hello?", 0xA, 0
    HELLO1      db "How are you?", 0xA, 0
    HELLO2      db "Say what now?", 0xA, 0
    SHOW_CREATE db " ! Created thread %p", 0xA, 0
    SHOW_KILL   db " ! Killed thread %p", 0xA, 0

section '.bss' writeable
    SCHED_RBP      rq 1
    SCHED_RSP      rq 1
    CURRENT_THREAD rq 1

section '.text' executable

    macro JUMP_TO_SCHED {
        mov     rsp, qword [SCHED_RSP]
        mov     rbp, qword [SCHED_RBP]
        jmp     scheduler
    }

    macro LOAD_THREAD_STACK {
        mov     rax, [CURRENT_THREAD]
        mov     rsp, [rax + 8]
        mov     rbp, [rax + (8 * 2)]
    }

    macro YIELD address {
        mov     rax, [CURRENT_THREAD]
        mov     qword [rax + 8], rsp
        mov     qword [rax + (8 * 2)], rbp ; NOTE: Stash stack pointers.
        mov     qword [rax], address       ; NOTE: Stash resume address.
        JUMP_TO_SCHED
    }

    macro KILL_THREAD {
        mov     rax, [CURRENT_THREAD]
        mov     qword [rax + (8 * 3)], 0

        mov     rdi, SHOW_KILL
        mov     rsi, rax
        xor     eax, eax
        call    printf

        JUMP_TO_SCHED
    }


    f0_thread:
        LOAD_THREAD_STACK
        pop     rdi ; NOTE: Function arguments are already on the stack.
        call    f0_yield
        KILL_THREAD
    f0_yield:
        push    rdi ; NOTE: Push function arguments onto the stack.
        YIELD   f0_body
    f0_body:
        LOAD_THREAD_STACK
        pop     rdi
        xor     eax, eax
        call    printf

        ret


    f1_thread:
        LOAD_THREAD_STACK
        pop     rdi
        call    f1_yield
        KILL_THREAD
    f1_yield:
        push    rdi
        YIELD f1_body
    f1_body:
        LOAD_THREAD_STACK
        pop     rdi
        call    f0_yield
        ret


    f2_thread:
        LOAD_THREAD_STACK
        call    f2_yield
        KILL_THREAD
    f2_yield:
        YIELD f2_body
    f2_body:
        LOAD_THREAD_STACK

        mov     rdi, f1_thread
        call    new_thread

        push    rax

        mov     rdi, SHOW_CREATE
        mov     rsi, [rsp]
        xor     eax, eax
        call    printf

        pop     rdi
        mov     rsi, HELLO1
        call    push_thread

        mov     rdi, HELLO2
        call    f1_yield

        ret


    f3_thread:
        LOAD_THREAD_STACK
        call    f3_yield
        KILL_THREAD
    f3_yield:
        YIELD f3_body
    f3_body:
        LOAD_THREAD_STACK

        mov     rdi, f2_thread
        call    new_thread

        mov     rdi, SHOW_CREATE
        mov     rsi, rax
        xor     eax, eax
        call    printf

        ret


    entry_thread:
        LOAD_THREAD_STACK
        call    entry_yield
        KILL_THREAD
    entry_yield:
        YIELD entry_body
    entry_body:
        LOAD_THREAD_STACK

        mov     rdi, f0_thread
        call    new_thread

        push    rax

        mov     rdi, SHOW_CREATE
        mov     rsi, [rsp]
        xor     eax, eax
        call    printf

        pop     rdi
        mov     rsi, HELLO0
        call    push_thread ; NOTE: Push function arguments onto the stack.

        mov     rdi, f3_thread
        call    new_thread

        mov     rdi, SHOW_CREATE
        mov     rsi, rax
        xor     eax, eax
        call    printf

        call    f3_yield

        ret


    main:
        push    rbp
        mov     rbp, rsp

        mov     rdi, entry_thread
        call    new_thread

        mov     rdi, SHOW_CREATE
        mov     rsi, rax
        xor     eax, eax
        call    printf

        mov     rdi, entry_thread
        call    new_thread

        mov     rdi, SHOW_CREATE
        mov     rsi, rax
        xor     eax, eax
        call    printf

        mov     rsp, rbp
        pop     rbp

        mov     qword [SCHED_RSP], rsp
        mov     qword [SCHED_RBP], rbp
        jmp     scheduler
