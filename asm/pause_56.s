# Shared by the pause hooks.  Pads 4 and 5 are P5/P6's converted inputs.
.ifndef PAUSE_56_S
.set PAUSE_56_S, 1

.include "triples.s"

.set pad_size, 0x44
.set pad_ofst_pressed, 0 # u32.
.set pad_ofst_triggered, 8 # u32.

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
