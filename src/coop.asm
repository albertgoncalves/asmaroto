format ELF64

public main

public THREAD

extrn printf

extrn scheduler

extrn thread_new
extrn thread_kill
extrn thread_push_stack

extrn channel_new
extrn channel_ready
extrn channel_push_data
extrn channel_push_wait
extrn channel_pop_data

section '.rodata'
    PING db " - ping -", 0xA, 0
    PONG db " - pong -", 0xA, 0
    DONE db "Done!", 0xA, 0

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


; ping_pong in out done message {
;     let n {
;         (receive in)
;     }
;     if (= n 0) {
;         (send done 0)
;     } else {
;         (printf "%s\n" message)
;         (send out (- n 1))
;         (ping_pong in out done message)
;     }
; }
    ping_pong_thread:
        LOAD_THREAD_STACK

        mov     rdi, [rsp + (8 * 3)]
        call    receive
        push    rax

        test    rax, rax ; NOTE: if (rax == 0) { ...
        jnz     ping_pong_else
    ; ping_pong_if_then:
        mov     rdi, [rsp + (8 * 2)]
        mov     rsi, DONE
        call    send
        KILL_THREAD
    ping_pong_else:
        mov     rdi, [rsp + 8]
        xor     eax, eax
        call    printf

        mov     rdi, [rsp + (8 * 3)]
        mov     rsi, [rsp]
        sub     rsi, 1
        call    send

        add     rsp, 8
        YIELD   ping_pong_thread


; main {
;     let ping {
;         (channel)
;     }
;     let pong {
;         (channel)
;     }
;     let done {
;         (channel)
;     }
;     (spawn ping_pong ping pong done "ping")
;     (spawn ping_pong pong ping done "pong")
;     (receive done)
;     (printf "Done!\n")
; }
    main_thread:
        LOAD_THREAD_STACK

        call    channel_new     ; NOTE: let ping { ...
        push    rax

        call    channel_new     ; NOTE: let pong { ...
        push    rax

        call    channel_new     ; NOTE: let done { ...
        push    rax


        mov     rdi, ping_pong_thread
        call    thread_new
        push    rax

        mov     rdi, [rsp]
        mov     rsi, [rsp + (8 * 3)]
        call    thread_push_stack

        mov     rdi, [rsp]
        mov     rsi, [rsp + (8 * 2)]
        call    thread_push_stack

        mov     rdi, [rsp]
        mov     rsi, [rsp + 8]
        call    thread_push_stack

        mov     rdi, [rsp]
        mov     rsi, PING
        call    thread_push_stack

        add     rsp, 8


        mov     rdi, ping_pong_thread
        call    thread_new
        push    rax

        mov     rdi, [rsp]
        mov     rsi, [rsp + (8 * 2)]
        call    thread_push_stack

        mov     rdi, [rsp]
        mov     rsi, [rsp + (8 * 3)]
        call    thread_push_stack

        mov     rdi, [rsp]
        mov     rsi, [rsp + 8]
        call    thread_push_stack

        mov     rdi, [rsp]
        mov     rsi, PONG
        call    thread_push_stack

        add     rsp, 8


        mov     rdi, [rsp + (8 * 2)]
        mov     rsi, 5
        call    send

        mov     rdi, [rsp]
        call    receive

        mov     rdi, rax
        xor     eax, eax
        call    printf

        KILL_THREAD


    main:
        mov     rdi, main_thread
        call    thread_new

        mov     qword [SCHED_RSP], rsp
        mov     qword [SCHED_RBP], rbp
        jmp     scheduler
