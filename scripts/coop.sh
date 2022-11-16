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
    -Wno-padded
    -Wno-pointer-arith
)

clang-format -i -verbose "$WD/src/"coop.c
clang "${flags_c[@]}" -c -o "$WD/bin/c_coop.o" "$WD/src/coop.c"
fasm "$WD/src/coop.asm" "$WD/bin/asm_coop.o"
mold -run clang -no-pie -o "$WD/bin/coop" "$WD/bin/c_coop.o" \
    "$WD/bin/asm_coop.o"
"$WD/bin/coop" || echo "$?"
