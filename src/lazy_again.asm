format ELF64

public _start

extrn _exit
extrn malloc
extrn printf

section '.rodata'
    format_func   db "!",  10, 0
    format_result db "%d", 10, 0

section '.rodata' writeable
    thunk rq 4

section '.text' executable
    _start:
            mov     [thunk], f2
            mov     [thunk + 8], 0
            mov     [thunk + (8 * 2)], -123
            mov     [thunk + (8 * 3)], 456

            mov     rdi, thunk
            call    call_thunk_2
            mov     rdi, rax
            call    print_result

            mov     rdi, thunk
            call    call_thunk_2
            mov     rdi, rax
            call    print_result

            xor     edi, edi
            call    _exit

    f2:
            push    rdi
            push    rsi

            mov     rdi, format_func
            xor     eax, eax
            call    printf

            pop     rdi
            pop     rsi

            sub     rdi, rsi
            mov     rax, rdi
            ret

    print_result:
            mov     rsi, rdi
            mov     rdi, format_result
            xor     eax, eax
            call    printf
            ret

    ; i.e. "call a thunk with 2 arguments"
    call_thunk_2:
            mov     rax, [rdi + 8]
            and     rax, 1
            test    rax, rax
            jz      _else

            mov     rax, [rdi]
            ret

        _else:
            push    rdi

            mov     rax, [rdi]
            mov     rsi, [rdi + (8 * 3)]
            mov     rdi, [rdi + (8 * 2)]
            call    rax

            pop     rdi

            mov     [rdi], rax

            mov     rsi, [rdi + 8]
            or      rsi, 1
            mov     [rdi + 8], rsi

            ret

    ; /* --- */
    ;
    ;                       <-8bytes->
    ;                       +--------+--------+--------+--------+----
    ;   thunk           =>  | func   | info   | arg-0  | arg-1  | ...
    ;   thunk (cached)  =>  | result | info   |
    ;
    ;               <----------------------------8bytes---------------------------->
    ;   info    =>  CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCBBBBBBA
    ;   info.A  =>  (info & 1) ? cached : not cached
    ;   info.B  =>  (info >> 1) & 0x3F == number of args
    ;   info.C  =>  (info >> 7 + 0) & 1 ? arg-0 is a pointer : arg-0 is not a pointer
    ;               (info >> 7 + 1) & 1 ? arg-1 is a pointer : arg-1 is not a pointer
    ;               ...

    ; /* --- */
    ;
    ;   fn f0 { /* () -> int */
    ;       (printf "f0\n");
    ;       -1
    ;   }
    ;
    ;   fn f1 x { /* int -> int */
    ;       (printf "f1\n");
    ;       (+ 1 x)
    ;   }
    ;
    ;   fn f2 x y { /* thunk -> thunk -> thunk */
    ;       (printf "f2\n");
    ;       (#alloc-thunk f1 (+ (#call-thunk x) (#call-thunk y)))
    ;   }
    ;
    ;   let x = (#alloc-thunk f0);
    ;   (#push-gc x);
    ;   let y = (#alloc-thunk f1 1);
    ;   (#push-gc y);
    ;   (printf "%d\n" (#call-thunk y));
    ;   let z0 = (#alloc-thunk 0b10 f2 x y);
    ;   (#push-gc z0);
    ;   let z1 = (#call-thunk z0);
    ;   (#push-gc z1);
    ;   (printf "%d\n" (#call-thunk z1));
    ;   (printf "%d\n" (#call-thunk z1));
    ;   (#pop-gc z1);
    ;   (#pop-gc z0);
    ;   (#pop-gc y);
    ;   (#pop-gc x);
    ;   (#run-gc);
    ;
    ; /* --- */
    ;
    ;   fn f0 { /* () -> int */
    ;       printf("f0\n");
    ;       -1
    ;   }
    ;
    ;   fn f1 x { /* int -> int */
    ;       printf("f1\n");
    ;       +(1, x)
    ;   }
    ;
    ;   fn f2 x y { /* thunk<int> -> thunk<int> -> thunk<int> */
    ;       (printf "f2\n");
    ;       f1(+(x, y))
    ;   }
    ;
    ;   let x = f0();           // x: thunk<int>
    ;   let y = f1(1);          // y: thunk<int>
    ;   printf("%d\n", y);
    ;   let z0 = f2(x, y);      // z0: thunk<thunk<int>>
    ;   let z1 = z0;            // z1: thunk<thunk<int>>
    ;   printf("%d\n", z1);
    ;   printf("%d\n", z1);
