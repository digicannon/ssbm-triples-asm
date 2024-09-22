# ====================
#  Insert at 8016E9A8
# ====================

.include "common.s"
.include "triples.s"

.set player_block, 0x80453080
.set player_block_size, 0xE90

.set reg_player_count, 3
.set reg_player, 4
    li reg_player_count, 0
    load reg_player, player_block
loop:
    # Offset 8 is player type, uint32.  Check != 3 (NONE).
    lwz r5, 8(reg_player)
    cmpwi r5, 3
    beq loop_control
    # This player is active.
    addi reg_player_count, reg_player_count, 1
loop_control:
    addi reg_player, reg_player, player_block_size
    # while (player_block <= player_block_p6)
    load r5, (player_block + (player_block_size * 5))
    cmpw reg_player, r5
    ble loop

    load r5, match_player_count
    stw reg_player_count, 0(r5)

return:
    lbz r3, 0(r31) # Original code.
