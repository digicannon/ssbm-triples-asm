.include "../common.s"
.include "../triples.s"

    loadwz r3, widescreen_enabled
    cmpwi r3, 0xEE
    beq widescreen
    .long 0xC002E19C # Original code.
    b return
widescreen:
    .long 0x48000011
    .long 0x7C6802A6
    .long 0xC0030000
    .long 0x4800000C
    .long 0x4E800021
    .long 0x40DC7AE1
return:
