#!/usr/bin/env bash

set -eu

fasm "$WD/src/link0.asm" "$WD/bin/link0.o"
fasm "$WD/src/link1.asm" "$WD/bin/link1.o"
mold -run clang -no-pie -o "$WD/bin/link" "$WD/bin/link1.o" "$WD/bin/link0.o"
"$WD/bin/link"
