# ====================
#  Insert at 80263328
# ====================

.include "common.s"

.set epilogue, 0x80263334

    branchl r12, css_56_start_rumble
    branch r12, epilogue # Original code: b to the epilogue.
