# ====================
#  Insert at 80263334
# ====================

.set FALSE, 0

    # Don't do anything if not on main CSS (ID 2).
    lis r5, 0x8047
    ori r5, r5, 0x9D30
    lbz r5, 0(r5)
    cmpi 0, r5, 2
    beq we_are_main_css
    # Make sure CSS state is default.
    lis r3, 0x8000
    li r4, FALSE
    stb r4, 0x2900(r3)
    b return
we_are_main_css:

    # Set match to 6 players.
    lis r3, 0x8048
    lbz r4, 0x7C0(r3)
    ori r4, r4, 0x18 # HUDCount_Six
    stb r4, 0x7C0(r3)

    sync # Good to do before reading extra ports.
    lis r3, 0x8000
    lbz r3, 0x2900(r3)
    cmpli 0, r3, FALSE
    bne css_for_56

css_for_1234:
    lis r3, 0x8000
    lhz r4, 0x2A00(r3)
    lhz r5, 0x2A0C(r3)
    or r3, r4, r5
    rlwinm r3, r3, 0, 19, 19 # Get just Start button bit.
    cmpli 0, r3, 0
    beq return

    # Either 5 or 6 has requested their CSS!
    # Step 1) Set CSS state.
    lis r3, 0x8000
    li r4, 1
    stb r4, 0x2900(r3)
    # Step 2) Backup player 1-4.
    # Character, HMN/CPU, stocks, costume.
    lis r3, 0x8048
    lwz r4, 0x0820(r3)
    lwz r5, 0x0844(r3)
    lwz r6, 0x0868(r3)
    lwz r7, 0x088C(r3)
    lis r3, 0x8000
    stw r4, 0x2910(r3)
    stw r5, 0x2918(r3)
    stw r6, 0x2920(r3)
    stw r7, 0x2928(r3)
    # Subcolor, handicap, team ID, nametag ID.
    lis r3, 0x8048
    lwz r4, 0x0827(r3)
    lwz r5, 0x084B(r3)
    lwz r6, 0x086F(r3)
    lwz r7, 0x0893(r3)
    lis r3, 0x8000
    stw r4, 0x2914(r3)
    stw r5, 0x291C(r3)
    stw r6, 0x2924(r3)
    stw r7, 0x292C(r3)
    # Step 3) Copy in P5 and P6 data.    
    lis r3, 0x8048
    li r4, 1
    stb r4, 0x08B1(r3) # Set P5 to a HMN.
    stb r4, 0x08D5(r3) # Set P6 to a HMN.
    lwz r4, 0x08B0(r3) # Load P5, now as a HMN.
    lwz r5, 0x08D4(r3) # Load P6, now as a HMN.
    stw r4, 0x0820(r3) # Store P5 in P1.
    stw r5, 0x0844(r3) # Store P6 in P2.
    # Step 4) Reset and close port 3 and 4.
    lis r4, 0x1A03
    stw r4, 0x0868(r3)
    stw r4, 0x088C(r3)
    # Step 5) Reload CSS.
    # Play menu select SFX.
    li r3, 1
    lis r14, 0x8002
    ori r14, r14, 0x4030
    mtctr r14
    bctrl
    # Blank screen.
    lis r14, 0x8022
    ori r14, r14, 0xEBDC
    mtctr r14
    bctrl
    # Reload CSS.
    li r3, 2
    lis r14, 0x801A
    ori r14, r14, 0x42F8
    mtctr r14
    bctrl
    lis r14, 0x801A
    ori r14, r14, 0x4B60
    mtctr r14
    bctrl
    b return

css_for_56:
    # Keep port 3 and 4 closed.
    lis r3, 0x8048
    lis r4, 0x1A03
    stw r4, 0x0868(r3)
    stw r4, 0x088C(r3)

return:
    lwz	r0, 0x34(sp) # Default code line.

