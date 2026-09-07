# ====================
#  Insert at 8016BDA8
# ====================

.include "common.s"
.include "pause_56.s"

    cmpwi r30, 4
    blt stock
    converted_pad_offset r30, r31, r4
stock:
    add r3, r31, r0
