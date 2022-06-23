#!/usr/bin/env bash

set -eu
fasm "$WD/src/link0.asm" "$WD/bin/link0.o"
fasm "$WD/src/link1.asm" "$WD/bin/link1.o"
ld -fuse-ld=mold -o "$WD/bin/link" -lc "$WD/bin/link0.o" "$WD/bin/link1.o"
"$WD/bin/link"
