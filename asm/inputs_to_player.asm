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
    cmpl 0, r3, r5
    bgt read_usb.load_rtrig
    lwz r3, 0x30(r4)
    b read_usb.store_trig
read_usb.load_rtrig:
    lwz r3, 0x34(r4)
read_usb.store_trig:
    stw r3, 0x650(player_data)
    # Finally, store buttons.
    lwz r3, 0(r4)
    stw r3, 0x65C(player_data)

    b return

return:
    restore             # Restore registers and lr.
    lbz r0, 0x2219(r31) # Default code line.
