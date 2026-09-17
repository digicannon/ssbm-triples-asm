# ====================
#  Insert at 80260548
# ====================

.include "common.s"

    lbz r4, 4(r31) # The cursor's port; 0 for whichever P5/P6 is swapped in.
    cmpwi r4, 0
    bne spawn
    branchl r12, css_56_swapped_port
    cmpwi r3, 0
    blt spawn
    mr r4, r3
spawn:
    mr r3, r31
    branchl r12, css_hand_warp_to_spawn

    li r4, 0
    sth r4, 10(r31) # Original code.
