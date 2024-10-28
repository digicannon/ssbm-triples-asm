# ====================
#  Insert at 80160154
# ====================

.include "common.s"

.set OSReport, 0x803456A8

    # Skip data/funcs.
    b begin

header:
    blrl
    .string "Ope! X(\nPress LRA+Start to reboot the game.\n\nPlease provide a photo of this for your bug report.\n"
    .align 4, 0

begin:
    # Remove all previous OSReports. [UnclePunch]
    load r3, 0x804CF7E8
    li r4, 0
    stw r4, 0xC(r3)

    # Print out header.
    bl header
    mflr r3
    branchl r4, OSReport

    # Print build title.
    # We overwrite this with the triples version text.
    load r3, 0x803EA6C8
    branchl r4, OSReport

return:
    li	r0, 0 # Original code.
