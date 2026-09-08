# ====================
#  Insert at 801A0E7C
# ====================

.include "common.s"
.include "converted_pads.s"

    lwz r6, 0x14(r4) # PauseData.slot, the pauser.
    cmpwi r6, 4
    blt stock
    subi r6, r6, 4
    mulli r5, r6, pad_size
    load r0, triples_converted_output
stock:
    add r3, r0, r5
