# ====================
#  Insert at 80266830
# ====================

.include "common.s"
.include "triples.s"

	# Don't do anything if not on main CSS (ID 2).
	lis r17, 0x8047
	ori r17, r17, 0x9D30
	lbz r17, 0(r17)
	cmpi 0, r17, 2
	bne RETURN_ORIGINAL

b START_CODE
# Begin data table
FP_CONST_NEG_10:
blrl
.float -5.0
FP_CONST_NEG_2_3:
blrl
.float -2.3
FP_CONST_NEG_FIVE:
blrl
.float -2.0
FP_CONST_0:
FP_CONST_ZERO:
blrl
.float 0.0
FP_CONST_POINT_ONE:
blrl
.float 0.1
FP_CONST_POINT_THREE:
blrl
.float 0.3
FP_CONST_HALF:
blrl
.float 0.5
FP_CONST_POINT_SIX:
blrl
.float 0.6
FP_CONST_0_64:
FP_CONST_POINT_SIX_FOUR:
blrl
.float 0.64
FP_CONST_0_66:
FP_CONST_POINT_SIX_SIX:
blrl
.float 0.66
FP_CONST_POINT_SEVEN:
blrl
.float 0.7
FP_CONST_POINT_NINE_TWO:
blrl
.float 0.92
FP_CONST_ONE:
blrl
.float 1.0
FP_CONST_TWO:
blrl
.float 2.0
FP_CONST_3:
FP_CONST_THREE:
blrl
.float 3.0
FP_CONST_FOUR:
blrl
.float 4.0
FP_CONST_FIVE:
blrl
.float 5.0
FP_CONST_SIX:
blrl
.float 6.0
FP_CONST_EIGHT:
blrl
.float 8.0
FP_CONST_10:
blrl
.float 10.0
FP_CONST_12:
blrl
.float 13.0
FP_CONST_11:
blrl
.float 10.65
FP_CONST_10_45:
blrl
.float 10.45
FP_CONST_TEN_POINT_EIGHT:
FP_CONST_10_8:
blrl
.float 10.8
FP_CONST_15:
blrl
.float 15
FP_CONST_15_5:
blrl
.float 15.5
FP_CONST_20:
FP_CONST_TWENTY:
blrl
.float 20.0
FP_CONST_20_65:
blrl
.float 20.65
FP_CONST_TWENTY_ONE:
blrl
.float 21.0
FP_CONST_TWENTY_FIVE:
blrl
.float 25.7
FP_CONST_32:
blrl
.float 32.0
FP_CONST_50:
FP_CONST_FIFTY:
blrl
.float 50.0
FP_CONST_155:
blrl
.float 155.0
FP_CONST_206_5:
blrl
.float 206.5
FP_CONST_255:
blrl
.float 255.0

FP_CONST_LABEL_POS_Y:
blrl
.float 60
FP_CONST_LABEL_POS_X_P1:
blrl
.float 35
FP_CONST_LABEL_POS_X_P2:
blrl
.float -50
FP_CONST_LABEL_POS_X_P3:
blrl
.float -140
FP_CONST_LABEL_POS_X_P4:
blrl
.float -230
FP_CONST_BORDER_POS_X_SHIFT:
blrl
.float 5.15
FP_CONST_P2_BORDER_POS_Y:
blrl
.float 40
FP_CONST_LABEL_P1_TEAM_POS_X:
blrl 
.float -25.25
FP_CONST_LABEL_P2_TEAM_POS_X:
blrl 
.float -15
FP_CONST_LABEL_P3_TEAM_POS_X:
blrl 
.float -4.85
FP_CONST_LABEL_P4_TEAM_POS_X:
blrl 
.float 5.5
FP_CONST_LABEL_P1_TEAM_POS_Y:
blrl 
.float -2.5

FP_CONST_LABEL_BG_POS_Y:
blrl
.float -21
FP_CONST_LABEL_BG_POS_Y_NEW: # For P5 & 6 (New)
blrl
.float -24.0
FP_CONST_LABEL_BG_POS_X_P1:
blrl
.float -25.5
FP_CONST_LABEL_BG_POS_X_P2:
blrl
.float -15.2
FP_CONST_LABEL_BG_POS_X_P3:
blrl
.float -4.9
FP_CONST_LABEL_BG_POS_X_P4:
blrl
.float 5.3
FP_CONST_LABEL_BG_SCALE_Y:
blrl
.float 0.42
FP_CONST_LABEL_BG_SCALE_X:
blrl
.float 0.69

CONST_STR_TRIPLES:
blrl
.string "Triples"
END_CONST_TABLE:

# Begin Function decls

get_rgb_ptr:
    # R3 is a JObj* and on return contains a pointer to the RGB values
    # This was written for player portrait background "card's", but may work for other things
	lwz r3, 0x18(r3)
	lwz r3, 0x08(r3)
	lwz r3, 0x1c(r3)
	lwz r3, 0x08(r3)
	subi r3, r3, 4
	blr

set_jobj_alpha:
    # R3 is a JObj*
	# f1 is new alpha value
	# Strictly, this sets the first alpha of the first DObj's first material. Generally, that's what you wnat.
	lwz r3, 0x18(r3)
	lwz r3, 0x8(r3)
	lwz r3, 0xc(r3)
	stfs f1, 0xc(r3)
	blr

create_text:
    # R3 should be a char*
	# F1 should be X offset
	# F2 should be Y offset
	# R3 return value is the GObj *
	stmw r30, -8(sp) # Save r30, r31
    mflr r30         # Backup LR
	mr r31, sp       # Backup SP
	stwu sp, -36(sp) # Grow stack

    stfs f1, 12(sp)  # Store X on stack
    stfs f2, 16(sp)  # Store Y on stack
    stw  r3,  8(sp)  # Store char * on stack

    # Create the text GObj
    li r3, 0
	li r4, 0
	branchl r12, 0x803a6754 # CreateTextGObj

	# Store GObj return on stack
	stw r3,  20(sp)

    # Set text spacing to TIGHT in GObj
	li r4, 1
	stb r4, 0x49(r3)
	# Set text to center around x
	li r4,0x1
	stb r4, 0x4A(r3)

	# Set canvas scaling
	bl FP_CONST_POINT_ONE
	mflr r5
	lfs f1,  0(r5)
	lwz r3, 20(sp) # GObj
	stfs f1, 0x24(r3) # X
	stfs f1, 0x28(r3) # Y

    # Subtext Init
	lwz r4,  8(sp) # Str char *
	lfs f1, 12(sp) # X
	lfs f2, 16(sp) # Y
	branchl r12, 0x803a6b98 # InitializeSubtext
	stw r3, 24(sp) # Store the JObj of the subtext

	# Scale text
	mr r4, r3  # JObj return from prev call
	lwz r3, 20(sp) # GObj
	bl FP_CONST_POINT_SIX
	mflr r5
	bl FP_CONST_POINT_SIX
	mflr r6
	lfs f1, 0(r5) # X Scaling
	lfs f2, 0(r6) # Y Scaling
	branchl r12, 0x803a7548 # UpdateSubtextSize

	lwz r3, 20(sp) # GObj* return value
	lwz r4, 24(sp) # JObj* alt return value
	mtlr r30          # Restore LR
	mr sp, r31        # Pop the stack
	lmw r30, -8(sp)   # Restore r30, r31
	blr

copy_jobj:
    # R3 should be a JObj* and will contain the copied JObj* as a ret val
	# NOTE this does not copy animations. You will likely need to not only register,
	#      but also manually trigger them yourself.
	stmw r30, -8(sp) # Save r30, r31
    mflr r30         # Backup LR
	mr r31, sp       # Backup SP
	stwu sp, -24(sp) # Grow stack 6 words

    # Create the new JObj
    lwz r3, 0x84(r3)        # The JObj Desc to steal
	branchl r12, 0x80370E44 # CreateJObj from Desc
	stw r3, 16(sp)          # Store JObj on stack

    # Create the GObj
	li r3, 4      # GObj UI Class. 4, Player is used by CSS for UI.
	li r4, 0x1   # idx
	li r5, 0x80   # prio
	branchl r12, 0x803901F0 # CreateG
	stw r3, 12(sp) # Store GObj return value to stack

    # Link the two
    li r4, 4       # JOBJ class
	lwz r5, 16(sp) # The jobj from the stack
    branchl r12, 0x80390a70 # InitKind

    # Add a render function
	lwz r3, 12(sp) # Load GObj from stack
	load r4, 0x80391070     # TextureDisplay
    li r5, 0x1             # Same idx as above
	li r6, 0x80             # Prio
	branchl r12, 0x8039069c # Add GxLink

	lwz r3, 16(sp)    # The jobj from the stack as return value
	mtlr r30          # Restore LR
	mr sp, r31        # Pop the stack
	lmw r30, -8(sp)   # Restore r30, r31
	blr

manually_animate_below:
blrl
manually_animate:
    # R3 contains a JObj*, Undefined return value
    # R4 contains WHICH DObj*, Undefined return value
	# f1 contains frame number
	# Undefined return value

	stmw r30, -8(sp) # Save r30, r31
    mflr r30         # Backup LR
	mr r31, sp       # Backup SP
	stwu sp, -24(sp) # Grow stack 6 words

	# Uses f1 to know the frame number
	# Requires AObj * since we are manually calling, rather than with JObjRunAObjCallback
	stw r3, 16(sp)   # Store JObj on stack
	#lwz r3, 0x18(r3) # Jobj's DObj
	# Caller provides which DObj to animate
	lwz r3, 8(r4)    # DObj's MObj
	lwz r3, 8(r3)    # MObj's TObj
	lwz r3, 0x64(r3) # MObj's AObj
	branchl r12, 0x8036410C # HSD_AObjReqAnim

	lwz r3, 16(sp)          # The jobj from the stack
	branchl r12, 0x80370928 # HSD_JObjAnimAll

	lwz r3, 16(sp) # The jobj from the stack
	li r4, 6
	li r5, 0x400
	load r6, 0x8036414c # HSD_AObjStopAnim
	li r7, 6
	li r8, 0
	li r9, 0
	branchl r12, 0x80364c08 #HSD_JobjRunAObjCallback

	mtlr r30          # Restore LR
	mr sp, r31        # Pop the stack
	lmw r30, -8(sp)   # Restore r30, r31
	blr

# Begin actual code
START_CODE:
.set jobj_x30_ptr,       0x804d6cc0
.set jobj_x30_base,      0x810dc540
# .set jobj_x30_5,         0x810ea2a0
# .set jobj_x30_8,         0x810ed820
# .set jobj_x30_8_1,       0x810ed8c0
# .set jobj_x30_8_2,       0x810eda00
# .set jobj_x30_8_3,       0x810edaa0
# .set jobj_x30_8_4,       0x810edb40
# .set jobj_x30_12,        0x810fe0c0
# .set jobj_x30_13,        0x810ff760
# .set jobj_x30_14,        0x81100ae0
# .set jobj_x30_15,        0x81101f00
# .set jobj_x30_15_1_2,    0x81102a00
# .set jobj_x30_16,        0x811032c0
# .set jobj_x30_16_1,      0x81103360
# .set jobj_x30_16_2,      0x81103b00
# .set jobj_x30_16_3,      0x81104380
# .set jobj_x30_16_4,      0x81104c00
.set jobj_x30_16_1_1,    (0x81103400 - jobj_x30_base)
# .set jobj_x30_16_1_1_d1_p, 0x811036c0
# .set jobj_x30_16_1_1_d2_p, 0x811030c0
# .set jobj_x30_16_1_1_d3_p, 0x81103180
.set jobj_x30_16_2_1,    (0x81103ba0 - jobj_x30_base)
# .set jobj_x30_16_3_1,    0x81104420
# .set jobj_x30_16_4_1,    0x81104ca0
.set func_text_update_subtext_pos, 0x803a746c
.set func_jobj_remove,             0x80371370
.set func_jobj_remove_anim_all,    0x8036f6b4
.set func_jobj_set_flags,          0x80371d00
.set func_jobj_hide,               func_jobj_set_flags
.set func_dobj_set_flags,          0x8035DDB8

.set reg_jobj_x30_base, r27

.macro load_jobj_addr reg, x30_offset
	load \reg, \x30_offset
	add \reg, reg_jobj_x30_base, \reg
.endm
.macro load_jobj_addr_abs reg, x30_address
	load \reg, (\x30_address - jobj_x30_base)
	add \reg, reg_jobj_x30_base, \reg
.endm

	# Make some stack room
	stmw r27, -20(sp) # Save r28 .. r31
	mr r31, sp        # Backup SP
	stwu sp, -28(sp)  # Grow stack 6 words

	loadwz reg_jobj_x30_base, jobj_x30_ptr

# Hide extra artifacts we don't want anymore, like P1-P4 italics
.set func_m_set_alpha, 0x80363C2C
# Hide weird extra rectangles around char string
	li r4, 0
    load_jobj_addr_abs r3, 0x810f7ce0 # x30_9_5_d1_p
	sth r4, 0xe(r3) # n_display
	load_jobj_addr_abs r3, 0x810f78e0 # x30_9_5_d2_p
	sth r4, 0xe(r3) # n_display
	load_jobj_addr_abs r3, 0x810f75a0 # x30_9_5_d3_p
	sth r4, 0xe(r3) # n_display
	load_jobj_addr_abs r3, 0x810f7540 # x30_9_5_d4_p
	sth r4, 0xe(r3) # n_display

# Hide italic "text" P1-4
	li r4, 0
	load_jobj_addr_abs r3, 0x81103180 # x30_16_1_1_d3_p
	sth r4, 0xe(r3) # n_display
	load_jobj_addr_abs r3, 0x81103d40 # x30_16_2_1_d3_p
	sth r4, 0xe(r3) # n_display
	load_jobj_addr_abs r3, 0x811045c0 # x30_16_3_1_d3_p
	sth r4, 0xe(r3) # n_display
	load_jobj_addr_abs r3, 0x81104e40 # x30_16_4_1_d3_p
	sth r4, 0xe(r3) # n_display
	b RETURN

# Scale card to FP_CONST_... X size
    mr r7, r3
	li r9, 32 # Number of scale_loop_vars
	li r10, 0
	bl scale_p1_vars
	mflr r6
	bl FP_CONST_POINT_SIX_SIX
	mflr r5

	b scale_card_loop

scale_p1_vars:
	blrl
# P1
    .long (0x810ea340 - jobj_x30_base) # Rectangle border
	.long (0x810ecae0 - jobj_x30_base) # Char portrait
	.long (0x810eba00 - jobj_x30_base) # Category logo
	.long (0x81103400 - jobj_x30_base) # HMN tag
	.long (0x810feea0 - jobj_x30_base) # Door
	.long (0x810fe4a0 - jobj_x30_base) # Door curved inner anim pt1
	.long (0x810fe540 - jobj_x30_base) # ^ pt2
	.long (0x810ed8c0 - jobj_x30_base) # Team tag
# P2
    .long (0x810EA3E0 - jobj_x30_base) # Rectangle border
    .long (0x810ecb80 - jobj_x30_base) # Char portrait
	.long (0x810ebb20 - jobj_x30_base) # Category logo
	.long (0x81103ba0 - jobj_x30_base) # HMN tag
	.long (0x811002a0 - jobj_x30_base) # Door
	.long (0x810ff940 - jobj_x30_base) # Door curved inner anim
	.long (0x810ffb00 - jobj_x30_base) # ^ pt2
	.long (0x810eda00 - jobj_x30_base) # Team tag
# P3
    .long (0x810ea480 - jobj_x30_base) # Rectangle border
	.long (0x810ecca0 - jobj_x30_base) # Char portrait
	.long (0x810ebbc0 - jobj_x30_base) # Category logo
	.long (0x81104420 - jobj_x30_base) # HMN tag
	.long (0x811016c0 - jobj_x30_base) # Door
	.long (0x81100de0 - jobj_x30_base) # Door curved inner anim
	.long (0x81100e80 - jobj_x30_base) # ^ pt2
	.long (0x810edaa0 - jobj_x30_base) # Team tag
# P4
    .long (0x810ea580 - jobj_x30_base) # Rectanlge border
    .long (0x810ecd40 - jobj_x30_base) # Char portrait
	.long (0x810ebc60 - jobj_x30_base) # Category logo
	.long (0x81104ca0 - jobj_x30_base) # HMN tag
	.long (0x81102a00 - jobj_x30_base) # Door
	.long (0x811020e0 - jobj_x30_base) # Door curved inner anim
	.long (0x81102180 - jobj_x30_base) # ^ pt2
	.long (0x810edb40 - jobj_x30_base) # Team tag

text_label_gobjs:
	blrl
    .long (0x80bd5c88 - jobj_x30_base) # P1 Char Label
	.long (0x80bd5f68 - jobj_x30_base) # P2 Char Label
	.long (0x80bd6418 - jobj_x30_base) # P3 Char Label
	.long (0x80bd68c8 - jobj_x30_base) # P4 Char Label

text_background_jobjs:
	blrl
    .long (0x810ef040 - jobj_x30_base) # P1 Text BG
    .long (0x810f1380 - jobj_x30_base) # P2 Text BG
    .long (0x810f3600 - jobj_x30_base) # P3 Text BG
    .long (0x810f5880 - jobj_x30_base) # P4 Text BG

scale_card_loop:
.set x_pos_offset, 0x38
.set y_pos_offset, 0x3c
.set z_pos_offset, 0x40
.set x_scale_offset, 0x2c
.set y_scale_offset, 0x30
    cmp 0, r9, r10
	beq finished_card_scale_loop

    # main loop logic, get each JObj and scale it
    lwz r3, 0(r6)
	add r3, reg_jobj_x30_base, r3
	lfs f4, 0(r5)
	stfs f4, x_scale_offset(r3)

    addi r6, r6, 4 # increment by sizeof(word)
	addi r10, r10, 1
	b scale_card_loop
finished_card_scale_loop:
# Translate P2-4 over to the left
# Load consts and offsets
	bl FP_CONST_TWO
	mflr r8
	lfs f8, 0(r8) # const 2.0
	bl FP_CONST_THREE
	mflr r9
	lfs f9, 0(r9) # const 3.0
	bl scale_p1_vars
	mflr r6
	addi r6, r6, 32 # skip P1 vars
	bl FP_CONST_BORDER_POS_X_SHIFT
	mflr r5

# Init loop counters
	li r9, 24 # Number of scale_loop_vars
	li r10, 0
translate_card_loop:
    cmp 0, r9, r10
	beq finished_card_translate_loop

    # main loop logic, get each JObj and translate it
    lwz r3, 0(r6) # Current JObj
	add r3, reg_jobj_x30_base, r3
	lfs f4, 0(r5) # X = Translate amount
	lfs f5, x_pos_offset(r3) # Current pos
	cmpi 0, r10, 8 # if we're on P1, no mul
	blt no_mul
double_x:
	cmpi 0, r10, 16
	bge triple_x # if we're onto P4, triple instead
    fmul f4, f4, f8
	b no_mul
triple_x:
    fmul f4, f4, f9
no_mul:
	fsub f5, f5, f4
	stfs f5, x_pos_offset(r3)

    addi r6, r6, 4 # increment by sizeof(word)
	addi r10, r10, 1
	b translate_card_loop
finished_card_translate_loop:

# Translate char label string pos(s)
	bl text_label_gobjs
	mflr r28

	bl FP_CONST_LABEL_POS_Y
    mflr r3
	lfs f2, 0(r3) # Label Y Pos
	bl FP_CONST_LABEL_POS_X_P1
    mflr r3
	lfs f8, 0(r3) # P1 Label X Pos
	bl FP_CONST_LABEL_POS_X_P2
    mflr r3
	lfs f9, 0(r3) # P2 Label X Pos
	bl FP_CONST_LABEL_POS_X_P3
    mflr r3
	lfs f10, 0(r3) # P3 Label X Pos
	bl FP_CONST_LABEL_POS_X_P4
    mflr r3
	lfs f11, 0(r3) # P4 Label X Pos

	# Begin func calls to translate
    lwz r3, 0(r28)  # P1 Label GObj ptr
	add r3, reg_jobj_x30_base, r3
	fmr f1, f8
	lis r4, 0 # Subtext Idx
	branchl r12, func_text_update_subtext_pos

    addi r28, r28, 4
    lwz r3, 0(r28)  # P2 Label GObj ptr
	add r3, reg_jobj_x30_base, r3
	fmr f1, f9
	lis r4, 0 # Subtext Idx
	branchl r12, func_text_update_subtext_pos

	addi r28, r28, 4
    lwz r3, 0(r28)  # P3 Label GObj ptr
	add r3, reg_jobj_x30_base, r3
	fmr f1, f10
	lis r4, 0 # Subtext Idx
	branchl r12, func_text_update_subtext_pos

	addi r28, r28, 4
    lwz r3, 0(r28)  # P4 Label GObj ptr
	add r3, reg_jobj_x30_base, r3
	fmr f1, f11
	lis r4, 0 # Subtext Idx
	branchl r12, func_text_update_subtext_pos

# Translate and scale text backgrounds
	bl text_background_jobjs
	mflr r28

	bl FP_CONST_LABEL_BG_POS_Y
    mflr r3
	lfs f2, 0(r3) # Label BG Y Pos
	bl FP_CONST_LABEL_BG_SCALE_X
    mflr r3
	lfs f3, 0(r3) # Label BG X Scale
	bl FP_CONST_LABEL_BG_SCALE_Y
    mflr r3
	lfs f4, 0(r3) # Label BG Y Scale

	bl FP_CONST_LABEL_BG_POS_X_P1
    mflr r3
	lfs f8, 0(r3) # P1 Label BG X Pos
	bl FP_CONST_LABEL_BG_POS_X_P2
    mflr r3
	lfs f9, 0(r3) # P2 Label BG X Pos
	bl FP_CONST_LABEL_BG_POS_X_P3
    mflr r3
	lfs f10, 0(r3) # P3 Label BG X Pos
	bl FP_CONST_LABEL_BG_POS_X_P4
    mflr r3
	lfs f11, 0(r3) # P4 Label BG X Pos


	lwz r3, 0x0(r28) # P1 BG JObj
	add r3, reg_jobj_x30_base, r3
	stfs f8, x_pos_offset(r3)
	stfs f2, y_pos_offset(r3)
	stfs f3, x_scale_offset(r3)
	stfs f4, y_scale_offset(r3)
	lwz r3, 0x4(r28) # P2 BG JObj
	add r3, reg_jobj_x30_base, r3
	stfs f9, x_pos_offset(r3)
	stfs f2, y_pos_offset(r3)
	stfs f3, x_scale_offset(r3)
	stfs f4, y_scale_offset(r3)
	lwz r3, 0x8(r28) # P3 BG JObj
	add r3, reg_jobj_x30_base, r3
	stfs f10, x_pos_offset(r3)
	stfs f2, y_pos_offset(r3)
	stfs f3, x_scale_offset(r3)
	stfs f4, y_scale_offset(r3)
	lwz r3, 0xc(r28) # P4 BG JObj
	add r3, reg_jobj_x30_base, r3
	stfs f11, x_pos_offset(r3)
	stfs f2,  y_pos_offset(r3)
	stfs f3, x_scale_offset(r3)
	stfs f4, y_scale_offset(r3)
# Translate P1-4 Team Tag/Buttons
# easy abstraction here maybe if run out of memory
	bl FP_CONST_LABEL_P1_TEAM_POS_Y
	mflr r7
	lfs f4, 0(r7)
	bl FP_CONST_LABEL_P1_TEAM_POS_X
	mflr r7
	lfs f5, 0(r7)
	bl FP_CONST_LABEL_P2_TEAM_POS_X
	mflr r7
	lfs f6, 0(r7)
	bl FP_CONST_LABEL_P3_TEAM_POS_X
	mflr r7
	lfs f7, 0(r7)
	bl FP_CONST_LABEL_P4_TEAM_POS_X
	mflr r7
	lfs f8, 0(r7)

	# P1 Team Tag
	load_jobj_addr_abs r3, 0x810ed8c0
	stfs f4, y_pos_offset(r3)
	stfs f5, x_pos_offset(r3)
	# P2 Team Tag
	load_jobj_addr_abs r3, 0x810eda00
	stfs f4, y_pos_offset(r3)
	stfs f6, x_pos_offset(r3)
	# P3 Team Tag
	load_jobj_addr_abs r3, 0x810edaa0
	stfs f4, y_pos_offset(r3)
	stfs f7, x_pos_offset(r3)
	# P4 Team Tag
	load_jobj_addr_abs r3, 0x810edb40
	stfs f4, y_pos_offset(r3)
	stfs f8, x_pos_offset(r3)

# Create P5 & 6
    load_jobj_addr_abs r3, 0x810ea340 # P1 JObj
    bl copy_jobj
    mr r28, r3 # P5 JObj
	# Store background in global
	load r3, css_p5_bg
	stw r28, 0(r3)
	load_jobj_addr_abs r3, 0x810ea340 # P1 JObj
    bl copy_jobj
    mr r29, r3 # P6 Jobj
	# Store background in global
	load r3, css_p6_bg
	stw r29, 0(r3)

# Scale & Move P5 & 6
	bl FP_CONST_POINT_SIX_SIX
	mflr r7
	lfs f4, 0(r7)
	stfs f4, x_scale_offset(r28)
	stfs f4, x_scale_offset(r29)

	bl FP_CONST_TEN_POINT_EIGHT
	mflr r7
	lfs f4, 0(r7)
	stfs f4, x_pos_offset(r28)
	bl FP_CONST_TWENTY_ONE
	mflr r7
	lfs f4, 0(r7)
	stfs f4, x_pos_offset(r29)

# Copy & Move P1 Italic image to P5
	load_jobj_addr r3, jobj_x30_16_1_1
	bl copy_jobj
	# Move & Shrink
	bl FP_CONST_10_8
	mflr r7
	lfs f4, 0(r7)
	bl FP_CONST_12
	mflr r7
	lfs f5, 0(r7)
	bl FP_CONST_HALF
	mflr r7
	lfs f6, 0(r7)
	lfs f7, 0(r7)

	stfs f4, x_pos_offset(r3)
	stfs f5, y_pos_offset(r3)
	stfs f6, z_pos_offset(r3)
	stfs f7, x_scale_offset(r3)

	# Calc d1_p/d2_p offset and hide
	mr r4, r3
	li r6, 0
	lwz r4, 0x18(r4) # d1
	lwz r5, 0xc(r4) # d1_p
	lwz r4, 0x4(r4)  # d2
	lwz r4, 0xc(r4)  # d2_p
	sth r6, 0xe(r4) # n_display; hide HMN tag
	sth r6, 0xe(r5) # n_display; hide shadow

# Copy & Move P2 Italic image to P6
	load_jobj_addr r3, jobj_x30_16_2_1
	bl copy_jobj
	# Store the copy in a global
	load r4, css_p6_p2_label
	stw r3, 0(r4)

	# Register animation and set to frame 2
	load r4, 0x80f48858 # AnimJoint
	load r5, 0x80f54110 # MatJoint
	li   r6, 0          # ShapeAnimJoint
	branchl r12, 0x8036fa10 # HSD_JObjAddAnim
	bl FP_CONST_ONE
	mflr r4
	lfs f1, 0(r4)

	# Reload global before manually_animate call
	load r4, css_p6_p2_label
	lwz r3, 0(r4)
	mr r4, r3 # get 3rd DObj
	lwz r4, 0x18(r4) # First DObj
	lwz r4, 0x04(r4) # Second DObj
	lwz r4, 0x04(r4) # Third DObj
	bl manually_animate
	# And again after, since it might be clobbered
	load r4, css_p6_p2_label
	lwz r3, 0(r4)

	# Move & Shrink
	bl FP_CONST_TWENTY_ONE
	mflr r4
	lfs f4, 0(r4)

	# TODO easy loop for everything here except x_pos
	stfs f4, x_pos_offset(r3)
	stfs f5, y_pos_offset(r3)
	stfs f6, z_pos_offset(r3)
	stfs f7, x_scale_offset(r3)

	# Calc d1_p/d2_p offset and hide
	mr r4, r3
	li r6, 0
	lwz r4, 0x18(r4) # d1
	lwz r5, 0xc(r4) # d1_p
	lwz r4, 0x4(r4)  # d2
	lwz r4, 0xc(r4)  # d2_p
	sth r6, 0xe(r4) # n_display; hide HMN tag
	sth r6, 0xe(r5) # n_display; hide shadow

# Color P5
	mr r3, r28
    bl get_rgb_ptr # R3 contains P5 RGB offset
	load r4, 0xff982600 # P5 Orange
	stw r4, 0(r3)
	load r4, 0x2c2c2c00 # Gray for inner line
	stw r4, 4(r3)

# Color P6
	mr r3, r29
    bl get_rgb_ptr # R3 contains P6 RGB offset
	load r4, 0x984ce500 # P6 Purple
	stw r4, 0(r3)
	load r4, 0x2c2c2c00 # Gray for inner line
	stw r4, 4(r3)

# Create P5 Player Portrait
    load_jobj_addr_abs r3, 0x810ecae0 # Portrait
    bl copy_jobj
    mr r28, r3 # JObj

    # Store JObj in global for use in input loop
	load r4, css_p5_portrait
	stw r28, 0(r4)

	# Store starting frame number TODO remove?
	bl FP_CONST_ONE
	mflr r3
	lfs f1, 0(r3)
	load r4, css_backup_space
	stfs f1, 0(r4)

	# Scale and move
	    bl FP_CONST_0_64
	    mflr r7
	    lfs f4, 0(r7)
	    stfs f4, x_scale_offset(r28)
		bl FP_CONST_TEN_POINT_EIGHT
		mflr r7
		lfs f4, 0(r7)
		stfs f4, x_pos_offset(r28)

	# Register animation and set to frame 2
        mr r3, r28 # The jobj from the stack
        load r4, 0x80f47f34 # AnimJoint
        load r5, 0x80f53b94 # MatJoint
        li   r6, 0          # ShapeAnimJoint
        branchl r12, 0x8036fb5c # HSD_JObjAddAnimAll

        bl FP_CONST_TWO
        mflr r4
        lfs f1, 0(r4)
        mr r3, r28
		mr r4, r3 # Calc DObj*
		lwz r4, 0x18(r4) # First DObj
        bl manually_animate

	# Set alpha to unselected mode
	    mr r3, r28
		bl FP_CONST_HALF
		mflr r4
		lfs f1, 0(r4)
		bl set_jobj_alpha

# Create P6 Player Portrait
    load_jobj_addr_abs r3, 0x810ecae0 # Portrait
    bl copy_jobj
    mr r28, r3 # JObj
	
    # Store JObj in global for use in input loop
	load r4, css_p6_portrait
	stw r28, 0(r4)

	# Scale and move
	    bl FP_CONST_0_64
	    mflr r7
	    lfs f4, 0(r7)
	    stfs f4, x_scale_offset(r28)
		bl FP_CONST_TWENTY_ONE
		mflr r7
		lfs f4, 0(r7)
		stfs f4, x_pos_offset(r28)

	# Register animation and set to frame 2
        mr r3, r28 # The jobj from the stack
        load r4, 0x80f47f34 # AnimJoint
        load r5, 0x80f53b94 # MatJoint
        li   r6, 0          # ShapeAnimJoint
        branchl r12, 0x8036fb5c # HSD_JObjAddAnimAll

        bl FP_CONST_ZERO
        mflr r4
        lfs f1, 0(r4)
        mr r3, r28
		mr r4, r3 # Calc DObj*
		lwz r4, 0x18(r4) # First DObj
        bl manually_animate

    # Set alpha to unselected mode
	    mr r3, r28
		bl FP_CONST_HALF
		mflr r4
		lfs f1, 0(r4)
		bl set_jobj_alpha

# Create P5 Nametag
    load_jobj_addr_abs r3, 0x810ef040 # Text Label BG
    bl copy_jobj
    mr r28, r3 # JObj

	# Scale and move
		bl FP_CONST_LABEL_BG_SCALE_X
	    mflr r7
	    lfs f4, 0(r7)
	    stfs f4, x_scale_offset(r28)

		bl FP_CONST_LABEL_BG_SCALE_Y
	    mflr r7
	    lfs f4, 0(r7)
	    stfs f4, y_scale_offset(r28)

		bl FP_CONST_15_5
		mflr r7
		lfs f4, 0(r7)
		stfs f4, x_pos_offset(r28)

	    bl FP_CONST_LABEL_BG_POS_Y_NEW
		mflr r7
		lfs f4, 0(r7)
		stfs f4, y_pos_offset(r28)

# Create P6 Nametag
    load_jobj_addr_abs r3, 0x810ef040 # Text Label BG
    bl copy_jobj
    mr r28, r3 # JObj

	# Scale and move
		bl FP_CONST_LABEL_BG_SCALE_X
	    mflr r7
	    lfs f4, 0(r7)
	    stfs f4, x_scale_offset(r28)

		bl FP_CONST_LABEL_BG_SCALE_Y
	    mflr r7
	    lfs f4, 0(r7)
	    stfs f4, y_scale_offset(r28)

		bl FP_CONST_TWENTY_FIVE
		mflr r7
		lfs f4, 0(r7)
		stfs f4, x_pos_offset(r28)

	    bl FP_CONST_LABEL_BG_POS_Y_NEW
		mflr r7
		lfs f4, 0(r7)
		stfs f4, y_pos_offset(r28)

# Create P5 Text Label
	bl CONST_STR_TRIPLES
	mflr r3
	bl FP_CONST_155
	mflr r5
	lfs f1, 0(r5) # X offset
	bl FP_CONST_206_5
	mflr r5
	lfs f2, 0(r5) # Y Offset
	bl create_text

	# Store GObj in global for use in input loop
	load r5, css_p5_text_gobj
	stw r3, 0(r5)
	# Store Subtext in global for use in input loop
	load r5, css_p5_text_subtext
	stw r4, 0(r5)

# Create P6 Text Label
	bl CONST_STR_TRIPLES
	mflr r3
	bl FP_CONST_255
	mflr r5
	lfs f1, 0(r5) # X offset
	bl FP_CONST_206_5
	mflr r5
	lfs f2, 0(r5) # Y Offset
	bl create_text
	# Store GObj in global for use in input loop
	load r5, css_p6_text_gobj
	stw r3, 0(r5)
	# Store Subtext in global for use in input loop
	load r5, css_p6_text_subtext
	stw r4, 0(r5)

# Load function addrs into global
bl manually_animate_below
mflr r3
load r4, css_manually_animate
stw r3, 0(r4)

# Return / original value
RETURN:
	mr sp, r31         # Pop the stack
	lmw r27, -20(sp)   # Restore r28 .. r31

    mr r3, r7
RETURN_ORIGINAL:
	lmw	r17, 0x011C(sp)
