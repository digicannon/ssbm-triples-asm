# ====================
#  Insert at 802F64F0
# ====================

.include "common.s"

    mr r3, r4 # The symbol's MObj.
    mr r4, r31 # The player slot.
    branchl r12, hud_56_franchise_symbol_color
    lwz r3, 4(r29) # Original code.
