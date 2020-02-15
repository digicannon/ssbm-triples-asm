# ====================
#  Insert at 801B14B8
# ====================

    # Don't do anything if not on main CSS (ID 2).
    lis r20, 0x8047
    ori r20, r20, 0x9D30
    lbz r20, 0(r20)
    cmpi 0, r20, 2
    bne return

    # Check if CSS is dirty.
    lis r20, 0x8000
    lbz r21, 0x2901(r20)
    cmpli 0, r21, 0
    beq return
    # Set CSS state.
    li r21, 0
    stb r21, 0x2900(r20)
    stb r21, 0x2901(r20)

return:
    addi r4, r3, 0

