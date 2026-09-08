# ====================
#  Insert at 80266BB4
# ====================

.include "common.s"
.include "triples.s"

.set lbDvd_GetPreloadCacheScene, 0x8001822C
.set lbDvd_UpdatePreloadCache, 0x80018254
.set player_size, 0x24
.set CHKIND_NONE, 0x21

    branchl r12, lbDvd_GetPreloadCacheScene
    # game_cache.entries[4] is at scene + 0x30, 8 bytes each.
    addi r5, r3, 0x30
    load r6, players + (player_size * 4)
    li r7, 2
loop:
    # slot_type: 0=HMN, 1=CPU, 3=NONE.
    lbz r4, 1(r6)
    cmplwi r4, 1
    li r3, CHKIND_NONE
    bgt store
    lbz r3, 0(r6)
    extsb r3, r3
    lbz r4, 3(r6)
    stb r4, 4(r5)
store:
    stw r3, 0(r5)
    addi r5, r5, 8
    addi r6, r6, player_size
    subi r7, r7, 1
    cmpwi r7, 0
    bne loop

return:
    branchl r12, lbDvd_UpdatePreloadCache
