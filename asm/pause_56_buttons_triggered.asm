# ====================
#  Insert at 8016D1C0 and 8016D238
# ====================

.include "common.s"
.include "converted_pads.s"

.set gm_GetButtonsTriggered, 0x801A36A0

    cmplwi r3, 4
    blt stock
    converted_pad r3
    lwz r4, pad_ofst_triggered(r3)
    li r3, 0
    b done
stock:
    branchl r12, gm_GetButtonsTriggered
done:
    nop
