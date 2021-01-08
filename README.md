This repo contains reduced ATS2 code, that al;lows to ignore a datavtype,
producing memory leak. How to build:

```bash
$ git clone https://github.com/dambaev/ats-datavtype-leak.git
cd ats-datavtype-leak/
nix-shell ./shell
cd src
make test3
./test3

```

test3 contains a typechecked program, that is leaking a datavtype:
```
$ valgrind test3 
==3294== Memcheck, a memory error detector
==3294== Copyright (C) 2002-2017, and GNU GPL'd, by Julian Seward et al.
==3294== Using Valgrind-3.15.0 and LibVEX; rerun with -h for copyright info
==3294== Command: src/test3
==3294== 
==3294== 
==3294== HEAP SUMMARY:
==3294==     in use at exit: 4 bytes in 1 blocks
==3294==   total heap usage: 3 allocs, 2 frees, 36 bytes allocated
==3294== 
==3294== LEAK SUMMARY:
==3294==    definitely lost: 4 bytes in 1 blocks
==3294==    indirectly lost: 0 bytes in 0 blocks
==3294==      possibly lost: 0 bytes in 0 blocks
==3294==    still reachable: 0 bytes in 0 blocks
==3294==         suppressed: 0 bytes in 0 blocks
==3294== Rerun with --leak-check=full to see details of leaked memory
==3294== 
==3294== For lists of detected and suppressed errors, rerun with: -s
==3294== ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 0 from 0)
```
