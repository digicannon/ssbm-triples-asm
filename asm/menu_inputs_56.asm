# ====================
#  Insert at 801A3E74
# ====================

# End of gm_EvaluateAllControllerInputs.

.include "common.s"

    branchl r12, menu_inputs_56
    lwz r0, 0x4C(r1) # Original code.
