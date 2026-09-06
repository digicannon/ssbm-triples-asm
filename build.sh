rm ../asm2memcard/a2m
#gcc -DDEBUG -g -o ../asm2memcard/a2m ../asm2memcard/asm2memcard.c
gcc -g -o ../asm2memcard/a2m ../asm2memcard/asm2memcard.c
../asm2memcard/a2m --dolphin --clean --no-loader triples.a2m
