# ====================
#  Insert at 80263334
# ====================

.include "common.s"
.include "triples.s"

    b begin

default_card_data:
    blrl
    .long 0x1A030000
    .long 0x00FF0000
    .long 0x09007800

begin:
    # Don't do anything if not on main CSS (ID 2).
    loadbz r3, 0x80479D30
    cmpi 0, r3, 2
    bne return

    # Reset the HUD to the default 4 players.
    # The loop below will expand it if this match requires it.
    lis r4, 0x8048
    lbz r5, 0x7C0(r4)
    andi. r5, r5, 0xF7 # Mask off 8.
    stb r5, 0x7C0(r4)

.set player_size, 0x24

.set pad_size, 0x44
.set pad_offset_error, 0x41
.set pad_err_ok, 0
.set pad_err_no_controller, 0xFF

.set reg_player_data, 3
.set reg_pad_data, 6
.set reg_idx, 7

    # Offset 0: Character, HMN/CPU, stocks, costume.
    # Offset 7: Subcolor, handicap, team ID, nametag ID.

    load reg_player_data, 0x80480820
    load reg_pad_data, triples_converted_output
    li reg_idx, 0
loop:
    # Check if controller is plugged in.
    lbz r4, pad_offset_error(reg_pad_data)
    cmpli 0, r4, pad_err_ok
    bne load_none
    # Set source player data pointer.
    mr r4, reg_player_data
    b store
load_none:
    bl default_card_data
    mflr r4
store:
    # Dest is offset by (player_size * 4), 0x90.
    lwz r5, 0(r4)
    stw r5, 0x90(reg_player_data)
    lwz r5, 4(r4)
    stw r5, 0x94(reg_player_data)
    lwz r5, 8(r4)
    stw r5, 0x98(reg_player_data)
    # If the player being stored is active, expand the HUD to 6 slots.
    # We check this instead of the controller status because p5/p6 may not be playing.
    lbz r4, 0x91(reg_player_data)
    cmpli 0, r4, 3 # 3=NONE.
    beq control
    # Expand the HUD to 6 slots.
    lis r4, 0x8048
    lbz r5, 0x7C0(r4)
    ori r5, r5, 8 # Bitmask for 6 players.
    stb r5, 0x7C0(r4)
control:
    addi reg_player_data, reg_player_data, player_size
    addi reg_pad_data, reg_pad_data, pad_size
    addi reg_idx, reg_idx, 1
    cmpli 0, reg_idx, 2
    blt loop

return:
    lwz r0, 0x34(r1)
