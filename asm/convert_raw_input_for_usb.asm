# ====================
#  Insert at 80377988
# ====================

.include "common.s"
.include "triples.s"

.set HID_STATUS, 0x93003440
.set HID_CTRL, 0x93005000
.set HID_PACKET_BASE, 0x930050F0

.set port_type_normal, 0x10
.set port_type_wavebird, 0x22

.set pad_size, 12
.set pad_ofst_button, 0 # 16 bits.
.set pad_ofst_left_stick_x, 2
.set pad_ofst_left_stick_y, 3
.set pad_ofst_right_stick_x, 4
.set pad_ofst_right_stick_y, 5
.set pad_ofst_left_trigger, 6
.set pad_ofst_right_trigger, 7
.set pad_ofst_triggers, 6 # 16 bits.
.set pad_ofst_unk0, 8 # 16 bits.
.set pad_ofst_err, 10
.set pad_ofst_padding, 11

# This is executed after the zero based port number is incremented.
# If r24 is 2, the game is *about* to handle port 1.
#   It is about to increment the source pointer in r25 by 68
#   and the dest pointer in r26 by 12.
# If r24 is 4 or 6, depending on context, the loop will exit.
#   4 if we aren't modifying anything.
#   6 if we are reading the extra ports.

.set reg_port_number, 24
.set reg_src_ptr,     25
.set reg_dest_ptr,    26

    # We only need to read our data and set up our pointers
    # after the game handles the first 4 ports.
    cmpwi reg_port_number, 4
    bne return

.if DEBUG
    # Dophin will crash if we try to read the HID data
    # because it resides in Wii memory.
    b set_pointers
.endif

    # Invalidate cache for all the USB data.
.macro cache_invalidate addr
    li r3, 0
    load r4, \addr
    dcbi r3, r4
    sync
.endm
    cache_invalidate HID_STATUS
    cache_invalidate HID_CTRL
    cache_invalidate HID_PACKET_BASE
    cache_invalidate (HID_PACKET_BASE + 0x10)

    loadwz r3, HID_STATUS
    cmpwi r3, 0
    beq hid_status_bad
    loadwz r3, (HID_CTRL + 0) # Vendor ID.
    cmpwi r3, 0x57E
    bne hid_status_bad
    loadwz r3, (HID_CTRL + 4) # Product ID.
    cmpwi r3, 0x337
    bne hid_status_bad
    b hid_status_ok
hid_status_bad:
    # Set both controllers to unplugged.
    load r3, triples_nintendont_data
    li r4, 0xFF
    stb r4, pad_ofst_err(r3)
    addi r3, r3, pad_size
    stb r4, pad_ofst_err(r3)
    # Skip reading HID data.
    b set_pointers
hid_status_ok:

.set reg_idx, 3
.set reg_packet, 4
.set reg_pad, 5
    li reg_idx, 0
    load reg_packet, HID_PACKET_BASE
    load reg_pad, triples_nintendont_data
loop:
    # Check plug status.
    lbz r7, 1(reg_packet)
    andi. r7, r7, port_type_normal
    cmpwi r7, port_type_normal
    beq plugged_in
    lbz r7, 1(reg_packet)
    andi. r7, r7, port_type_wavebird
    cmpwi r7, port_type_wavebird
    beq plugged_in
    # Not plugged in.
    li r7, 0xFF
    stb r7, pad_ofst_err(reg_pad)
    b loop.control
plugged_in:
    # Write 0 to the last 4 bytes of the pad,
    # which includes the error field.
    li r7, 0
    stw r7, 8(reg_pad)

    # Buttons.
    lbz r7, 2(reg_packet)
    andi. r6, r7, 0xF0 # D-pad.
    srwi r6, r6, 4
    andi. r7, r7, 0x0F # ABXY.
    slwi r7, r7, 8
    or r0, r7, r6
    lbz r7, 3(reg_packet)
    andi. r6, r7, 1 # Start.
    slwi r6, r7, 12
    or r0, r0, r6
    andi. r6, r7, 0xE # ZRL.
    slwi r6, r6, 3
    or r0, r0, r6
    sth r0, pad_ofst_button(reg_pad)

    # Sticks.
.macro convert_stick packet_offset, pad_offset
    lbz r7, \packet_offset(reg_packet)
    subi r7, 7, 0x80
    extsb r7, r7
    stb r7, \pad_offset(reg_pad)
.endm
    convert_stick 4, pad_ofst_left_stick_x
    convert_stick 5, pad_ofst_left_stick_y
    convert_stick 6, pad_ofst_right_stick_x
    convert_stick 7, pad_ofst_right_stick_y

    # Triggers.
    lhz r7, 8(reg_packet)
    sth r7, pad_ofst_triggers(reg_pad)
loop.control:
    addi reg_idx, reg_idx, 1
    addi reg_packet, reg_packet, 9
    addi reg_pad, reg_pad, pad_size
    cmpwi reg_idx, 2
    blt loop

    # Flush cash for the data we just wrote.
.macro cache_flush addr
    li r3, 0
    load r4, \addr
    dcbf r3, r4
    sync
.endm
    cache_flush triples_nintendont_data
    cache_flush (triples_nintendont_data + 0x10)
    cache_flush (triples_nintendont_data + 0x20)

set_pointers:
    # This function is about to increment this value by 12.
    load reg_src_ptr, (triples_nintendont_data - 12)
    # This function is about to increment this value by 68.
    load reg_dest_ptr, (triples_converted_output - 68)

return:
    cmpwi reg_port_number, 6 # Modified code line to scan 6 ports.
