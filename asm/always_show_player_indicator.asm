# ====================
#  Insert at 8016CF38
# ====================

# If the match has more than 4 people alive, always show the player indicators.
# Otherwise, default to normal behavior.

.set player_block, 0x80453080
.set player_block_size, 0xE90
.set indicator_flags, 0x804D6D70

.set reg_alive_count, 3
.set reg_idx, 4
.set reg_player, 5
    li reg_idx, 0
    li reg_alive_count, 0
loop:
    lis reg_player, player_block @h
    ori reg_player, reg_player, player_block @l
    mulli r6, reg_idx, player_block_size
    add reg_player, reg_player, r6
    # Offset 8 is player type, uint32.  Check != 3 (NONE).
    lwz r6, 8(reg_player)
    cmpli 0, r6, 3
    beq loop_control
    # Offset 0x8E is stock count, uint8.  Check > 0.
    lbz r6, 0x8E(reg_player)
    cmpli 0, r6, 0
    beq loop_control
    # This player is alive.
    addi reg_alive_count, reg_alive_count, 1
loop_control:
    addi reg_idx, reg_idx, 1
    cmpli 0, reg_idx, 6
    blt loop

    # Determine the behavior we want.
    cmpli 0, reg_alive_count, 5
    blt choose_default
choose_always_show:
    lis r4, 0x0101
    ori r4, r4, 0x0101
    b write
choose_default:
    li r4, 0

write:
    lis r3, indicator_flags @h
    ori r3, r3, indicator_flags @l
    stw r4, 0(r3)
    sth r4, 4(r3)

return:
    # Original code line.
    lmw	r27, 0x1C(sp)
