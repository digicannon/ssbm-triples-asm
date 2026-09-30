# ====================
#  Insert at 80028494
# ====================

# lbAudioAx_8002838C sizes the character SFX bank for the 4 largest
# character sound banks.  Add the 5th and 6th largest so 6 unique
# characters fit.  lbl_80433B44 holds bank indices sorted by size.

.include "common.s"

.set sorted_banks, 0x80433B44
.set lbAudioAx_SortBanks, 0x80023254

    test_mex r4
    load r4, sorted_banks
    beq sizes
    loadwz r4, mex_audio
    lwz r4, 0x14(r4) # m-ex's sorted list.
sizes:
    addi r5, r31, 0x11E4 # u32[][2] bank sizes; m-ex rebases r31 onto its own.
    lwz r8, -0x525C(r13) # lbl_804D6444, character bank total.
    lwz r0, 0x10(r4)
    slwi r0, r0, 3
    lwzx r0, r5, r0
    add r8, r8, r0
    lwz r0, 0x14(r4)
    slwi r0, r0, 3
    lwzx r0, r5, r0
    add r8, r8, r0
    stw r8, -0x525C(r13)

return:
    branchl r12, lbAudioAx_SortBanks
