format ELF64

public main
public MEMORY

extrn printf

extrn memory_init    ; void   memory_init(void)
extrn alloc_buffer_2 ; i64*   alloc_buffer_2(i64, i64)
extrn scope_new      ; Scope* scope_new(void)
extrn scope_new_from ; Scope* scope_new_from(Scope*)
extrn scope_lookup   ; i64    scope_lookup(Scope*, char*, u64)
extrn scope_insert   ; void   scope_insert(Scope*, char*, u64, i64)
extrn scope_update   ; void   scope_update(Scope*, char*, u64, i64)

SYS_EXIT equ 60

section '.rodata'
    STR_F db "f"
    LEN_F =  $ - STR_F

    STR_G db "g"
    LEN_G =  $ - STR_G

    STR_X db "x"
    LEN_X =  $ - STR_X

    STR_I64     db "%ld", 0
    STR_NEWLINE db 0xA, 0

section '.bss' writeable
    MEMORY rb 280

section '.text' executable

;   _s0_ := (@newScope ());
;   (@insertScope _s0_ "f" (_s0_, _f0_));
;   (@insertScope _s0_ "g" (_s0_, _f2_));
;   print (((@lookupScope _s0_ "f") ((@lookupScope _s0_ "g") ())) ());
;   print "\n"
main:
        push    rbp             ; [???]
        mov     rbp, rsp        ; []

        call    memory_init     ; []

    ; _s0_ := (@newScope ());
        call    scope_new
        push    rax             ; [_s0_]

    ; (@insertScope _s0_ "f" (_s0_, _f0_));
        ; NOTE: Store values in a tuple.
        mov     rdi, [rbp - 8]
        mov     rsi, _f0_
        call    alloc_buffer_2
        push    rax             ; [_s0_, (_s0_, _f0_)]

        ; NOTE: Insert tuple into scope.
        mov     rdi, [rbp - 8]
        mov     rsi, STR_F
        mov     rdx, LEN_F
        mov     rcx, [rbp - 16]
        call    scope_insert
        add     rsp, 8          ; [_s0_]

    ; (@insertScope _s0_ "g" (_s0_, _f2_));
        ; NOTE: Store values in a tuple.
        mov     rdi, [rbp - 8]
        mov     rsi, _f2_
        call    alloc_buffer_2
        push    rax             ; [_s0_, (_s0_, _f2_)]

        ; NOTE: Insert tuple into scope.
        mov     rdi, [rbp - 8]
        mov     rsi, STR_G
        mov     rdx, LEN_G
        mov     rcx, [rbp - 16]
        call    scope_insert
        add     rsp, 8          ; [_s0_]

    ; print (((@lookupScope _s0_ "f") ((@lookupScope _s0_ "g") ())) ());
    ; ... @lookupScope _s0_ "g"
        mov     rdi, [rbp - 8]
        mov     rsi, STR_G
        mov     rdx, LEN_G
        call    scope_lookup
        push    rax             ; [_s0_, (_s0_, _f2_)]

    ; NOTE: Call function with 0 arguments from tuple.
    ; ... (_s0_, _f2_) ()
        mov     rax, [rbp - 16]
        mov     rdi, [rax]
        mov     rax, [rax + 8]
        add     rsp, 8          ; [_s0_]
        call    rax
        push    rax             ; [_s0_, g ()]

    ; ... @lookupScope _s0_ "f"
        mov     rdi, [rbp - 8]
        mov     rsi, STR_F
        mov     rdx, LEN_F
        call    scope_lookup
        push    rax             ; [_s0_, g (), (_s0_, _f0_)]

    ; NOTE: Call function with 1 argument from tuple.
    ; ... (_s0_, _f0_) (g ())
        mov     rax, [rbp - 24] ; NOTE: Could `rsp` be used here?
        mov     rdi, [rax]
        mov     rax, [rax + 8]
        add     rsp, 8          ; [_s0_, g ()]
        pop     rsi             ; [_s0_]
        call    rax
        push    rax             ; [_s0_, f ()]

    ; NOTE: Call function with 0 arguments from tuple (?).
    ; ... (f ()) ()
        mov     rax, [rbp - 16] ; NOTE: Could `rsp` be used here?
        mov     rdi, [rax]
        mov     rax, [rax + 8]
        add     rsp, 8          ; [_s0_]
        call    rax
        push    rax             ; [_s0_, (f ()) ()]

    ; print ((f ()) ())
        mov     rdi, STR_I64
        pop     rsi             ; [_s0_]
        xor     eax, eax
        call    printf

    ; print "\n"
        mov     rdi, STR_NEWLINE
        xor     eax, eax
        call    printf

        mov     rsp, rbp
        pop     rbp

        xor     edi, edi
        mov     eax, SYS_EXIT
        syscall

;   _f0_ := (\_s0_ x ->
;       _s1_ := (@newScopeFrom _s0_);
;       (@insertScope _s1_ "x" x);
;       (_s1_, _f1_)
;   );
_f0_:
        push    rbp
        mov     rbp, rsp        ; []

        push    rdi             ; [_s0_]
        push    rsi             ; [_s0_, x]

        mov     rdi, [rbp - 8]
        call    scope_new_from
        push    rax             ; [_s0_, x, _s1_]

    ; (@insertScope _s1_ "x" x);
        mov     rdi, [rbp - 24]
        mov     rsi, STR_X
        mov     rdx, LEN_X
        mov     rcx, [rbp - 16]
        call    scope_insert

        ; NOTE: Store values in a tuple.
        mov     rdi, [rbp - 24] ; NOTE: Could we use `rsp` here?
        mov     rsi, _f1_
        call    alloc_buffer_2
        push    rax             ; [_s0_, x, _s1_, (_s1_, _f1_)]

        pop     rax             ; [_s0_, x, _s1_]

        mov     rsp, rbp
        pop     rbp
        ret

;   _f1_ := (\_s1_ ->
;       _s2_ := (@newScopeFrom _s1_);
;       (@lookupScope _s2_ "x")
;   );
_f1_:
        push    rbp
        mov     rbp, rsp        ; []

        push    rdi             ; [_s1_]

        mov     rdi, [rbp - 8]
        call    scope_new_from
        push    rax             ; [_s1_, _s2_]

        mov     rdi, [rbp - 16]
        mov     rsi, STR_X
        mov     rdx, LEN_X
        call    scope_lookup
        push    rax             ; [_s1_, _s2_, x]

        pop     rax             ; [_s1_, _s2_]

        mov     rsp, rbp
        pop     rbp
        ret

;   _f2_ := (\_s0_ ->
;       _s3_ := (@newScopeFrom _s0_);
;       (@insertScope _s3_ "x" 0);
;       (@updateScope _s3_ "x" -123);
;       (@lookupScope _s3_ "x")
;   );
_f2_:
        push    rbp
        mov     rbp, rsp        ; []

        push    rdi             ; [_s0_]

        mov     rdi, [rbp - 8]
        call    scope_new_from
        push    rax             ; [_s0_, _s3_]

        mov     rdi, [rbp - 16]
        mov     rsi, STR_X
        mov     rdx, LEN_X
        mov     rcx, 0
        call    scope_insert

        mov     rdi, [rbp - 16]
        mov     rsi, STR_X
        mov     rdx, LEN_X
        mov     rcx, -123
        call    scope_update

        mov     rdi, [rbp - 16]
        mov     rsi, STR_X
        mov     rdx, LEN_X
        call    scope_lookup
        push    rax

        pop     rax

        mov     rsp, rbp
        pop     rbp
        ret
