# ====================
#  Insert at 802FCC9C
# ====================

# If the match has more than 4 people alive, always show the player indicator.
# Otherwise, default to normal behavior.

# Return r0 as true (nonzero) for always visible.
# Return r0 as false for normal control.

.set player_block, 0x80453080
.set player_block_p6, 0x80457950

.set player_block_size, 0xE90
.set player_block_size_of_6, player_block_size * 6

.set alive_count, 3
.set reg_idx, 6
    li reg_idx, 0
    li alive_count, 0
loop:
    lis r4, player_block @h
    ori r4, r4, player_block @l
    mulli r5, reg_idx, player_block_size
    add r4, r4, r5
    # Offset 8 is player type, uint32.  Check != 3 (NONE).
    lwz r5, 8(r4)
    cmpli 0, r5, 3
    beq loop_control
    # Offset 0x8E is stock count, uint8.  Check > 0.
    lbz r5, 0x8E(r4)
    cmpli 0, r5, 0
    beq loop_control
    # This player is alive.
    addi alive_count, alive_count, 1
loop_control:
    addi reg_idx, reg_idx, 1
    cmpli 0, reg_idx, 6
    blt loop

return:
    cmpli 0, alive_count, 5
    blt return_original
    li r0, 1
    b return_exit
return_original:
    lbz	r3, 0(r31)
    subi r4, r13, 18736
    lbzx r0, r4, r3
return_exit:
