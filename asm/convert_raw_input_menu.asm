# ====================
#  Insert at 80377998
# ====================

# DO NOT MODIFY REGISTER 23!

.include "triples.s"

# This never moves.
.set controller_data, 0x804C1FAC
.set port_size, 0x44

    # Don't do anything if not in a menu.
    lis r3, 0x8047
    ori r3, r3, 0x9D30
    lbz r4, 0(r3)
    cmpli 0, r4, 2
    blt not_in_game 
    bgt return # Unknown case.
    # Check the minor scene to see if we are in a game.
    # 2 is in game.  >2 is unknown case.
    lbz r4, 3(r3)
    cmpli 0, r4, 2
    bge return
not_in_game:

.set counter, 24
.set dest, 25
.set src, 26

    li counter, 0
    lis dest, controller_data @h
    ori dest, dest, controller_data @l
.if DEBUG
    # P3 and P4 go to P1 and P2.
    addi src, dest, 0x88
.else
    lis src, triples_converted_output @h
    ori src, src, triples_converted_output @l
.endif
loop:
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
copy_stick_ret:
    blr

return:
    mr r3, r23
