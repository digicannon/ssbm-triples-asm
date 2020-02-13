# ====================
#  Insert at 8006B0DC
# ====================

.macro branchl reg, address
    lis \reg, \address @h
    ori \reg,\reg,\address @l
    mtctr \reg
    bctrl
.endm

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

# Registers.
.set player_data,    31
.set player_slot,    29
.set player_buttons, 28
.set itof_result,     31
.set itof_magic_s,    30
.set itof_magic_u,    29
.set stick_max_float, 28
.set stick_min_float, 27
.set trig_max_float,  26

    backup

    lbz player_slot, 0xC(player_data)
    # Only do for player slot 4/5 (5/6).
    cmpli 0, player_slot, 4
    blt return

    bl load_floats
    mflr r3
    lfd itof_magic_s, 0(r3)
    lfd itof_magic_u, 0x8(r3)
    lfs stick_max_float, 0x10(r3)
    lfs stick_min_float, 0x14(r3)
    lfs trig_max_float, 0x18(r3)

    lis r3, 0x4330
    stw r3, 0x90(r1)

#lwz r3, AnalogX(PlayerBackup)
#stw r3, 0x620(PlayerData) #analog X
#lwz r3, AnalogY(PlayerBackup)
#stw r3, 0x624(PlayerData) #analog Y
#lwz r3, CStickX(PlayerBackup)
#stw r3, 0x638(PlayerData) #cstick X
#lwz r3, CStickY(PlayerBackup)
#stw r3, 0x63C(PlayerData) #cstick Y
#lwz r3, Trigger(PlayerBackup)
#stw r3, 0x650(PlayerData) #trigger
#lwz r3, Buttons(PlayerBackup)
#stw r3, 0x65C(PlayerData) #buttons

#unsigned short button;
#char stickX;
#char stickY;
#char substickX;
#char substickY;
#unsigned char triggerLeft;
#unsigned char triggerRight;

    mr r4, player_slot
    subi r4, r4, 4 # Make P5 offset 0.
    mulli r4, r4, 12 # Multiply by size of Nintendont's PADStatus.
    oris r4, r4, 0x8000
    ori r4, r4, 0x2A00
    sync
read_usb:
    # Buttons.
    lhz r3, 0(r4)
    # Check for Z.
    rlwinm r5, r3, 0, 27, 27 # Z bit of r3 in r5.
    cmpli 0, r5, 0
    beq read_usb.set_buttons # If r5 is 0, skip Z macros.
    oris r3, r3, 0x8000 # Set the MSB to signal trigger press.
    ori r3, r3, 0x100   # Set A as pressed.
read_usb.set_buttons:
    mr player_buttons, r3
    # Stick X.
    lbz r3, 0x2(r4)
    bl stick_correct
    bl itof_s
    stfs itof_result, 0x620(player_data)
    # Stick Y.
    lbz r3, 0x3(r4)
    bl stick_correct
    bl itof_s
    stfs itof_result, 0x624(player_data)
    # C-Stick X.
    lbz r3, 0x4(r4)
    bl stick_correct
    bl itof_s
    stfs itof_result, 0x638(player_data)
    # C-Stick Y.
    lbz r3, 0x5(r4)
    bl stick_correct
    bl itof_s
    stfs itof_result, 0x63C(player_data)
    # Trigger.  The greater side is used.
    lbz r3, 0x6(r4) # Left trigger.
    lbz r5, 0x7(r4) # Right trigger.
    cmpl 0, r3, r5
    bgt read_usb.check_trigger
    mr r3, r5
read_usb.check_trigger:
    cmpli 0, r3, 0x4C
    blt read_usb.trigger_too_low
    # OR in buttons' MSB to signal trigger press.
    oris player_buttons, player_buttons, 0x8000
    b read_usb.set_trigger
read_usb.trigger_too_low:
    li r3, 0
read_usb.set_trigger:
    bl itof_u
    fdivs itof_result, itof_result, trig_max_float
    stfs itof_result, 0x650(player_data)
    # Finally, store buttons.
    stw player_buttons, 0x65C(player_data)

    b return

# if (v >= -28 && v <= 27)
#   v = 0;
# else if (v >= 85)
#   v = 126
# else if (v <= -86)
#   v = -127
stick_correct:    
    extsb r3, r3
    # Check for deadzone.
    cmpi 0, r3, 27
    bgt stick_correct.notdead
    cmpi 0, r3, -28
    blt stick_correct.notdead
    li r3, 0
    blr
stick_correct.notdead:
    # Check for "alive"zone.
    cmpi 0, r3, 85
    blt stick_correct.posfine
    li r3, 126
    blr
stick_correct.posfine:
    cmpi 0, r3, -86
    bgt stick_correct.ret
    li r3, -127
stick_correct.ret:
    blr

itof_s:
    cmpi 0, r3, 0
    fmr f3, stick_max_float
    blt itof_s.pos
    fmr f3, stick_min_float
itof_s.pos:
    extsb r3, r3
    xoris r3, r3, 0x8000
    stw r3, 0x94(r1)
    lfd itof_result, 0x90(r1)
    fsub itof_result, itof_result, itof_magic_s
    frsp itof_result, itof_result
    fdivs itof_result, itof_result, f3
    blr

itof_u:
    stw r3, 0x94(r1)
    lfd itof_result, 0x90(r1)
    fsub itof_result, itof_result, itof_magic_u
    frsp itof_result, itof_result
    blr

load_floats:
    blrl
    # 0x00: itof_magic_s
    .long 0x43300000
    .long 0x80000000
    # 0x08: itof_magic_u
    .long 0x43300000
    .long 0
    # 0x10: stick_max_float (127.0)
    .long 0x42FE0000
    # 0x14: stick_min_float (128.0)
    .long 0x43000000
    # 0x18: trig_max_float (255.0)
    .long 0x437F0000

return:
    restore             # Restore registers and lr.
    lbz r0, 0x2219(r31) # Default code line.

