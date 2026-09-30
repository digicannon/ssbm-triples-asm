# ====================
#  Insert at 80263064
# ====================

# fn_80262F44 has counted the open real doors into r4 and sent any open
# door without a pick to its hide path.  Add P5/P6 from the player table,
# which the shadow swap keeps current.

.include "common.s"

.set player_size, 0x24
.set hide, 0x802631C0
.set CKIND_NONE, 0x21

    test_mex r12
    li r12, CKIND_NONE
    beq count
    loadwz r12, mex_ext_count
count:
    load r5, players + 4 * player_size
    li r6, 2
loop:
    lbz r0, 1(r5) # slot_type; 3 is closed.
    cmplwi r0, 1
    bgt next
    lbz r0, 0(r5) # ckind
    cmplw r0, r12
    bge no_pick
    addi r4, r4, 1
next:
    addi r5, r5, player_size
    subi r6, r6, 1
    cmpwi r6, 0
    bne loop
    b done
no_pick:
    branch r12, hide
done:
    cmpwi r4, 2
