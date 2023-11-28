powerpc-eabi-as -a32 -mbig -mregnames -o a.obj && powerpc-eabi-objcopy -O binary a.obj a.out && xxd -g 4 a.out
