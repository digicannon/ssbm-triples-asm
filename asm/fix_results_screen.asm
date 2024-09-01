# ====================
#  Insert at 8016EBA8
# ====================

.include "common.s"

.set results_block, 0x80479DFC
.set results_block_size, 0xA8
# struct ResultsBlock {
#     // uint32 offset 0
#     uint8 player_type;
#     uint8 char_external_id;
#     uint8 char_internal_id;
#     uint8 costume_id; // Totally separate from team!
#     // uint32 offset 4
#     uint8 result_type? always 0x78 when player present.
#     uint8 placement; // 0 is 1st, 1 is 2nd, etc.
#     uint8 placement again?
#     uint8 team_id;
# };
.set rb_player_type, 0
.set rb_char_ext_id, 1
.set rb_char_int_id, 2
.set rb_char_costume_id, 3
.set rb_result_type, 4
.set rb_placement, 5
.set rb_sub_placement, 6
.set rb_team_id, 7

.set result_block_p5, 0x8047A09C
.set result_block_p6, 0x8047A144

.set player_type_cpu, 1
.set player_type_inactive, 3

# ===============================================
# Ensure everyone's placement is in bounds [0,3].
# ===============================================

.set reg_result, 3
.set reg_idx, 4
.set reg_temp, 7
    li reg_idx, 0
placement_bounds_check:
    load reg_result, results_block
    mulli reg_temp, reg_idx, results_block_size
    add reg_result, reg_result, reg_temp
    # Did this player get worse than 4th place?
    # Remember that placement is 0-based.
    lbz reg_temp, rb_placement(reg_result)
    cmpli 0, reg_temp, 4 # Logical comparison here ensures it cannot be negative.
    blt placement_bounds_check.continue
    li reg_temp, 3 # 4th place.
    stb reg_temp, rb_placement(reg_result)
    stb reg_temp, rb_sub_placement(reg_result)
placement_bounds_check.continue:
    addi reg_idx, reg_idx, 1
    cmpi 0, reg_idx, 6 # All six players must be checked.
    blt placement_bounds_check

# =================
# Begin copy check.
# =================

    # Skip teams logic if not in teams mode.
    lis r3, 0x8048
    lbz r3, 0x7C8(r3)
    cmpli 0, r3, 0
    bne teams_mode

# ========================
# Begin free for all mode.
# ========================

    # Check if player 5 is active and won.
    load r3, results_block # P1 block.
    load r4, result_block_p5
    lbz r5, rb_player_type(r4)
    cmpli 0, r5, player_type_inactive
    beq ffa_skip5
    lbz r5, rb_placement(r4)
    cmpli 0, r5, 0
    beq ffa_copy
ffa_skip5:

    # Check if player 6 is active and won.
    load r3, results_block + results_block_size # P2 block.
    load r4, result_block_p6
    lbz r5, rb_player_type(r4)
    cmpli 0, r5, player_type_inactive
    beq ffa_skip6
    lbz r5, rb_placement(r4)
    cmpli 0, r5, 0
    beq ffa_copy
ffa_skip6:

    # Neither player won, no copy required.
    b return

    # r3 = Address of destination player block.
    # r4 = Address of winning player block.
ffa_copy:
    li r5, results_block_size # size
    branchl r6, memcpy
    # Set the replacement to a CPU so nobody has to press start for it.
    # It would be unclear who is in control, the replaced controller or player 5/6?
    # memcpy leaves r3, the destination, untouched.
    li r4, player_type_cpu
    stb r4, rb_player_type(r3)

    b return

# =================
# Begin teams mode.
# =================

.set reg_result, 3
.set reg_idx, 4
.set reg_winning_team, 5
.set reg_replace_ptr, 6
.set reg_temp, 7

.macro idx_to_result_ptr
    load reg_result, results_block
    mulli reg_temp, reg_idx, results_block_size
    add reg_result, reg_result, reg_temp
.endm

    # Find the winning team ID by finding the player in 1st place and saving their team ID.

teams_mode:
    li reg_idx, 0
    li reg_winning_team, 0
find_winner:
    idx_to_result_ptr
    # Is this player active?
    lbz reg_temp, rb_player_type(reg_result)
    cmpli 0, reg_temp, player_type_inactive
    beq find_winner.continue
    # Did this player get 1st place?
    lbz reg_temp, rb_placement(reg_result)
    cmpli 0, reg_temp, 0
    bne find_winner.continue
    # This player got 1st place and is therefore on the winning team.
    lbz reg_winning_team, rb_team_id(reg_result)
    b find_winner.exit
find_winner.continue:
    addi reg_idx, reg_idx, 1
    cmpi 0, reg_idx, 6 # All six players must be checked.
    blt find_winner
find_winner.exit:

    # Find a player slot in 1-4 that is either inactive or on the losing team.
    # They will be replaced by either player 5 or 6 should one of them be on the winning team.

    li reg_idx, 0
    li reg_replace_ptr, 0
find_replace:
    idx_to_result_ptr
    # Is this player active?
    # If not, select this slot even if one was already selected.
    lbz reg_temp, rb_player_type(reg_result)
    cmpli 0, reg_temp, player_type_inactive
    bne find_replace.check_team
    # Mark this player for replacement and exit.
    # We always take the opportunity to replace an empty slot.
    mr reg_replace_ptr, reg_result
    b find_replace.exit
find_replace.check_team:
    # If a replacement has not been selected already,
    # and this player is not on the winning team,
    # select this slot for replacement.
    cmpli 0, reg_replace_ptr, 0
    bne find_replace.continue
    lbz reg_temp, rb_team_id(reg_result)
    cmpl 0, reg_temp, reg_winning_team
    beq find_replace.continue
    # Mark this player for replacement.
    mr reg_replace_ptr, reg_result
find_replace.continue:
    addi reg_idx, reg_idx, 1
    cmpi 0, reg_idx, 4
    blt find_replace
find_replace.exit:

    # Copy either player 5 or 6 if one of them is on the winning team.

    cmpli 0, reg_replace_ptr, 0
    beq return # No replacement slot is available.
    li reg_idx, 4 # Start at player 5.
copy_loop:
    idx_to_result_ptr
    # Is this player active?
    lbz reg_temp, rb_player_type(reg_result)
    cmpli 0, reg_temp, player_type_inactive
    beq copy_loop.continue
    # Is this player on the winning team?
    lbz reg_temp, rb_team_id(reg_result)
    cmpl 0, reg_temp, reg_winning_team
    bne copy_loop.continue
    # Copy them to the replacement index and exit.
    mr r4, reg_result # src
    mr r3, reg_replace_ptr # dest
    li r5, results_block_size # size
    branchl r6, memcpy
    # Set the replacement to a CPU so nobody has to press start for it.
    # It would be unclear who is in control, the replaced controller or player 5/6?
    # memcpy leaves r3, the destination, untouched.
    li r4, player_type_cpu
    stb r4, rb_player_type(r3)
    b return
copy_loop.continue:
    addi reg_idx, reg_idx, 1
    cmpli 0, reg_idx, 6
    blt copy_loop

# =================================================
# Begin shared code between teams and free for all.
# =================================================

return:
    # Always delete players 5 and 6 to prevent a crash.

    # Player 5, zero.
    load r3, result_block_p5
    li r4, results_block_size
    branchl r5, Zero_AreaLength
    # Player 5, store inactive player type.
    load r3, result_block_p5
    li r4, player_type_inactive
    stb r4, rb_player_type(r3)

    # Player 6, zero.
    load r3, result_block_p6
    li r4, results_block_size
    branchl r5, Zero_AreaLength
    # Player 6, store inactive player type.
    load r3, result_block_p6
    li r4, player_type_inactive
    stb r4, rb_player_type(r3)

    # Original code line.
    lwz	r0, 0x001C(sp)
