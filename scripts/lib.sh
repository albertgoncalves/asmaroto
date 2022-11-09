#!/usr/bin/env bash

set -eu

flags_c=(
    "-ferror-limit=1"
    "-march=native"
    -O3
    "-std=c99"
    -Werror
    -Weverything
)
flags_asm=(
    "-fuse-ld=mold"
    --no-warn-rwx-segments
    -znoexecstack
)

clang-format -i -verbose "$WD/src/"*.c
clang "${flags_c[@]}" -c -o "$WD/bin/c_lib.o" "$WD/src/lib.c"
fasm "$WD/src/lib.asm" "$WD/bin/asm_lib.o"
ld "${flags_asm[@]}" -o "$WD/bin/lib" -lc "$WD/bin/c_lib.o" "$WD/bin/asm_lib.o"
"$WD/bin/lib"
