# ====================
#  Insert at 802F9A3C
# Modified from https://raw.githubusercontent.com/UnclePunch/slippi-ssbm-asm/master/External/PAL/Core/PAL%20Stock%20Icons.asm
# ====================

.include "common.s"

.set player_block, 0x80453080
.set player_block_size, 0xE90

.set reg_player_count, 3
.set reg_player, 4
    li reg_player_count, 0
    load reg_player, player_block
loop:
    # Offset 8 is player type, uint32.  Check != 3 (NONE).
    lwz r5, 8(reg_player)
    cmpli 0, r5, 3
    beq loop_control
    # This player is active.
    addi reg_player_count, reg_player_count, 1
loop_control:
    addi reg_player, reg_player, player_block_size
    # while (player_block <= player_block_p6)
    load r5, (player_block + (player_block_size * 5))
    cmpl 0, reg_player, r5
    ble loop

    # If the player count is less than 5 players we will not modify the icon size.
    cmpli 0, reg_player_count, 5
    blt return
    # We are loading PAL icon size.

    bl floats
    mflr r4
    # Store X Scale.
    lwz r3,0x0(r4)
    stw r3,0x2c(r29)
    #Store Y Scale.
    stw r3,0x30(r29)
    # Load Y Offset.
    lwz r3,0x4(r4)
    stw r3,0x3C(r29)
    b return

######################################
floats:
    blrl
    .float 0.85     #x and y scale
    .float -21      #y offset
######################################

return:
    lwz	r0, 0x0014(r29)
