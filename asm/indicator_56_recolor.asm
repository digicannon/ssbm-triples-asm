# ====================
#  Insert at 802FD3EC
# ====================

.include "common.s"

    cmpwi r29, 4
    blt done
    mr r3, r30
    mr r4, r29
    branchl r12, indicator_56_recolor
done:
    lmw r27, 0x34(r1) # Original code.
