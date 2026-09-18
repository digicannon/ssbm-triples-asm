# ====================
#  Insert at 803787FC
# ====================

# HSD_PadRumbleInterpret, where a port's motor status just changed.

.include "common.s"
.include "triples.s"

.set reg_port, 27
.set reg_rumble_data, 30

    cmpwi reg_port, 4
    blt return
.if !DEBUG
    mr r3, reg_port
    lbz r4, 1(reg_rumble_data)
    branchl r12, rumble_56_motor
.endif
return:
    lbz r0, 1(reg_rumble_data) # Original code.
