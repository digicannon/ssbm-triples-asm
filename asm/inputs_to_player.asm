# ====================
#  Insert at 8006B028
# ====================

.include "triples.s"

# Registers.
.set player_data,    31

    stw r0, 0x065C(r31) # Default code line.

    lbz r4, 0xC(player_data)
    # Only do anything for player 5 and 6.
    cmpli 0, r4, 4
    blt return

    subi r4, r4, 4 # Make P5 offset 0.
    mulli r4, r4, 0x44 # Multiply by size of input struct.
    oris r4, r4, triples_converted_output @h
    ori r4, r4, triples_converted_output @l
    sync
read_usb:
    # Load buttons.
    lwz r3, 0(r4)
    stw r3, 0x65C(player_data)
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
    cmpl 0, r5, r3
    bgt read_usb.load_rtrig
read_usb.load_ltrig:
    cmpli 0, r3, 0x4C
    blt read_usb.store_trig_zero
    lwz r3, 0x30(r4)
    b read_usb.store_trig
read_usb.load_rtrig:
    cmpli 0, r5, 0x4C
    blt read_usb.store_trig_zero
    lwz r3, 0x34(r4)
    b read_usb.store_trig
read_usb.store_trig_zero:
    li r3, 0
read_usb.store_trig:
    stw r3, 0x650(player_data)

return:
