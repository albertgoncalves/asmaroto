#!/usr/bin/env bash

set -eu

flags=(
    "-ferror-limit=1"
    "-march=native"
    -O3
    "-std=c99"
    -Werror
    -Weverything
    -Wno-declaration-after-statement
    -Wno-extra-semi-stmt
    -Wno-unused-macros
)

clang-format -i -verbose "$WD/src/"*.c
clang "${flags[@]}" -c -o "$WD/bin/c_closure.o" "$WD/src/closure.c"
fasm "$WD/src/closure.asm" "$WD/bin/asm_closure.o"
ld -fuse-ld=mold -o "$WD/bin/closure" -lc "$WD/bin/c_closure.o" \
    "$WD/bin/asm_closure.o"
"$WD/bin/closure" || echo "$?"
