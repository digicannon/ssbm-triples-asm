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
#     uint8 placement; // 0 if winning team, 1 if 2nd place, etc.
#     uint8 subplacement?
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

.set player_type_inactive, 3

    # Skip teams logic if not in teams mode.
    lis r3, 0x8048
    lbz r3, 0x7C8(r3)
    cmpli 0, r3, 0
    beq return

    # Find winning team.

    .set reg_result, 3
    .set reg_idx, 4
    .set reg_replace_ptr, 5
    .set reg_temp, 6

    li reg_idx, 0
    li reg_replace_ptr, 0
loop:
    load reg_result, results_block
    mulli reg_temp, reg_idx, results_block_size
    add reg_result, reg_result, reg_temp
    # Is this person on the winning team?
    lbz reg_temp, rb_placement(reg_result)
    cmpli 0, reg_temp, 0
    beq loop.control
    # This player is on a losing team.
    # The first losing player will be available for replacement.
    mr reg_replace_ptr, reg_result
    b loop.exit
loop.control:
    addi reg_idx, reg_idx, 1
    cmpli 0, reg_idx, 4
    blt loop
loop.exit:

    # Now we see if either p5 or p6 should be copied.
    cmpli 0, reg_replace_ptr, 0
    beq return # No replacement slot is available.
copy_loop:
    load reg_result, results_block
    mulli reg_temp, reg_idx, results_block_size
    add reg_result, reg_result, reg_temp
    # Is this person on the winning team?
    lbz reg_temp, rb_placement(reg_result)
    cmpli 0, reg_temp, 0
    bne copy_loop.control
    # Copy them to the replacement index and exit.
    mr r4, reg_result # src
    mr r3, reg_replace_ptr
    li r5, results_block_size # size
    branchl r6, memcpy
    b return
copy_loop.control:
    addi reg_idx, reg_idx, 1
    cmpli 0, reg_idx, 6
    blt copy_loop

return:
    # Always delete players 5 and 6 to prevent a crash.
.set result_block_p5, 0x8047A09C
.set result_block_p6, 0x8047A144

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
