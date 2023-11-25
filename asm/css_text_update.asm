# ====================
#  Insert at 80262614
# ====================

.include "common.s"
.include "triples_globals.s"

# Get P2's hover (debug mode)
.set reg_stringtable, 31

b END_STR_NAME_TABLE
FP_CONST_NINE_TWO:
blrl
.float 0.92
FP_CONST_SIXTY:
blrl
.float 0.66
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
.float 14
FP_CONST_LABEL_POS_X_P1:
blrl
.float -10
FP_CONST_LABEL_POS_X_P2:
blrl
.float 0
FP_CONST_LABEL_POS_X_P3:
blrl
.float -300
FP_CONST_LABEL_POS_X_P4:
blrl
.float -300
FP_CONST_BORDER_POS_X_SHIFT:
blrl
.float 5.15
FP_CONST_P2_BORDER_POS_Y:
blrl
.float 40

STR_NAME_TABLE:
# Do not remove these nop(s). They are for alignment and the string table will break without them.
nop
#nop
blrl
.string "Dr. Mario"
.align 4, 0
.string "Mario"
.align 4, 0
.string "Luigi"
.align 4, 0
.string "Bowser"
.align 4, 0
.string "Peach"
.align 4, 0
.string "Yoshi"
.align 4, 0
.string "Donkey Kong"
.align 4, 0
.string "Cpt. Falcon"
.align 4, 0
.string "Ganondorf"
.align 4, 0
.string "Falco"
.align 4, 0
.string "Fox"
.align 4, 0
.string "Ness"
.align 4, 0
.string "Ice Climbers"
.align 4, 0
.string "Kirby"
.align 4, 0
.string "Samus Aran"
.align 4, 0
.string "Zelda"
.align 4, 0
.string "Link"
.align 4, 0
.string "Young Link"
.align 4, 0
.string "Pichu"
.align 4, 0
.string "Pikachu"
.align 4, 0
.string "JigglyPuff"
.align 4, 0
.string "Mewtwo"
.align 4, 0
.string "Mr Game & Watch"
.align 4, 0
.string "Marth"
.align 4, 0
.string "Roy"
.align 4, 0
.string "--"
.align 4, 0
END_STR_NAME_TABLE:

# Get string table
	bl STR_NAME_TABLE
	mflr reg_stringtable

# Get current char index for P2 
# 0 == Dr Mario, 0xa == Fox, 0x18 == Roy
    lis   r28, p2_char_select @h
    ori   r28, r28, p2_char_select @l
    lbz   r28, 2(r28)
    
    # Make sure it's in bounds
    cmpi  0, r28, 0
    blt   INVALID_SELECTION
    cmpi  0, r28, 0x19
    bgt   INVALID_SELECTION
    b VALID_SELECTION

INVALID_SELECTION:
    # Just make r28 'valid'
    li r28, 0x19

VALID_SELECTION:
    lis   r5, dbg_text_gobj @h
	ori   r3, r5, dbg_text_gobj @l
	ori   r4, r5, dbg_subtext_str @l
	lwz   r3, 0(r3)
	lwz   r4, 0(r4)
	mr    r5, reg_stringtable
	mulli  r28, r28, 0x10
	add   r5, r5, r28
	branchl r12, Text_UpdateSubtextContents

# now do logic for bullshit
# only run code below this once
load r3, css_run_once
lwz r4, 0(r3)
cmpi 0, r4, 0xff
beq RETURN
li r4, 0xff
stw r4, 0(r3)

# Get the big ui joint from CSS
# 0x804d6cc0 (HSD_JObj *)
.set job_x30_ptr,       0x804d6cc0 
.set job_x30,           0x810dc540
.set job_x30_5,         0x810ea2a0
.set job_x30_16,        0x811032c0
.set job_x30_16_1,      0x81103360
.set job_x30_16_2,      0x81103b00
.set job_x30_16_3,      0x81104380
.set job_x30_16_4,      0x81104c00
.set job_x30_16_1_1,    0x81103400
.set job_x30_16_2_1,    0x81103ba0
.set job_x30_16_3_1,    0x81104420
.set job_x30_16_4_1,    0x81104ca0
.set known_flags,       0x00080208
.set func_text_update_subtext_pos, 0x803a746c
.set func_jobj_remove,             0x80371370  
.set func_jobj_remove_anim_all,    0x8036f6b4 
.set func_jobj_set_flags,          0x80371D00
.set func_jobj_hide,               func_jobj_set_flags
load r11, job_x30_16_1
load r7, known_flags

# Indev / debug loop to find the correct address for the JObj. This can be removed once functionallity is complete.
# Loop its children until find a flags of known_flags
# That's the one to try and hide.
    lwz r11, 0x10(r11) # Child of JObj
    li r9, 1
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

# Scale card to FP_CONST_... X size
    mr r7, r3
	li r9, 16 # Number of scale_loop_vars
	li r10, 0
	bl scale_p1_vars
	mflr r6
	bl FP_CONST_SIXTY
	mflr r5

b scale_card_loop
scale_p1_vars:
blrl
# P1
    .long 0x810ea340    # Rectangle border
	.long 0x810ecae0    # Char portrait
	.long 0x810eba00    # Category logo
	.long 0x81103400    # HMN tag
# P2
    .long 0x810EA3E0    # Rectangle border
    .long 0x810ecb80    # Char portrait
	.long 0x810ebb20    # Category logo
	.long 0x81103ba0    # HMN tag
# P3
    .long 0x810ea480    # Rectangle border
	.long 0x810ecca0    # Char portrait
	.long 0x810ebbc0    # Category logo
	.long 0x81104420    # HMN tag
# P4
    .long 0x810ea580    # Rectanlge border
    .long 0x810ecd40    # Char portrait
	.long 0x810ebc60    # Category logo
	.long 0x81104ca0    # HMN tag
text_label_gobjs:
blrl
    .long 0x80bd5c88    # P1 Char Label
	.long 0x80bd5f68    # P2 Char Label
	.long 0x80bd6418    # P3 Char Label
	.long 0x80bd68c8    # P4 Char Label

scale_card_loop:
.set x_pos_offset, 0x38
.set y_pos_offset, 0x3c
.set x_scale_offset, 0x2c
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
	addi r6, r6, 16 # skip P1 vars
	bl FP_CONST_BORDER_POS_X_SHIFT
	mflr r5

# Init loop counters
	li r9, 12 # Number of scale_loop_vars
	li r10, 0
translate_card_loop:
    cmp 0, r9, r10
	beq finished_card_translate_loop

    # main loop logic, get each JObj and translate it
    lwz r3, 0(r6) # Current JObj
	lfs f4, 0(r5) # X = Translate amount
	lfs f5, x_pos_offset(r3) # Current pos
	cmpi 0, r10, 4 # if we're on P1, no mul
	blt no_mul
double_x:
	cmpi 0, r10, 8
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

# Translate char label pos(s)
	lis r4, 0 # Subtext Idx
	bl text_label_gobjs
	mflr r6

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
    lwz r3, 0(r6)  # P1 Label GObj ptr
	fmr f1, f8
	branchl r12, func_text_update_subtext_pos

    addi r6, r6, 4
    lwz r3, 0(r6)  # P2 Label GObj ptr
	fmr f1, f9
	branchl r12, func_text_update_subtext_pos
    
	addi r6, r6, 4
    lwz r3, 0(r6)  # P3 Label GObj ptr
	fmr f1, f10
	branchl r12, func_text_update_subtext_pos
	
	addi r6, r6, 4
    lwz r3, 0(r6)  # P4 Label GObj ptr
	fmr f1, f11
	branchl r12, func_text_update_subtext_pos



# Return / original value
RETURN:
    mr r3, r7
    lmw	r19, 0x00B4 (sp)

