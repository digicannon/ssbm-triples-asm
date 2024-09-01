# ====================
#  Insert at 8022F7D8
# ====================

.include "common.s"

    lis r3, 0x8047
	ori r3, r3, 0x9D30
	lbz r3, 0(r3)
	cmpi 0, r3, 2
    bne return_original

    li r3, 2
    branchl r4, 0x801A42F8 # Set major.
    branchl r4, 0x801A4B60 # Change sceen.
    b return

return_original:
    branchl r3, 0x802640A0 # Original function call to load CSS layout.
return:
