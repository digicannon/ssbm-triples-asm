# ====================
#  Insert at 802FC9EC
# ====================

# Right after the slot's player id lands in r3.  CPUs keep their CP label.

.include "common.s"

.set epilogue, 0x802FCA84

    cmpwi r3, 4
    blt done
    cmpwi r30, 0
    bne done
    mr r3, r28
    mr r4, r29
    branchl r12, indicator_56_frame
    branch r12, epilogue
done:
    clrlwi. r0, r29, 24 # Original code.
