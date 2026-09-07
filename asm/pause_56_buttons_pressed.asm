# ====================
#  Insert at 8016D1E4
# ====================

.include "common.s"
.include "pause_56.s"

.set gm_GetButtonsPressed, 0x801A3680

    cmplwi r3, 4
    blt stock
    converted_pad r3
    lwz r4, pad_ofst_pressed(r3)
    li r3, 0
    b done
stock:
    branchl r12, gm_GetButtonsPressed
done:
    nop
