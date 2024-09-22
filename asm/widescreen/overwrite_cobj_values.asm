.include "../common.s"
.include "../triples.s"

    loadwz r3, widescreen_enabled
    cmpwi r3, 0xEE
    beq widescreen
    .long 0xC03F0034 # Original code.
    b return
widescreen:
    .long 0x38600001
    .long 0x986DAFE0
    .long 0xC03F0034
    .long 0x4800001D
    .long 0x7C6802A6
    .long 0xC0430000
    .long 0xC0630004
    .long 0xEC2100B2
    .long 0xEC211824
    .long 0x48000010
    .long 0x4E800021
    .long 0x43A00000
    .long 0x435B0000
return:
