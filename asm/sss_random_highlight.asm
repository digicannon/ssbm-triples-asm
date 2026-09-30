# ====================
#  Insert at 8025AA10
# ====================

# RANDOM is the last icon ID:
# - 0x1D of 0x1E in vanilla.
# - m-ex's count - 1.

.include "common.s"

    test_mex r7
    li r7, 0x1D
    beq return
    loadwz r7, mex_sss_icon_count
    subi r7, r7, 1
return:
