# ====================
#  Insert at 8006AF10
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
    addis r3, r3, match_players @h
    addi r3, r3, match_players @l
    lwz r3, match_player_ofst_kind(r3)
    cmpwi r3, PKIND_HUMAN
    bne return

    subi r4, r4, 4 # Make P5 offset 0.
    mulli r4, r4, pad_size
    oris r4, r4, triples_converted_output @h
    ori r4, r4, triples_converted_output @l
    sync

    # Stick X and Y.
    lwz r3, 0x20(r4)
    stw r3, 0x620(player_data)
    lwz r3, 0x24(r4)
    stw r3, 0x624(player_data)
    # C-Stick X and Y.
    lwz r3, 0x28(r4)
    stw r3, 0x638(player_data)
    lwz r3, 0x2C(r4)
    stw r3, 0x63C(player_data)

    # Trigger.  The greater side is used.
    lwz r3, 0x30(r4)
    lwz r0, 0x34(r4)
    cmplw 0, r0, r3
    ble store_trigger
    mr r3, r0
store_trigger:
    stw r3, 0x650(player_data)

return:
    lfs f1, 0x620(player_data) # Original code.
