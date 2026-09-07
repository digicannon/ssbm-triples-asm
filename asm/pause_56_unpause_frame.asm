# ====================
#  Insert at 8016D0BC and 8016D11C
# ====================

.include "common.s"
.include "pause_56.s"

    cmplwi r4, 4
    blt stock
    converted_pad_offset r4, r3, r7
stock:
    add r5, r3, r0
