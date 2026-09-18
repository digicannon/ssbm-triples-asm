# ====================
#  Insert at 80378A24
# ====================

# HSD_PadRumbleInit zeroes four entries; zero our fifth and sixth.

.include "common.s"

    li r0, 0
    stw r0, 0x30(r3)
    stw r0, 0x34(r3)
    stw r0, 0x38(r3)
    stw r0, 0x3C(r3)
    stw r0, 0x40(r3)
    stw r0, 0x44(r3)
    lwz r31, 0x2C(r1) # Original code.
