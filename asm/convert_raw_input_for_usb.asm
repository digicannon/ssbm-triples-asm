# ====================
#  Insert at 80377988
# ====================

.include "common.s"
.include "triples.s"

.set master_status, 0x804C1FAC # HSD_PadMasterStatus[4].
.set port_size, 0x44
.set port_ofst_err, 0x41

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
    # Dolphin would crash trying to read HID data.
    # Move P3/P4's raw pads to P5/P6 instead.
    load r3, triples_nintendont_data
    lwz r4, -12(reg_src_ptr)
    stw r4, 0(r3)
    lwz r4, -8(reg_src_ptr)
    stw r4, 4(r3)
    lwz r4, -4(reg_src_ptr)
    stw r4, 8(r3)
    lwz r4, 0(reg_src_ptr)
    stw r4, 12(r3)
    lwz r4, 4(reg_src_ptr)
    stw r4, 16(r3)
    lwz r4, 8(reg_src_ptr)
    stw r4, 20(r3)
    # P3 and P4 themselves read as unplugged.
    li r4, 0xFF
    load r3, master_status + 2 * port_size + port_ofst_err
    stb r4, 0(r3)
    stb r4, port_size(r3)
.else
    branchl r12, read_adapter_pads
.endif

set_pointers:
    # This function is about to increment this value by 12.
    load reg_src_ptr, (triples_nintendont_data - 12)
    # This function is about to increment this value by 68.
    load reg_dest_ptr, (triples_converted_output - 68)

return:
    cmpwi reg_port_number, 6 # Modified code line to scan 6 ports.
