# ====================
#  Insert at 80263334
# ====================

    lis r3, 0x8048
    # Set match to 6 players.
    lbz r4, 0x7C0(r3)
    ori r4, r4, 0x18 # HUDCount_Six
    stb r4, 0x7C0(r3)
    # Copy player data.
    lwz r4, 0x0820(r3) # Load P1's values.
    stw r4, 0x08B0(r3) # Copy to P5.
    stw r4, 0x08D4(r3) # Copy to P6.
    li r4, 1 # CPU
    stb r4, 0x08B1(r3) # Set P5 to a CPU.
    stb r4, 0x08D5(r3) # Set P6 to a CPU.

return:
    lwz	r0, 0x34(sp) # Default code line.
