# ====================
#  Insert at 80266830
# ====================

.include "common.s"

    loadbz r12, css_door_count
    cmpwi r12, 4
    bne return
    stwu r1, -0x10(r1)
    stw r3, 8(r1) # The function's return value.
    branchl r12, css_rescale_doors
    branchl r12, css_door_texts_remake
    branchl r12, css_56_create
    branchl r12, css_name_boxes
    branchl r12, css_door_buttons_create
    branchl r12, css_cursor_grab_create
    lwz r3, 8(r1)
    addi r1, r1, 0x10
return:
    lmw r17, 0x11C(r1) # Original code.
