# ====================
#  Insert at 8015ED3C
# ====================

.include "common.s"

    cmpwi r3, 4
    blt return
    subi r3, r3, 4
    load r4, rumble_56_enabled
    lbzx r3, r4, r3
    blr
return:
    lwz r0, -0x77C0(r13) # Original code.
