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
    #lis r5, 0x8047
    #ori r5, r5, 0x9D30
    #lbz r5, 0(r5)
    #cmpi 0, r5, 2
    #bne return

    # Check if this CSS was for P5/6.
    # If not, no data movement required.
    #lis r3, 0x8000
    #lbz r4, 0x2900(r3)
    #cmpli 0, r4, 0
    #beq player_data_ok

    # Move "P1" data to P5.
    lis r3, 0x8048
    lwz r4, 0x0820(r3)
    lwz r5, 0x0827(r3)
    stw r4, 0x08B0(r3)
    stw r5, 0x08B7(r3)
    # Move "P2" data to P6.
    lwz r4, 0x0844(r3)
    lwz r5, 0x084B(r3)
    stw r4, 0x08D4(r3)
    stw r5, 0x08DB(r3)
    # Backup "P1" and "P2" CSS team colors for 5 and 6.
    #lis r3, 0x803F
    #lbz r4, 0x0E06(r3)
    #lbz r5, 0x0E2A(r3)
    #lis r3, 0x8000
    #stb r4, 0x2932(r3)
    #stb r5, 0x2933(r3)
    # Restore CSS team colors for P1 and P2.
    #lis r3, 0x8000
    #lbz r4, 0x2930(r3)
    #lbz r5, 0x2931(r3)
    #lis r3, 0x803F
    #stb r4, 0x0E06(r3)
    #stb r5, 0x0E2A(r3)
    # Bring player 1-4 data back to their proper location.
    # Character, HMN/CPU, stocks, costume.
    #lis r3, 0x8000
    #lwz r4, 0x2910(r3)
    #lwz r5, 0x2918(r3)
    #lwz r6, 0x2920(r3)
    #lwz r7, 0x2928(r3)
    #lis r3, 0x8048
    #stw r4, 0x0820(r3)
    #stw r5, 0x0844(r3)
    #stw r6, 0x0868(r3)
    #stw r7, 0x088C(r3)
    # Subcolor, handicap, team ID, nametag ID.
    #lis r3, 0x8000
    #lwz r4, 0x2914(r3)
    #lwz r5, 0x291C(r3)
    #lwz r6, 0x2924(r3)
    #lwz r7, 0x292C(r3)
    #lis r3, 0x8048
    #stw r4, 0x0827(r3)
    #stw r5, 0x084B(r3)
    #stw r6, 0x086F(r3)
    #stw r7, 0x0893(r3)
player_data_ok:

return:
    restore
    li r3, 1
