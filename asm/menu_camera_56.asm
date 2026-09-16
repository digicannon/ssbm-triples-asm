# ====================
#  Insert at 8022BB14
# ====================

.include "common.s"
.include "converted_pads.s"

.set nml_substick_x, 0x28
.set nml_substick_y, 0x2C

# f1 and f0 hold negative and positive deadzone values.
# f2 and f3 are the camera controlling stick's coordinates.

    load r4, triples_converted_output
    li r5, 0
    # Iterations:
    # - Last vanilla stick checked.  We do this to keep intended priority.
    # - P5
    # - P6
check:
    fcmpo cr0, f2, f1
    ble done
    fcmpo cr0, f2, f0
    bge done
    fcmpo cr0, f3, f1
    ble done
    fcmpo cr0, f3, f0
    bge done
    lfs f2, nml_substick_x(r4)
    lfs f3, nml_substick_y(r4)
    addi r4, r4, pad_size
    addi r5, r5, 1
    cmpwi r5, 2
    blt check
    # Exits after loading P6.  Vanilla will check deadzone again.
done:
    lfs f1, -0x3C18(r2) # Original code.
