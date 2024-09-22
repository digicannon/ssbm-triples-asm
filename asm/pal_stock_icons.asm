# ====================
#  Insert at 802F9A3C
# Modified from https://raw.githubusercontent.com/UnclePunch/slippi-ssbm-asm/master/External/PAL/Core/PAL%20Stock%20Icons.asm
# ====================

.include "common.s"
.include "triples.s"

    # If the player count is less than 5 players we will not modify the icon size.
    loadwz r3, match_player_count
    cmpwi r3, 5
    blt return
    # We are loading PAL icon size.

    bl floats
    mflr r4
    # Store X Scale.
    lwz r3,0x0(r4)
    stw r3,0x2c(r29)
    #Store Y Scale.
    stw r3,0x30(r29)
    # Load Y Offset.
    lwz r3,0x4(r4)
    stw r3,0x3C(r29)
    b return

######################################
floats:
    blrl
    .float 0.85     #x and y scale
    .float -21      #y offset
######################################

return:
    lwz r0, 0x0014(r29)
