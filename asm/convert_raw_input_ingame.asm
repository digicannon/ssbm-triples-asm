# ====================
#  Insert at 80377988
# ====================

# This is executed after the zero based port number is incremented.
# If r24 is 2, the game is *about* to handle port 1.
#   It is about to increment the source pointer in r25 by 68
#   and the dest pointer in r26 by 12.
# If r24 is 4 or 6, depending on context, the loop will exit.
#   4 if we aren't modifying anything.
#   6 if we are reading the extra ports.

# Register names.
.set port_number, 24
.set src_ptr,     25
.set dest_ptr,    26

# Our space for USB data.
# The game is about to increment this value by 12.
.set OUR_SRC_ADDR, 0x80002A00 - 12
# Our space for P5 and P6.
# The game is about to increment this value by 68.
.set OUR_DEST_ADDR, 0x80002800 - 68

    # We only need to set up our pointers after
    # the game handles the first 4 ports.
    cmpwi port_number, 4
    bne return

    lis src_ptr, OUR_SRC_ADDR@h
    ori src_ptr, src_ptr, OUR_SRC_ADDR@l

    lis dest_ptr, OUR_DEST_ADDR@h
    ori dest_ptr, dest_ptr, OUR_DEST_ADDR@l

return:
    cmpwi port_number, 6 # Modified code line to scan 6 ports.
