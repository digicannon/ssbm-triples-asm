# ====================
#  Insert at 80266CE0
# ====================

.macro backup
    mflr r0
    stw r0, 0x4(r1)
    stwu r1, -0xB0(r1)
    stmw r20, 0x8(r1)
.endm

.macro restore
    lmw r20, 0x8(r1)
    lwz r0, 0xB4(r1)
    addi r1, r1, 0xB0
    mtlr r0
.endm

# Register names.

    backup

    # Don't do anything if not on main CSS (ID 2).
    lis r5, 0x8047
    ori r5, r5, 0x9D30
    lbz r5, 0(r5)
    cmpi 0, r5, 2
    bne return

    lis r3, 0x8000
    lbz r4, 0x2900(r3)
    cmpli 0, r4, 0
    beq player_data_ok
    # Set CSS state.
    li r4, 0
    stb r4, 0x2900(r3)
    # Move P1 and P2 data to P5 and P6.
    lis r3, 0x8048
    lwz r4, 0x0820(r3)
    lwz r5, 0x0844(r3)
    stw r4, 0x08B0(r3)
    stw r5, 0x08D4(r3)
    # Make P5 and P6 a CPU type; some tables only go to P4.
    li r4, 1
    stb r4, 0x08B1(r3)
    stb r4, 0x08D5(r3)
    # Bring player 1-4 data back to their proper location.
    lis r3, 0x8000
    lwz r4, 0x2910(r3)
    lwz r5, 0x2914(r3)
    lwz r6, 0x2918(r3)
    lwz r7, 0x291C(r3)
    lis r3, 0x8048
    stw r4, 0x0820(r3)
    stw r5, 0x0844(r3)
    stw r6, 0x0868(r3)
    stw r7, 0x088C(r3)
player_data_ok:

    lis r3, 0x8048
    lis r4, 0x8043
    li r5, 0
update_preload_table:
    # Store character ID.
    lbz r6, 0x0820(r3)
    extsb r6, r6
    stw r6, 0x208C(r4)
    # Store costume ID.
    lbz r6, 0x0823(r3)
    stb r6, 0x2090(r4)
    # Loop.
    addi r3, r3, 0x24
    addi r4, r4, 0x08
    addi r5, r5, 1
    cmpli 0, r5, 6
    blt update_preload_table

    # Preload data.
    lis r3, 0x8001
    ori r3, r3, 0x8254
    mtctr r3
    bctrl

return:
    restore
    li r3, 1
