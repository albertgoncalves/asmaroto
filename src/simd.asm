format ELF64

public _start

extrn _exit
extrn printf

section '.rodata'
    format_string db "%f", 10, 0

section '.data'
    array dd 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 9.0, 0.0, 0.0, 0.0, 0.0

section '.text' executable
    _start:
            ; NOTE: See `https://flatassembler.net/docs.php?article=manual#_1.1`.
            vmovaps     ymm1, yword [array]
            vmovaps     ymm2, yword [array + (4 * 8)]
            vdivps      ymm3, ymm1, ymm2

            vpermilps   ymm3, ymm3, 3

            vmovaps     ymm0, ymm3
            cvtss2sd    xmm0, xmm0

            mov         rdi, format_string
            mov         eax, 1
            call        printf

            xor         edi, edi
            call        _exit
