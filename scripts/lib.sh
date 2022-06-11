#!/usr/bin/env bash

set -eu

flags=(
    "-ferror-limit=1"
    "-march=native"
    -O3
    "-std=c99"
    -Werror
    -Weverything
)

clang-format -i -verbose "$WD/src/"*.c
clang "${flags[@]}" -c -o "$WD/bin/c_lib.o" "$WD/src/lib.c"
fasm "$WD/src/lib.asm" "$WD/bin/asm_lib.o"
ld -fuse-ld=mold -o "$WD/bin/lib" -lc "$WD/bin/c_lib.o" "$WD/bin/asm_lib.o"
"$WD/bin/lib"
