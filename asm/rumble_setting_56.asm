# ====================
#  Insert at 8015ED3C
# ====================

# GetRumbleSettingOfPort.  The save data has four entries; P5/P6 are always on.

.include "common.s"

    cmpwi r3, 4
    blt return
    li r3, 1
    blr
return:
    lwz r0, -0x77C0(r13) # Original code.
