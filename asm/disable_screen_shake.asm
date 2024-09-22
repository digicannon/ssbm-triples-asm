# ====================
#  Insert at 80030E44
# ====================

.include "common.s"
.include "triples.s"

    # Enabled if not teams.
    lis r7, 0x8048
    lbz r7, 0x07C8(r7)
    cmpwi r7, 0
    beq return
    # Enabled if match has less than 5 players.
    loadwz r7, match_player_count
    cmpwi r7, 5
    blt return
    # Disabled.  Return early out of the screen shake func.
    blr
return:
    mflr r0 # Original code.
