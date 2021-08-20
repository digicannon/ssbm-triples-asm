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
    beq we_are_main_css
    # Make sure CSS state is default if not.
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
    # CSS team colors for P1 and P2.
    lis r3, 0x803F
    lbz r4, 0x0E06(r3)
    lbz r5, 0x0E2A(r3)
    lis r3, 0x8000
    stb r4, 0x2930(r3)
    stb r5, 0x2931(r3)
    # Step 3) Copy in P5 and P6 data.
    lis r3, 0x8048
    lwz r4, 0x08B0(r3) # Load P5.
    lwz r5, 0x08D4(r3) # Load P6.
    stw r4, 0x0820(r3) # Store P5 in P1.
    stw r5, 0x0844(r3) # Store P6 in P2.
    # Team colors from 5 and 6 into "1" and "2".
    lis r3, 0x8000
    lbz r4, 0x2932(r3)
    lbz r5, 0x2933(r3)
    lis r3, 0x803F
    stb r4, 0x0E06(r3)
    stb r5, 0x0E2A(r3)
    # Step 4) Reset and close port 3 and 4.
    lis r3, 0x8048
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
    # Nothing right now!

return:
    lwz	r0, 0x34(sp) # Default code line.

