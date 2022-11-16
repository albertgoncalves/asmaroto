#!/usr/bin/env bash

set -eu

flags_c=(
    "-ferror-limit=1"
    "-march=native"
    -O3
    "-std=c99"
    -Werror
    -Weverything
    -Wno-declaration-after-statement
)

clang-format -i -verbose "$WD/src/"closure.c
clang "${flags_c[@]}" -c -o "$WD/bin/c_closure.o" "$WD/src/closure.c"
fasm "$WD/src/closure.asm" "$WD/bin/asm_closure.o"
mold -run clang -no-pie -o "$WD/bin/closure" "$WD/bin/c_closure.o" \
    "$WD/bin/asm_closure.o"
"$WD/bin/closure" || echo "$?"
