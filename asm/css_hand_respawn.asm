# ====================
#  Insert at 80260548
# ====================

.include "common.s"

    mr r3, r31 # The cursor.
    lbz r4, 4(r31) # Its port.
    branchl r12, css_hand_warp_to_spawn

    li r4, 0
    sth r4, 10(r31) # Original code.
