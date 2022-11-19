format ELF64

public main

public CURRENT_THREAD

extrn printf

extrn scheduler

extrn new_thread
extrn push_thread_stack
extrn pause_thread
extrn kill_thread

extrn push_waiting

extrn new_channel
extrn channel_ready
extrn push_channel
extrn pop_channel

section '.rodata'
    PING db " - ping -", 0xA, 0
    PONG db " - pong -", 0xA, 0
    DONE db "Done!", 0xA, 0

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
        mov     rsp, [rax + 8]       ; NOTE: If the `Thread` struct is
        mov     rbp, [rax + (8 * 2)] ; re-ordered, this will break. Watch out!
    }

    macro YIELD address {
        mov     rax, [CURRENT_THREAD]
        mov     qword [rax + 8], rsp
        mov     qword [rax + (8 * 2)], rbp ; NOTE: Stash stack pointers.
        mov     qword [rax], address       ; NOTE: Stash resume address.
        JUMP_TO_SCHED
    }

    macro KILL_THREAD {
        mov     rdi, [CURRENT_THREAD]
        call    kill_thread

        JUMP_TO_SCHED
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
        call    pop_channel
        add     rsp, 8
        ret
    receive_else:
        mov     rdi, [CURRENT_THREAD]
        call    pause_thread
        mov     rdi, [rsp]
        mov     rsi, [CURRENT_THREAD]
        call    push_waiting
        YIELD   receive_yield


    send:
        call    push_channel
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

        call    new_channel     ; NOTE: let ping { ...
        push    rax

        call    new_channel     ; NOTE: let pong { ...
        push    rax

        call    new_channel     ; NOTE: let done { ...
        push    rax


        mov     rdi, ping_pong_thread
        call    new_thread
        push    rax

        mov     rdi, [rsp]
        mov     rsi, [rsp + (8 * 3)]
        call    push_thread_stack

        mov     rdi, [rsp]
        mov     rsi, [rsp + (8 * 2)]
        call    push_thread_stack

        mov     rdi, [rsp]
        mov     rsi, [rsp + 8]
        call    push_thread_stack

        mov     rdi, [rsp]
        mov     rsi, PING
        call    push_thread_stack

        add     rsp, 8


        mov     rdi, ping_pong_thread
        call    new_thread
        push    rax

        mov     rdi, [rsp]
        mov     rsi, [rsp + (8 * 2)]
        call    push_thread_stack

        mov     rdi, [rsp]
        mov     rsi, [rsp + (8 * 3)]
        call    push_thread_stack

        mov     rdi, [rsp]
        mov     rsi, [rsp + 8]
        call    push_thread_stack

        mov     rdi, [rsp]
        mov     rsi, PONG
        call    push_thread_stack

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
        call    new_thread

        mov     qword [SCHED_RSP], rsp
        mov     qword [SCHED_RBP], rbp
        jmp     scheduler
