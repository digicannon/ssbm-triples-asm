# ====================
#  Insert at 801A10E8
# ====================

.include "common.s"

    branchl r12, pause_56_banner_label
    lmw r26, 0x18(r1) # Original code.
