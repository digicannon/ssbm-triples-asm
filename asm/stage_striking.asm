# ====================
#  Insert at 80259C40
# ====================

.include "common.s"

    test_mex r3
    bne return

    # Begin original [Sham Rock, Dan Salvato] code.
    .long 0x39600000
    .long 0x3D408045
    .long 0x614AC388
    .long 0x38600000
    .long 0x3C80803F
    .long 0x608406D0
    .long 0x28000013
    .long 0x4082000C
    .long 0x39600001
    .long 0x48000010
    .long 0x28000000
    .long 0x408200C0
    .long 0x48000034
    .long 0x2C03001D
    .long 0x408000B4
    .long 0x2C0B0002
    .long 0x4182004C
    .long 0x1CA3001C
    .long 0x7CA52214
    .long 0x88C5000A
    .long 0x80AA0000
    .long 0x7CA53430
    .long 0x54A507FF
    .long 0x40820088
    .long 0x4800002C
    .long 0x806DB600
    .long 0x5460056B
    .long 0x4082001C
    .long 0x546006F7
    .long 0x40820008
    .long 0x48000074
    .long 0x39600002
    .long 0x38600000
    .long 0x4BFFFFB0
    .long 0x886DB60E
    .long 0x2C03001D
    .long 0x4080005C
    .long 0x1CA3001C
    .long 0x7CA52214
    .long 0x38C00000
    .long 0x2C0B0002
    .long 0x40820008
    .long 0x38C00002
    .long 0x98C50008
    .long 0x80A50000
    .long 0x2C030016
    .long 0x41800008
    .long 0x80A50010
    .long 0x3CC04400
    .long 0x2C0B0002
    .long 0x40820008
    .long 0x38C00000
    .long 0x90C50038
    .long 0x38C0001E
    .long 0x98CDB60E
    .long 0x2C0B0000
    .long 0x4182000C
    .long 0x38630001
    .long 0x4BFFFF4C
    .long 0x800DB604
    # End original code.

return:
    cmplwi r0, 0
