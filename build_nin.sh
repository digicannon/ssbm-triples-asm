(cd ../asm2memcard && go build -o a2m .) || exit 1
../asm2memcard/a2m --nintendont triples.a2m ../ssbm-triples-nintendont/kernel/triples_codes.h
