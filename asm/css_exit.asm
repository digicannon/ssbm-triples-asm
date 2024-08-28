# ====================
#  Insert at 80266CE0
# ====================

.include "common.s"
.include "triples.s"

    # Don't do anything if not on main CSS (ID 2).
    loadbz r3, 0x80479D30
    cmpi 0, r3, 2
    bne return

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
    lwz r4, 0(reg_player_data)
    lwz r5, 7(reg_player_data)
    b store
load_none:
    # These are the default values for closed player cards on the CSS.
    load r4, 0x1A030000
    load r5, 0x00090078
store:
    # Offsets 0 and 7 but +0x90 (player_size * 4).
    stw r4, 0x90(reg_player_data)
    stw r5, 0x97(reg_player_data)
control:
    addi reg_player_data, reg_player_data, player_size
    addi reg_pad_data, reg_pad_data, pad_size
    addi reg_idx, reg_idx, 1
    cmpli 0, reg_idx, 2
    blt loop

return:
    li r3, 1
