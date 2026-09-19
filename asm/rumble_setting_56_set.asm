# ====================
#  Insert at 8015ED4C
# ====================

.include "common.s"

    cmpwi r3, 4
    blt return
    subi r3, r3, 4
    load r5, rumble_56_enabled
    stbx r4, r5, r3
    blr
return:
    lwz r0, -0x77C0(r13) # Original code.
