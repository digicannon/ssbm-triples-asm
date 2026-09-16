# ====================
#  Insert at 8025BA60
# ====================

# After mnStageSel_Scene_OnFrame's existing pad loop.

.include "common.s"

    branchl r12, sss_56_input
    lbz r3, -0x49F4(r13) # Original code.
