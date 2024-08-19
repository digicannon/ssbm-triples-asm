# ====================
#  Insert at 80263334
# ====================

.include "triples.s"

.set FALSE, 0

    # Don't do anything if not on main CSS (ID 2).
    lis r5, 0x8047
    ori r5, r5, 0x9D30
    lbz r5, 0(r5)
    cmpi 0, r5, 2
    bne return

    # Set match to 6 players.
    lis r3, 0x8048
    lbz r4, 0x7C0(r3)
    ori r4, r4, 0x18 # HUDCount_Six
    stb r4, 0x7C0(r3)

return:
    lwz	r0, 0x34(sp) # Default code line.
