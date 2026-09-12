# ====================
#  Insert at 80263CC4
# ====================

.include "common.s"

    loadbz r3, css_door_count
    cmpwi r3, 4
    bne done
    li r3, 6
done:
