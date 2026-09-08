.ifndef CONVERTED_PADS_S
.set CONVERTED_PADS_S, 1

.include "triples.s"

.set pad_size, 0x44
.set pad_ofst_pressed, 0 # u32.
.set pad_ofst_triggered, 8 # u32.
.set pad_ofst_err, 0x41 # u8, 0 while plugged in.

# \reg = the address of pad \reg's converted pad.  Not r0.
.macro converted_pad reg
    subi \reg, \reg, 4
    mulli \reg, \reg, pad_size
    addis \reg, \reg, triples_converted_output@ha
    addi \reg, \reg, triples_converted_output@l
.endm

# r0 = the offset from \base to pad \id's converted pad, so the stock's
# base + offset add lands on it.  Clobbers \tmp.
.macro converted_pad_offset id, base, tmp
    mr \tmp, \id
    converted_pad \tmp
    subf r0, \base, \tmp
.endm

.endif
