# ====================
#  Insert at 8016CC4C and 8016CCAC
# ====================

.include "common.s"
.include "pause_56.s"

    cmplwi r4, 4
    blt stock
    converted_pad_offset r4, r3, r7
stock:
    add r6, r3, r0
