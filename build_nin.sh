rm ../asm2memcard/a2m
gcc -DDEBUG -g -o ../asm2memcard/a2m ../asm2memcard/asm2memcard.c
../asm2memcard/a2m --nintendont triples.a2m ../ssbm-triples-nintendont/kernel/triples_codes.h
