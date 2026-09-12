# ====================
#  Insert at 80263968
# ====================

.include "common.s"

    load r12, css_door_count
    lbz r0, 0(r12)
    cmpwi r0, 4
    bne done
    li r0, 6
done:
