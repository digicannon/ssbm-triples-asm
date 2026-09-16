# ====================
#  Insert at 80263250
# ====================

.include "common.s"
.include "converted_pads.s"

# r7 contains all pad buttons or'd together.

    cmplwi r5, 4 # Door count.
    bne done
    load r3, triples_converted_output
    lwz r0, pad_ofst_triggered(r3)
    or r7, r7, r0
    lwz r0, (pad_size + pad_ofst_triggered)(r3)
    or r7, r7, r0
done:
    lbz r0, -0x49AE(r13) # Original code.
