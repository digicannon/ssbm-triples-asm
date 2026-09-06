# ====================
#  Insert at 80017BFC
# ====================

# lbDvd_CachePreloadedFile, at the heap allocation.
# If we can't cache the file just drop it so its loaded from disc later.
# Default behavior is to crash.
#
# r3 = heap, r4 = size rounded to 32, r25 = entry index.

.include "common.s"

.set lbMemory_FreeBytes, 0x80014F7C
.set lbDvd_DropEntry, 0x800174E8
.set lbDvd_CacheNext, 0x80017CC4
.set lbHeap_Alloc, 0x80015BD0
.set heap_array, 0x80431FA0 + 0x10
.set heap_size, 0x1C
.set epilogue, 0x80017CB0
.set slack, 0x100 # HSD_Archive plus alignment.

    mr r29, r3
    mr r30, r4
    # Only AllM and AllA.  Stay is sized to fit its files exactly.
    cmpwi r29, 4
    blt alloc
    mulli r0, r29, heap_size
    load r5, heap_array
    add r5, r5, r0
    lwz r0, 0x10(r5)
    cmpwi r0, 0
    beq alloc # HSD heap, no handle to query.
    lwz r3, 4(r5)
    branchl r12, lbMemory_FreeBytes
    addi r0, r30, slack
    cmplw r3, r0
    bge alloc
    mr r3, r25
    branchl r12, lbDvd_DropEntry
    branchl r12, lbDvd_CacheNext
    branch r12, epilogue
alloc:
    mr r3, r29
    mr r4, r30

return:
    branchl r12, lbHeap_Alloc
