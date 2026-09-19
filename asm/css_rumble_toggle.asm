# ====================
#  Insert at 802608D8
# ====================

# mnCharSel_CursorThink, once the hand is clamped on screen.
# r28 holds the port's triggered buttons.

.include "common.s"

    mr r3, r31
    mr r4, r28
    branchl r12, css_rumble_toggle
    lbz r4, 4(r31) # Original code.
