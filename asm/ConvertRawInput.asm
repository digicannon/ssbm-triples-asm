# ====================
#  Insert at 80377600
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
.set usb_data, 29

    backup

    # Don't do anything if not on main CSS (ID 2).
    lis r25, 0x8047
    ori r25, r25, 0x9D30
    lbz r25, 0(r25)
    cmpi 0, r25, 2
    beq we_are_main_css
    # Make sure CSS state is default.
    lis r25, 0x8000
    li r29, 0
    stb r25, 0x2900(r3)
    b return
we_are_main_css:

    # Check that the CSS is for P5 and P6.
    lis r25, 0x8000
    lbz r25, 0x2900(r25)
    cmpli 0, r25, 0
    beq return

    # Get port number.
    mr usb_data, r26
    lis r25, 0x804C
    ori r25, r25, 0x1FAC
    sub usb_data, usb_data, r25
    li r25, 0x44
    divwu usb_data, usb_data, r25
    # Convert to our data address.
    mulli usb_data, usb_data, 12
    oris usb_data, usb_data, 0x8000
    ori usb_data, usb_data, 0x2A00

    # Buttons.
    lhz r25, 0(usb_data)
    stw r25, 0(r26)
    # Stick X.
    lbz r25, 0x2(usb_data)
    stb r25, 0x18(r26)
    # Stick Y.
    lbz r25, 0x3(usb_data)
    stb r25, 0x19(r26)
    # C-Stick X.
    lbz r25, 0x4(usb_data)
    stb r25, 0x1A(r26)
    # C-Stick Y.
    lbz r25, 0x5(usb_data)
    stb r25, 0x1B(r26)

return:
    restore
    lbz	r0, 0x001C(r30)

