# asmaroto

Dependencies
---
 - [Clang](https://clang.llvm.org/)
```
$ clang --version
clang version 14.0.6
Target: x86_64-pc-linux-gnu
Thread model: posix
InstalledDir: /usr/bin
```
 - [flat assembler](https://flatassembler.net/)
```
$ fasm
flat assembler  version 1.73.30
```
 - [mold](https://github.com/rui314/mold)
```
$ mold --version
mold 1.6.0 (323ad30e25c2c81efdb07ab76601a119335a40c8; compatible with GNU ld)
```

Quick start
---
```
$ . .shellhook
$ runa src/hello.asm
$ runc src/printf.asm
$ ./scripts/link.sh
```
