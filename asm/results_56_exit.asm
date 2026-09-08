# ====================
#  Insert at 8017858C
# ====================

# When the results screen is all CPUs,
# whether naturally or because our results patch copied in 5/6 as a CPU,
# the game requires one of any controller to press start to exit results.
# We need to check 5/6's controller or else its a softlock.

.include "common.s"
.include "converted_pads.s"

.set no_humans, 0x804D3FC8
.set sfx_forward, 0x80174338

    loadwz r3, no_humans
    cmpwi r3, 0
    beq done
    li r3, 4
    converted_pad r3
    li r4, 2
loop:
    lbz r0, pad_ofst_err(r3)
    cmpwi r0, 0
    bne next
    lwz r0, pad_ofst_triggered(r3)
    andi. r0, r0, BTN_MASK_START
    beq next
    li r24, 1
    branchl r12, sfx_forward
    b done
next:
    addi r3, r3, pad_size
    subi r4, r4, 1
    cmpwi r4, 0
    bne loop
done:
    cmpwi r24, 0 # Original code.
