# ====================
#  Insert at 802608B0
# ====================

.include "common.s"

    stwu r1, -0x10(r1)
    lis r0, 0x41D4 # 26.5f
    stw r0, 8(r1)
    lfs f1, 8(r1)
    addi r1, r1, 0x10
