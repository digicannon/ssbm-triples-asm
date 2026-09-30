# ====================
#  Insert at 8015FBA4
# ====================

# gmMainLib_8015FBA4 re-initializes save data at boot, on reset, and from
# the data delete menu.  Skip it on reset so settings survive.

.include "common.s"

.set resetting, 0x8046B0F4 # gmMainLib_8046B0F0.resetting

    loadwz r12, resetting
    cmpwi r12, 0
    beq return
    blr

return:
    mflr r0
