# ====================
#  Insert at 802FD274
# ====================

.include "common.s"

    cmpwi r27, 4
    blt done
    mr r3, r28
    mr r4, r27
    branchl r12, indicator_56_label
done:
    lmw r25, 0x2C(r1) # Original code.
