format ELF64

public main

public THREAD
public SCHED_RSP
public SCHED_RBP

public receive
public send

extrn printf

extrn scheduler

extrn thread_new
extrn thread_kill

extrn channel_ready
extrn channel_push_data
extrn channel_push_wait
extrn channel_pop_data

extrn main_thread

section '.bss' writeable
    SCHED_RBP rq 1
    SCHED_RSP rq 1
    THREAD    rq 1

section '.text' executable

    macro JUMP_SCHED {
        mov     rsp, qword [SCHED_RSP]
        mov     rbp, qword [SCHED_RBP]
        jmp     scheduler
    }

    macro LOAD_THREAD_STACK {
        mov     rax, [THREAD]
        mov     rsp, [rax + 8]       ; NOTE: If the `Thread` struct is
        mov     rbp, [rax + (8 * 2)] ; re-ordered, this will break. Watch out!
    }

    macro YIELD address {
        mov     rax, [THREAD]
        mov     qword [rax + 8], rsp
        mov     qword [rax + (8 * 2)], rbp ; NOTE: Stash stack pointers.
        mov     qword [rax], address       ; NOTE: Stash resume address.
        JUMP_SCHED
    }

    macro KILL_THREAD {
        mov     rdi, [THREAD]
        call    thread_kill
        JUMP_SCHED
    }


    receive:
        push    rdi
        YIELD   receive_yield
    receive_yield:
        LOAD_THREAD_STACK
        mov     rdi, [rsp]
        call    channel_ready

        test    rax, rax ; NOTE: if (channel_ready()) { ...
        jz      receive_else
    ; receive_if_then:
        mov     rdi, [rsp]
        call    channel_pop_data
        add     rsp, 8
        ret
    receive_else:
        mov     rdi, [rsp]
        mov     rsi, [THREAD]
        call    channel_push_wait
        YIELD   receive_yield


    send:
        call    channel_push_data
        YIELD   send_yield
    send_yield:
        LOAD_THREAD_STACK
        ret


    main:
        mov     rdi, main_thread
        call    thread_new

        mov     qword [SCHED_RSP], rsp
        mov     qword [SCHED_RBP], rbp
        jmp     scheduler
