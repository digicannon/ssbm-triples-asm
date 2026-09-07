(cd ../asm2memcard && go build -o a2m .) || exit 1
../asm2memcard/a2m --dolphin --clean --no-loader triples.a2m
