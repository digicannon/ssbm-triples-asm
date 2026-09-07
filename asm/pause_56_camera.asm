# ====================
#  Insert at 8002CB44
# ====================

# Camera_8002B694 fetches the pauser's inputs, where id 4 means every pad
# and 5 means none (the @set drops its early return on 5).

.include "common.s"
.include "pause_56.s"

.set Camera_8002B694, 0x8002B694

    cmpwi r4, 4
    blt stock
    converted_pad r4
    lwz r0, 0x20(r4) # Stick.
    stw r0, 0(r3)
    lwz r0, 0x24(r4)
    stw r0, 4(r3)
    lwz r0, 0x28(r4) # C-stick.
    stw r0, 8(r3)
    lwz r0, 0x2C(r4)
    stw r0, 0xC(r3)
    li r0, 0
    stw r0, 0x10(r3) # Pressed and triggered are u64.
    lwz r5, pad_ofst_pressed(r4)
    stw r5, 0x14(r3)
    stw r0, 0x18(r3)
    lwz r5, pad_ofst_triggered(r4)
    stw r5, 0x1C(r3)
    b done
stock:
    branchl r12, Camera_8002B694
done:
    nop
