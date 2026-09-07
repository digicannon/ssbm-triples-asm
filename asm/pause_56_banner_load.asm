# ====================
#  Insert at 801A129C
# ====================

.include "common.s"

    mr r3, r28
    branchl r12, pause_56_banner_load
    li r0, 99 # Original code.
