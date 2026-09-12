# ====================
#  Insert at 800364BC
# ====================

# The entry of Player_SetUnk45, which stores a slot's color index.

.include "common.s"

    mflr r0
    stw r0, 4(r1)
    stwu r1, -0x10(r1)
    stw r3, 8(r1)
    branchl r12, shield_and_blastzone_colors_56_index
    mr r4, r3
    lwz r3, 8(r1)
    addi r1, r1, 0x10
    lwz r0, 4(r1)
    mtlr r0
    mflr r0 # Original code.
