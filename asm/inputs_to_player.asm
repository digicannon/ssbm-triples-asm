# ====================
#  Insert at 8006B0DC
# ====================

.macro backup
    mflr r0
    stw r0, 0x4(r1)
    stwu r1, -0xB0(r1)
    stmw r20, 0x8(r1)
.endm

.macro restore
    lmw r20, 0x8(r1)
    lwz r0, 0xB4(r1)
    addi r1, r1, 0xB0
    mtlr r0
.endm

# Registers.
.set player_data,    31
.set player_slot,    29
.set player_buttons, 28

    backup

    lbz player_slot, 0xC(player_data)
    # Only do for player slot 4/5 (5/6).
    cmpli 0, player_slot, 4
    blt return

    # Read "raw" USB data converted by the game.
    mr r4, player_slot
    subi r4, r4, 4 # Make P5 offset 0.
    mulli r4, r4, 0x44 # Multiply by size of input struct.
    oris r4, r4, 0x8000
    ori r4, r4, 0x2800
    sync
read_usb:
    # Load buttons.
    lwz player_buttons, 0(r4)
    rlwinm r3, player_buttons, 0, 27, 27
    cmpli 0, r3, 0
    beq read_usb.no_z # If no Z, skip Z macros.
    oris player_buttons, player_buttons, 0x8000 # Set trigger press.
    ori player_buttons, player_buttons, 0x100   # Set A as pressed.
read_usb.no_z:
    # Stick X.
    lwz r3, 0x20(r4)
    stw r3, 0x620(player_data)
    # Stick Y.
    lwz r3, 0x24(r4)
    stw r3, 0x624(player_data)
    # C-Stick X.
    lwz r3, 0x28(r4)
    stw r3, 0x638(player_data)
    # C-Stick Y.
    lwz r3, 0x2C(r4)
    stw r3, 0x63C(player_data)
    # Trigger.  The greater side is used.
    lbz r3, 0x1C(r4) # Left trigger.
    lbz r5, 0x1D(r4) # Right trigger.
    # r3 will contain greater float, r5 will contain greater byte.
    cmpl 0, r5, r3
    bgt read_usb.load_rtrig
    mr r5, r3
    lwz r3, 0x30(r4)
    b read_usb.store_trig
read_usb.load_rtrig:
    lwz r3, 0x34(r4)
read_usb.store_trig:
    stw r3, 0x650(player_data)
    cmpli 0, r5, 0x4C
    blt read_usb.no_trig_flag
    oris player_buttons, player_buttons, 0x8000
read_usb.no_trig_flag:
    # Finally, store buttons.
    stw player_buttons, 0x65C(player_data)

    b return

return:
    restore             # Restore registers and lr.
    lbz r0, 0x2219(r31) # Default code line.
