# ====================
#  Insert at 80266830
# ====================

.include "common.s"

# Begin data table
b END_CONST_TABLE
FP_CONST_NINE_TWO:
blrl
.float 0.92
FP_CONST_SIXTY_SIX:
blrl
.float 0.66
FP_CONST_ONE_HUNDRED:
blrl
.float 20.0
FP_CONST_ONE:
blrl
.float 1.0
FP_CONST_TWO:
blrl
.float 2.0
FP_CONST_THREE:
blrl
.float 3.0

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

FP_CONST_LABEL_BG_POS_Y:
blrl
.float -21
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
END_CONST_TABLE:

# Begin actual code
.set jobj_x30_ptr,       0x804d6cc0 
.set jobj_x30,           0x810dc540
.set jobj_x30_5,         0x810ea2a0
.set jobj_x30_12,        0x810fe0c0
.set jobj_x30_13,        0x810ff760
.set jobj_x30_14,        0x81100ae0
.set jobj_x30_15,        0x81101f00
.set jobj_x30_15_1_2,    0x81102a00
.set jobj_x30_16,        0x811032c0
.set jobj_x30_16_1,      0x81103360
.set jobj_x30_16_2,      0x81103b00
.set jobj_x30_16_3,      0x81104380
.set jobj_x30_16_4,      0x81104c00
.set jobj_x30_16_1_1,    0x81103400
.set jobj_x30_16_1_1_d3_p, 0x81103180
.set jobj_x30_16_2_1,    0x81103ba0
.set jobj_x30_16_3_1,    0x81104420
.set jobj_x30_16_4_1,    0x81104ca0
.set known_flags,       0x20000208
.set func_text_update_subtext_pos, 0x803a746c
.set func_jobj_remove,             0x80371370  
.set func_jobj_remove_anim_all,    0x8036f6b4 
.set func_jobj_set_flags,          0x80371d00
.set func_jobj_hide,               func_jobj_set_flags
.set func_dobj_set_flags,          0x8035DDB8
load r11, jobj_x30
load r7, known_flags

# Indev / debug loop to find the correct address for the JObj. This can be removed once functionallity is complete.
# Loop its children until find a flags of known_flags
# That's the one to try and hide.
    lwz r11, 0x10(r11) # Child of JObj
    li r9, 15
    li r10, 0
loop:
    # if (i == 16)
    cmp 0, r9, r10
    beq finished_loop

    # compare JOBj flags to known dbg values of known_flags
    lwz r8, 0x14(r11)
	cmp 0, r8, r7
	beq found_match

    # next itr
	lwz r11, 0x08(r11) # curr = curr->next
	addi r10, r10, 1   # ++i
	b loop
found_match:
    nop #nop for BP
finished_loop:

# Hide extra artifacts we don't want anymore, like P1-P4 italics
.set func_m_set_alpha, 0x80363C2C
# Hide weird extra rectangles around char string
	li r4, 0
    load r3, 0x810f7ce0 # x30_9_5_d1_p
	sth r4, 0xe(r3) # n_display
	load r3, 0x810f78e0 # x30_9_5_d2_p
	sth r4, 0xe(r3) # n_display
	load r3, 0x810f75a0 # x30_9_5_d3_p
	sth r4, 0xe(r3) # n_display
	load r3, 0x810f7540 # x30_9_5_d4_p
	sth r4, 0xe(r3) # n_display

# Hide italic "text" P1-4
	li r4, 0
	load r3, 0x81103180 # x30_16_1_1_d3_p
	sth r4, 0xe(r3) # n_display
	load r3, 0x81103d40 # x30_16_2_1_d3_p
	sth r4, 0xe(r3) # n_display
	load r3, 0x811045c0 # x30_16_3_1_d3_p
	sth r4, 0xe(r3) # n_display
	load r3, 0x81104e40 # x30_16_4_1_d3_p
	sth r4, 0xe(r3) # n_display


# Scale card to FP_CONST_... X size
    mr r7, r3
	li r9, 28 # Number of scale_loop_vars
	li r10, 0
	bl scale_p1_vars
	mflr r6
	bl FP_CONST_SIXTY_SIX
	mflr r5

b scale_card_loop
scale_p1_vars:
blrl
# P1
    .long 0x810ea340    # Rectangle border
	.long 0x810ecae0    # Char portrait
	.long 0x810eba00    # Category logo
	.long 0x81103400    # HMN tag
	.long 0x810feea0    # Door
	.long 0x810fe4a0    # Door curved inner anim pt1
	.long 0x810fe540    # ^ pt2
# P2
    .long 0x810EA3E0    # Rectangle border
    .long 0x810ecb80    # Char portrait
	.long 0x810ebb20    # Category logo
	.long 0x81103ba0    # HMN tag
	.long 0x811002a0    # Door
	.long 0x810ff940    # Door curved inner anim
	.long 0x810ffb00    # ^ pt2
# P3
    .long 0x810ea480    # Rectangle border
	.long 0x810ecca0    # Char portrait
	.long 0x810ebbc0    # Category logo
	.long 0x81104420    # HMN tag
	.long 0x811016c0    # Door
	.long 0x81100de0    # Door curved inner anim
	.long 0x81100e80    # ^ pt2
# P4
    .long 0x810ea580    # Rectanlge border
    .long 0x810ecd40    # Char portrait
	.long 0x810ebc60    # Category logo
	.long 0x81104ca0    # HMN tag
	.long 0x81102a00    # Door
	.long 0x811020e0    # Door curved inner anim
	.long 0x81102180    # ^ pt2
text_label_gobjs:
blrl
    .long 0x80bd5c88    # P1 Char Label
	.long 0x80bd5f68    # P2 Char Label
	.long 0x80bd6418    # P3 Char Label
	.long 0x80bd68c8    # P4 Char Label
text_background_jobjs:
blrl
    .long 0x810ef040    # P1 Text BG
    .long 0x810f1380    # P2 Text BG
    .long 0x810f3600    # P3 Text BG
    .long 0x810f5880    # P4 Text BG

scale_card_loop:
.set x_pos_offset, 0x38
.set y_pos_offset, 0x3c
.set x_scale_offset, 0x2c
.set y_scale_offset, 0x30
    cmp 0, r9, r10
	beq finished_card_scale_loop

    # main loop logic, get each JObj and scale it
    lwz r3, 0(r6)
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
	addi r6, r6, 28 # skip P1 vars
	bl FP_CONST_BORDER_POS_X_SHIFT
	mflr r5

# Init loop counters
	li r9, 21 # Number of scale_loop_vars
	li r10, 0
translate_card_loop:
    cmp 0, r9, r10
	beq finished_card_translate_loop

    # main loop logic, get each JObj and translate it
    lwz r3, 0(r6) # Current JObj
	lfs f4, 0(r5) # X = Translate amount
	lfs f5, x_pos_offset(r3) # Current pos
	cmpi 0, r10, 7 # if we're on P1, no mul
	blt no_mul
double_x:
	cmpi 0, r10, 14
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
	fmr f1, f8
	lis r4, 0 # Subtext Idx
	branchl r12, func_text_update_subtext_pos

    addi r28, r28, 4
    lwz r3, 0(r28)  # P2 Label GObj ptr
	fmr f1, f9
	lis r4, 0 # Subtext Idx
	branchl r12, func_text_update_subtext_pos
    
	addi r28, r28, 4
    lwz r3, 0(r28)  # P3 Label GObj ptr
	fmr f1, f10
	lis r4, 0 # Subtext Idx
	branchl r12, func_text_update_subtext_pos
	
	addi r28, r28, 4
    lwz r3, 0(r28)  # P4 Label GObj ptr
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
	stfs f8, x_pos_offset(r3)
	stfs f2, y_pos_offset(r3)
	stfs f3, x_scale_offset(r3)
	stfs f4, y_scale_offset(r3)
	lwz r3, 0x4(r28) # P2 BG JObj
	stfs f9, x_pos_offset(r3)
	stfs f2, y_pos_offset(r3)
	stfs f3, x_scale_offset(r3)
	stfs f4, y_scale_offset(r3)
	lwz r3, 0x8(r28) # P3 BG JObj
	stfs f10, x_pos_offset(r3)
	stfs f2, y_pos_offset(r3)
	stfs f3, x_scale_offset(r3)
	stfs f4, y_scale_offset(r3)
	lwz r3, 0xc(r28) # P4 BG JObj
	stfs f11, x_pos_offset(r3)
	stfs f2,  y_pos_offset(r3)
	stfs f3, x_scale_offset(r3)
	stfs f4, y_scale_offset(r3)

# This code will probably crash - DEBUG
    load r3, 0x80f45128 # The JObj Desc to steal
	branchl r12, 0x80370E44 # CreateJObj from Desc
	mr   r30, r3
	lfs  f3, x_pos_offset(r3)

	bl FP_CONST_ONE_HUNDRED
    mflr r4
	lfs  f2, 0(r4) # 100.0
	fadd f3, f2, f3
	stfs f2, x_pos_offset(r3)


	li r3, 0x8    # class
	li r4, 1      # idx
	li r5, 0xff   # prio
	branchl r12, 0x803901F0 # CreateG
    mr r31, r3

    li r4, 3      # JOBJ 
	mr r5, r30    # The Jobj
    branchl r12, 0x80390a70 # InitKind

    mr r3, r31
	load r4, 0x80391070     # GXLink_Common
    li r5, 1      # Same idx as above
	li r6, 0xff  # Prio
	branchl r12, 0x8039069c # Add GxLink
	

# Return / original value
RETURN:
    mr r3, r7
	lmw	r17, 0x011C(sp)
