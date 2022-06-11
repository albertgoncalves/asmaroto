#include <stdint.h>
#include <stdio.h>

typedef int32_t  i32;
typedef uint32_t u32;

// NOTE: See `https://en.wikipedia.org/wiki/X86_calling_conventions#System_V_AMD64_ABI`.

//         rdi, rsi, rdx, rcx, r8,    r9
i32 c_func(i32, i32, i32, i32, char*, u32);

i32 c_func(i32 x0, i32 x1, i32 x2, i32 x3, char* chars, u32 len) {
    printf("  [.c]\n"
           "These values were provided by `.asm`: [ %d, %d, %d, %d ]\n"
           "This string was provided by `.asm`: \"%.*s\"\n",
           x0,
           x1,
           x2,
           x3,
           len,
           chars);
    return x0 - x1 - x2 - x3 - -123;
}
