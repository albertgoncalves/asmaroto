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
    -Wno-unused-macros
)
flags_asm=(
    "-fuse-ld=mold"
    --no-warn-rwx-segments
    -znoexecstack
)

clang-format -i -verbose "$WD/src/"*.c
clang "${flags_c[@]}" -c -o "$WD/bin/c_closure.o" "$WD/src/closure.c"
fasm "$WD/src/closure.asm" "$WD/bin/asm_closure.o"
ld "${flags_asm[@]}" -o "$WD/bin/closure" -lc "$WD/bin/c_closure.o" \
    "$WD/bin/asm_closure.o"
"$WD/bin/closure" || echo "$?"
