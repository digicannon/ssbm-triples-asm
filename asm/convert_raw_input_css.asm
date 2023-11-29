# ====================
#  Insert at 80377600
# ====================

.include "triples.s"

# Register names.
.set port_number, 24
.set usb_data, 3

# Debug start P5 door animation
#load r3, 0x804C1FAC
#lwz r4, 0(r3)
#lwz r5, 4(r3)
#rwlimi r4, r4, 0, 0x100, 0x100

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

.if DEBUG
    # Convert to our data address.
    mulli usb_data, port_number, 12
    oris usb_data, usb_data, 0x8000
    addi usb_data, usb_data, 0x2A00
    # For debug, if P1/2 presses Z register a Start press for P5/6.
    cmpli 0, port_number, 2
    bge debug_after_z
    lwz r4, 0(r26)
    cmpli 0, r4, BTN_MASK_Z
    bne debug_no_z
    # Store all Fs in extra port.
    lis r4, 0xFFFF
    ori r4, r4, 0xFFFF
    stw r4, 0(usb_data)
    b debug_after_z
debug_no_z:
    # Zero-out extra port.
    li r4, 0
    stw r4, 0(usb_data)
debug_after_z:
.else
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
.endif
    
return:
    lbz	r0, 0x001C(r30)

