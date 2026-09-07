# ====================
#  Insert at 80263334
# ====================

.include "common.s"

    branchl r12, css_player_data_update
    lwz r0, 0x34(r1) # Original code.
