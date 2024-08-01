# ====================
#  Insert at 8025ec68
# ====================

.include "common.s"
.include "triples.s"

# Preserve some registers
load r24, css_backup_space
stw r0, 0(r24)
stw r1, 4(r24)
stw r2, 8(r24)
stw r3, 12(r24)
stw r4, 16(r24)
stw r5, 20(r24)
stw r6, 24(r24)
stw r7, 28(r24)
stw r8, 32(r24)
stw r9, 36(r24)
stw r10, 40(r24)
stw r11, 44(r24)
stw r12, 48(r24)


# Force an animation on the rendered JOBJ
load r3, css_p5_border_jobj
lwz r3, 0(r3) # JObj
li r4, 6
li r5, 0x400,
load r6, 0x8036410c # HSD_AObjReqAnim

# Toggle the global between 1 and 2
load r8, css_p5_color_ctr
lwz r7, 0(r8)
cmpi 0, r7, 1
beq set_zero
set_one:
li r7, 1
b after_set
set_zero:
li r7, 0
after_set:
stw r7, 0(r8)
# r7 contains the frame to start the animation on
branchl r12, 0x80364c08 #HSD_JobjRunAObjCallback

load r3, css_p5_border_jobj
lwz r3, 0(r3) # JObj
branchl r12, 0x80370928 # HSD_JObjAnimAll

load r3, css_p5_border_jobj
lwz r3, 0(r3) # JObj
li r4, 6
li r5, 0x400,
load r6, 0x8036414c # HSD_AObjStopAnim
li r7, 6
li r8, 0
li r9, 0
branchl r12, 0x80364c08 #HSD_JobjRunAObjCallback


# Restore & return
load r24, css_backup_space
lwz r0, 0(r24)
lwz r1, 4(r24)
lwz r2, 8(r24)
lwz r3, 12(r24)
lwz r4, 16(r24)
lwz r5, 20(r24)
lwz r6, 24(r24)
lwz r7, 28(r24)
lwz r8, 32(r24)
lwz r9, 36(r24)
lwz r10, 40(r24)
lwz r11, 44(r24)
lwz r12, 48(r24)
fsubs	f31, f0, f1 # Original instruction
