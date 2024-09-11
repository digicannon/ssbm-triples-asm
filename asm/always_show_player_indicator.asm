# ====================
#  Insert at 8016CF38
# ====================

# If the match has more than 4 people alive, always show the player indicators.
# Otherwise, default to normal behavior.

.include "common.s"
.include "triples.s"

.set player_block, 0x80453080
.set player_block_size, 0xE90
.set indicator_flags, 0x804D6D70

.set match_frame_counter, 0x80479D60
.set frames_to_flicker, 210 # 3.5 seconds.

.set reg_player_count, 3
.set reg_alive_count, 4
.set reg_player, 5
    li reg_player_count, 0
    li reg_alive_count, 0
    load reg_player, player_block
loop:
    # Offset 8 is player type, uint32.  Check != 3 (NONE).
    lwz r6, 8(reg_player)
    cmpli 0, r6, 3
    beq loop_control
    # This player is active.
    addi reg_player_count, reg_player_count, 1
    # Offset 0x8E is stock count, uint8.  Check > 0.
    lbz r6, 0x8E(reg_player)
    cmpli 0, r6, 0
    beq loop_control
    # This player is alive.
    addi reg_alive_count, reg_alive_count, 1
loop_control:
    addi reg_player, reg_player, player_block_size
    # while (player_block <= player_block_p6)
    load r6, (player_block + (player_block_size * 5))
    cmpl 0, reg_player, r6
    ble loop

    # Determine the behavior we want.
    cmpli 0, reg_player_count, 5
    blt choose_default # Match has always been at most 4 players.
    cmpli 0, reg_alive_count, 5
    blt choose_fade # Match was previously more than 4 players.
    # Match is currently more than 4 players.
choose_always_show:
    # Reset timer.
    load r3, match_frames_since_indicator_switch
    li r4, 0
    stw r4, 0(r3)
    # Store write value.
    li r4, 1
    b write
choose_fade:
    # Check if we've been flickering for the max amount of frames.
    # If we have, choose default behavior instead.
    load r3, match_frames_since_indicator_switch
    lwz r4, 0(r3)
    cmpli 0, r4, frames_to_flicker
    bge choose_default
    addi r4, r4, 1
    stw r4, 0(r3)
    # Determine flicker frame.
    loadwz r4, match_frame_counter
    # Shift 2nd LSB to LSB and mask it off.
    rlwinm r4, r4, 31, 31, 31
    b write
choose_default:
    li r4, 0

write:
    load r3, indicator_flags
    stb r4, 0(r3)
    stb r4, 1(r3)
    stb r4, 2(r3)
    stb r4, 3(r3)
    stb r4, 4(r3)
    stb r4, 5(r3)

return:
    # Original code line.
    lmw r27, 0x1C(sp)
