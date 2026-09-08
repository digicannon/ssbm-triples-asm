# ====================
#  Insert at 80177B48
# ====================

# This is checking if anyone pressed a button to advance to the match statistics.

.include "common.s"
.include "converted_pads.s"

    li r3, 4
    converted_pad r3
    li r4, 2
loop:
    lbz r0, pad_ofst_err(r3)
    cmpwi r0, 0
    bne next
    lwz r0, pad_ofst_triggered(r3)
    cmpwi r0, 0
    beq next
    li r0, 3
    stb r0, 1(r31)
    b done
next:
    addi r3, r3, pad_size
    subi r4, r4, 1
    cmpwi r4, 0
    bne loop
done:
    lbz r0, 1(r31) # Original code.
