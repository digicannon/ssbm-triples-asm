# ====================
#  Insert at 8026312C
# ====================

.include "common.s"

.set hide, 0x802631C0

    branchl r12, css_56_cursor_holding
    cmpwi r3, 0
    beq done
    branch r12, hide
done:
    lbz r0, -0x49A9(r13) # Original code.
