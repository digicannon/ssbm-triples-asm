# ====================
#  Insert at 80377998
# ====================

# DO NOT MODIFY REGISTER 23!

.include "common.s"
.include "triples.s"

# This never moves.
.set controller_data, 0x804C1FAC
.set port_size, 0x44

    # Don't do anything if not in game.
    load r3, 0x80479D30
    lbz r4, 0(r3)
    cmpli 0, r4, 2
    blt not_in_game 
    bgt return # Unknown case.
    # Check the minor scene to see if we are in a game.
    # 0 is in character select.
    # 1 is in stage select.
    # 2 is in game.
    # 3 is in sudden death.
    # 4 is in results screen.
    lbz r4, 3(r3)
    cmpli 0, r4, 1
    bgt return # In game.
    blt not_in_game # In character select.
    # We are on stage select.
    # Don't do anything if a stage is being loaded.
    # This is to prevent P5/6 forcing 1/2 to hold A for Sheik.
    # This byte is nonzero after a stage has been selected.
    loadbz r3, 0x804D6CAF
    cmpwi r3, 0
    bne return
not_in_game:

.set counter, 24
.set dest, 25
.set src, 26

    li counter, 0
    load dest, controller_data
.if DEBUG
    # P3 and P4 go to P1 and P2.
    addi src, dest, 0x88
.else
    load src, triples_converted_output
.endif
loop:
    # Check for source controller status.
    lbz r3, 0x41(src)
    cmpli 0, r3, 0 # 0 = plugged in and OK.
    bne loop.control
    # Ensure destination controller is enabled.
    li r3, 0
    stb r3, 0x41(dest)
    # Buttons.
    lwz r3, 0(dest)
    lwz r4, 0(src)
    or r3, r3, r4
    stw r3, 0(dest)
    # Left stick.
    li r3, 0x18
    bl copy_stick
    # Right stick.
    li r3, 0x1A
    bl copy_stick
    # Did the right stick copy?
    cmpli 0, r3, 0
    beq loop.no_right_stick
    # Copy the float values for the right stick.
    # Yes, this is only to allow menu camera manipulation. :)
    # C-Stick X float.
    lwz r3, 0x28(src)
    stw r3, 0x28(dest)
    # C-Stick Y float.
    lwz r3, 0x2C(src)
    stw r3, 0x2C(dest)
loop.no_right_stick:
loop.control:
    # Loop check.  Return if !0, else add 1.
    cmpli 0, counter, 0
    bne return
    addi counter, counter, 1
    addi dest, dest, port_size
    addi src, src, port_size
    b loop

.set copy_stick_deadzone, 24

# r3 = Input data offset to copy.
# If dest[r3] is zero, dest[r3] = src[r3].
# Returns nonzero in r3 if copy occurred.
copy_stick:
    add r4, dest, r3
    add r3, src, r3
    # Check dest X is in the deadzone.
    lbz r5, 0(r4)
    extsb r5, r5
    cmpi 0, r5, -copy_stick_deadzone
    blt copy_stick_ret
    cmpi 0, r5, copy_stick_deadzone
    bgt copy_stick_ret
    # Check dest Y is in the deadzone.
    lbz r5, 1(r4)
    extsb r5, r5
    cmpi 0, r5, -copy_stick_deadzone
    blt copy_stick_ret
    cmpi 0, r5, copy_stick_deadzone
    bgt copy_stick_ret
    # Perform the copy of both X and Y.
    lhz r5, 0(r3)
    sth r5, 0(r4)
    # Return true.
    li r3, 1
    blr
copy_stick_ret:
    # Return false.
    li r3, 0
    blr

return:
    mr r3, r23
