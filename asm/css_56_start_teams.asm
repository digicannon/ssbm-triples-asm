# ====================
#  Insert at 802630E8
# ====================

# fn_80262F44 found no two open real doors on different teams and is
# about to hide the start indicator.  Recount over all six; falling
# through returns to its teams_ok label.

.include "common.s"

.set doors, 0x803F0DFC
.set door_size, 0x24
.set players, 0x80480820
.set player_size, 0x24
.set hide, 0x802631C0

    li r3, 0 # One bit per team in use.
    load r4, doors
    li r5, 4
real:
    lbz r0, 0xB(r4) # p_kind; 3 is closed.
    cmplwi r0, 3
    beq real_next
    lbz r0, 0xA(r4) # team.
    li r6, 1
    slw r6, r6, r0
    or r3, r3, r6
real_next:
    addi r4, r4, door_size
    subi r5, r5, 1
    cmpwi r5, 0
    bne real
    load r4, players + 4 * player_size
    li r5, 2
shadow:
    lbz r0, 1(r4) # slot_type; 3 is closed.
    cmplwi r0, 1
    bgt shadow_next
    lbz r0, 9(r4) # team.
    li r6, 1
    slw r6, r6, r0
    or r3, r3, r6
shadow_next:
    addi r4, r4, player_size
    subi r5, r5, 1
    cmpwi r5, 0
    bne shadow
    subi r0, r3, 1
    and. r0, r0, r3 # Two or more teams.
    bne done
    branch r12, hide
done:
    nop
