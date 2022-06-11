#include <stdint.h>
#include <stdio.h>

typedef int32_t i32;

i32 c_func(i32);

i32 c_func(i32 x) {
    printf("This value was provided by `.asm`: %d\n", x);
    return x + -123;
}
