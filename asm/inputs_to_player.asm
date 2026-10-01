# ====================
#  Insert at 8006B028
# ====================

.include "triples.s"

.set player_data, 31

.set pad_size, 0x44
.set match_player_size, 0xE90
.set match_player_ofst_kind, 8
.set PKIND_HUMAN, 0

    lbz r4, 0xC(player_data)
    # Only do anything for player 5 and 6.
    cmpli 0, r4, 4
    blt return

    # Only do anything for human player kind.
    mulli r3, r4, match_player_size
    addis r3, r3, player_slots @h
    addi r3, r3, player_slots @l
    lwz r3, match_player_ofst_kind(r3)
    cmpwi r3, PKIND_HUMAN
    bne return

    subi r4, r4, 4 # Make P5 offset 0.
    mulli r4, r4, pad_size
    oris r4, r4, triples_converted_output @h
    ori r4, r4, triples_converted_output @l
    sync

    lwz r0, 0(r4)

return:
    stw r0, 0x065C(player_data) # Original code.
