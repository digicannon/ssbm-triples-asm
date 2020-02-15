# ====================
#  Insert at 80377600
# ====================

# Register names.
.set port_number, 24
.set usb_data, 3

    # Don't do anything if not on main CSS (ID 2).
    lis r3, 0x8047
    ori r3, r3, 0x9D30
    lbz r3, 0(r3)
    cmpi 0, r3, 2
    beq we_are_main_css
    # We aren't main CSS!
    lis r3, 0x8000
    li r4, 0
    sth r4, 0x2900(r3) # Clear state and dirty flag.
    b return
we_are_main_css:

    # Check if CSS state is dirty.
    lis r3, 0x8000
    lbz r3, 0x2901(r3)
    cmpli 0, r3, 0
    bne return

    # Check that the CSS is for P5 and P6.
    lis r3, 0x8000
    lbz r3, 0x2900(r3)
    cmpli 0, r3, 0
    beq return

    # Convert to our data address.
    mulli usb_data, port_number, 12
    oris usb_data, usb_data, 0x8000
    addi usb_data, usb_data, 0x2A00

    # Buttons.
    lhz r4, 0(usb_data)
    stw r4, 0(r26)
    # Stick X.
    lbz r4, 0x2(usb_data)
    stb r4, 0x18(r26)
    # Stick Y.
    lbz r4, 0x3(usb_data)
    stb r4, 0x19(r26)
    # C-Stick X.
    lbz r4, 0x4(usb_data)
    stb r4, 0x1A(r26)
    # C-Stick Y.
    lbz r4, 0x5(usb_data)
    stb r4, 0x1B(r26)
    
return:
    lbz	r0, 0x001C(r30)

