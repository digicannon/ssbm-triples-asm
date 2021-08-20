# ====================
#  Insert at 80266B48
# ====================

    # Check if this CSS is for P5/6.
    # If not, continue as normal.
    lis r5, 0x8000
    lbz r5, 0x2900(r5)
    cmpli 0, r5, 0
    beq return

    # Only do 2 iterations.
    li r5, 2
    mtctr r5

    # Move past data for 1-4, plus an extra in case
    # r7 was 8 more than expected for 1-4.
    # Sometimes it just is.  Don't know why yet.
    # See notes for character preload.
    addi r7, r3, 8 * 5

return:
    li r5, 0 # Default code line.
    cmpwi r0, 0 # Need to recompare r0 for next conditional branch.
