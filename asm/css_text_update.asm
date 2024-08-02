# ====================
#  Insert at 80262614
# ====================

.include "common.s"
.include "triples.s"

b BEGIN_CODE
FP_CONST_NINE_TWO:
blrl
.float 0.92
FP_CONST_SIXTY_SIX:
blrl
.float 0.66
FP_CONST_0:
blrl
.float 0.0
FP_CONST_0_5:
FP_CONST_HALF:
blrl
.float 0.5
FP_CONST_0_1:
blrl
.float 0.6
FP_CONST_1:
FP_CONST_ONE:
blrl
.float 1.0
FP_CONST_2:
FP_CONST_TWO:
blrl
.float 2.0
FP_CONST_THREE:
blrl
.float 3.0
FP_CONST_15:
blrl
.float 15.0
FP_CONST_30:
blrl
.float 30.0
FP_CONST_32:
blrl
.float 32.0

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

BG_COLOR_TABLE:
blrl # Are these values right?
.long 0xE54C4CFF # Red
.long 0x4B4CE5FF # Blue
.long 0x00B200FF # Green

STR_NAME_TABLE:
# Do not remove these nop(s). They are for alignment and the string table will break without them.
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
.string "DK"
.align 4, 0
.string "Falcon"
.align 4, 0
.string "Ganon"
.align 4, 0
.string "Falco"
.align 4, 0
.string "Fox"
.align 4, 0
.string "Ness"
.align 4, 0
.string "Wobblers"
.align 4, 0
.string "Kirby"
.align 4, 0
.string "Samus"
.align 4, 0
.string "Zelda"
.align 4, 0
.string "Link"
.align 4, 0
.string "smol"
.align 4, 0
.string "Pichu"
.align 4, 0
.string "Pikachu"
.align 4, 0
.string "Puff"
.align 4, 0
.string "Mewtwo"
.align 4, 0
.string "Mr G"
.align 4, 0
.string "Marth"
.align 4, 0
.string "Roy"
.align 4, 0
.string " "
.align 4, 0
END_STR_NAME_TABLE:

BEGIN_CHAR_ID_TABLE:
# We need a mapping of CSS ID -> External ID, and also to know how many 
# Costumes each character has.
# NOTE due to sheik existing, everyone's "external id" after her is actually -1 here for CSS. I dont know why this is.

blrl
.byte 0x15 # Dr Mario
.byte 0x01 #r
.byte 0x02 #g
.byte 0x03 #b
.byte 0x08 # Mario
.byte 0x00 #r
.byte 0x03 #g
.byte 0x04 #b
.byte 0x07 # Luigi
.byte 0x03 #r
.byte 0x02 #b
.byte 0x00 #g
.byte 0x05 # Bowser
.byte 0x1
.byte 0x2
.byte 0x0
.byte 0x0c # Peach
.byte 0x0
.byte 0x3
.byte 0x4
.byte 0x11 # Yoshi
.byte 0x1
.byte 0x2
.byte 0x0
.byte 0x01 # Donkey Kong
.byte 0x2
.byte 0x3
.byte 0x4
.byte 0x00 # Cpt Falcon
.byte 0x2
.byte 0x5
.byte 0x4
.byte 0x18 # Gannon
.byte 0x1
.byte 0x2
.byte 0x3
.byte 0x13 # Falco
.byte 0x1
.byte 0x2
.byte 0x3
.byte 0x02 # Fox
.byte 0x1
.byte 0x2
.byte 0x3
.byte 0x0b # Ness
.byte 0x0
.byte 0x2
.byte 0x3
.byte 0x0e # Ice Climbers
.byte 0x3
.byte 0x0
.byte 0x1
.byte 0x04 # Kirby
.byte 0x3
.byte 0x2
.byte 0x4
.byte 0x10 # Samus
.byte 0x0
.byte 0x4
.byte 0x3
.byte 0x12 # Zelda
.byte 0x1
.byte 0x2
.byte 0x3
.byte 0x06 # Link
.byte 0x1
.byte 0x2
.byte 0x0
.byte 0x14 # Young Link
.byte 0x1
.byte 0x2
.byte 0x0
.byte 0x17 # Pichu
.byte 0x1
.byte 0x2
.byte 0x3
.byte 0x0d # Pikachu
.byte 0x1
.byte 0x2
.byte 0x3
.byte 0x0f # Jigglypuff
.byte 0x1
.byte 0x2
.byte 0x3
.byte 0x0a # Mewtwo
.byte 0x1
.byte 0x2
.byte 0x3
.byte 0x03 # Game and Watch
.byte 0x1
.byte 0x2
.byte 0x3
.byte 0x09 # Marth
.byte 0x1
.byte 0x0
.byte 0x2
.byte 0x16 # Roy
.byte 0x1
.byte 0x2
.byte 0x3
.align 4
END_CHAR_ID_TABLE:

# Begin functions
convert_css_to_external_id:
    # R3 should be the css_id
	# R3 on return will be the external Id default costume
	# - Clobbers r3, r4

	stmw r30, -8(sp) # Save r30, r31
    mflr r30         # Backup LR
	mr r31, sp       # Backup SP
	stwu sp, -16(sp)  # Grow stack

	mulli r3, r3, 4 # table entries are 5b each
	bl BEGIN_CHAR_ID_TABLE
	mflr r4         # the table itself
	add r4, r4, r3
	lbz r3, 0(r4)

	mtlr r30          # Restore LR
	mr sp, r31        # Pop the stack
	lmw r30, -8(sp)   # Restore r30, r31
	blr

color_to_costume_id:
	# R3 should be the css_id
	# R4 should be the color, 0=red 1=blue 2=green
	# R3 on return will be the (local) costume id
	# - Clobbers r3, r4
	stmw r30, -8(sp) # Save r30, r31
    mflr r30         # Backup LR
	mr r31, sp       # Backup SP
	stwu sp, -16(sp)  # Grow stack

	mulli r3, r3, 4 # table entries are 5b each
	addi r3, r3, 1  # skip the first 2 bytes
	add r3, r3, r4  # get color offset
	bl BEGIN_CHAR_ID_TABLE
	mflr r4         # the table itself
	add r4, r4, r3
	lbz r3, 0(r4)

	mtlr r30          # Restore LR
	mr sp, r31        # Pop the stack
	lmw r30, -8(sp)   # Restore r30, r31
	blr

int_to_float:
    # R3 should contain your int
	# F1 will contain your float
	# - Clobbers r3, r4, f1, f2
	lis r4, 0x4330
    stw r4, -0x8 (sp)
    lis r4, 0x8000
    stw r4, -0x4 (sp)
    lfd f2, -0x8 (sp) # load magic double into f2
    xoris r3, r3, 0x8000 # flip sign bit
    stw r3, -0x4 (sp) # store lower half (upper half already stored)
    lfd f1, -0x8 (sp)
    fsub f1, f1, f2 # complete conversion
    
	blr

jobj_set_hidden:
    # R3 is the JOBJ *
	# R4 is a bool: 0 to show JObj, nonzero to hide
    # - Clobbers r3, r4, r5, r6
	
	# TODO this function likely needs no stack as I've removed function calls and link register clobbering

	stmw r30, -8(sp)  # Save r30, r31
    mflr r30          # Backup LR
	mr r31, sp        # Backup SP
	stwu sp, -16(sp)  # Grow stack

    stw r3, 12(sp) # Store JObj pointer on stack
	stw r4, 16(sp) # Store bool on stack

    lwz r3, 0x14(r3) # JObj flags

	lwz r4, 16(sp) # Bool flag from stack
    cmpi 0, r4, 0
	mr r4, r3      # Move current flag to r4
	beq jobj_set_hidden_show

	jobj_set_hidden_hide:
	    # Set hidden flag (1 << 4)
		ori r4, r4, 0x16
    	b jobj_set_hidden_set
	jobj_set_hidden_show:
	    # Unset hidden flag
		load r5, 0xFFFFFFEF # Complement of 0x10
		and r4, r4, r5
	jobj_set_hidden_set:
        lwz r3, 12(sp)   # JObj * from stack
		stw r4, 0x14(r3) # Set flags
	
	mtlr r30          # Restore LR
	mr sp, r31        # Pop the stack
	lmw r30, -8(sp)   # Restore r30, r31
	blr

set_card_color:
    # R3 is the JObj * of the portrait
    # R4 is RGB
	# - Clobbers r3
	lwz r3, 0x18(r3)
	lwz r3, 0x08(r3)
	lwz r3, 0x1c(r3)
	lwz r3, 0x08(r3)
	subi r3, r3, 4
	stw r4, 0(r3)
 	blr   

set_css_text:
    # R3 is the GObj * of the text
    # R4 is the subtext *
	# R5 is the CSS ID of the character
	# - Clobbers r3, r4, r5, r6, r7
	stmw r30, -8(sp)  # Save r30, r31
    mflr r30          # Backup LR
	mr r31, sp        # Backup SP
	stwu sp, -16(sp)  # Grow stack

	
	# Make sure give ID is in bounds
	cmpi  0, r5, 0
	blt   INVALID_SELECTION
	cmpi  0, r5, 0x19
	bgt   INVALID_SELECTION
	b VALID_SELECTION
INVALID_SELECTION:
	# Just make the index 'valid'
	li r5, 0x19
    
VALID_SELECTION:
	#lis   r5, dbg_text_gobj @h
	#ori   r3, r5, dbg_text_gobj @l
	#ori   r4, r5, dbg_subtext_str @l
	#lwz   r4, 0(r4)
	#lwz   r3, 0(r3)
	# r3 should still be the GObj
	# r4 should still be subtext *
    mr r7, r5 # Move to r7 for temp storage
	mulli  r7, r7, 0x10 # index in the string table
	bl STR_NAME_TABLE
	mflr r5
	add  r5, r5, r7 # Address of ASCII
	branchl r7, Text_UpdateSubtextContents

	mtlr r30          # Restore LR
	mr sp, r31        # Pop the stack
	lmw r30, -8(sp)   # Restore r30, r31
	blr

BEGIN_CODE:
	# Check if we're P1 (so it only runs once per frame)
p1:
		lbz r3, 4(r31)
		cmpi 0, r3, 1
		bne p2

		# Check if P1 is disabled
		lis r3, 0x803F
		lbz r4, 0x0E08(r3) # P1 player type
		cmpli 0, r4, 3
		beq p1_disabled

		# Check if P1 actually has a character selected
		lbz r4, 0x0E0B(r3) # P1 char select data
		cmpi 0, r4, 0x19
		bne p1_update_frame # 0x19 is after the end of the CSS
		b p1_no_character

p1_disabled:
		# Set BG to gray before hiding portrait
		load r4, 0x65656500 # Disabled gray
		load r3, css_p5_bg
		lwz r3, 0(r3)  # R3 contains P5 BG JObj*
		bl set_card_color
p1_no_character:
		# Set hidden flag for JObj
        load r3, css_p5_portrait # (P5 portrait JObj*) *
	    lwz r3, 0(r3)
		li r4, 1
		bl jobj_set_hidden
        
		# Hide text
		load r3, css_p5_text_gobj
		lwz r3, 0(r3) # GObj *
        load r4, css_p5_text_subtext
		lwz r4, 0(r4) # Subtext JObj *
		li r5, 400
		bl set_css_text

		b p2 # Done with p1

p1_update_frame:
        # Remove hidden flag from JObj
        load r3, css_p5_portrait # (P5 portrait JObj*) *
	    lwz r3, 0(r3)
		li r4, 0
		bl jobj_set_hidden

	    # Convert to External ID
	    load r3, 0x803F0E08 # P1 char select data
	    lbz r3, 3(r3)
	    bl convert_css_to_external_id
	    bl int_to_float

		# Now apply costume
		# First check if team mode is active:
		load r9, 0x804807C8 # Team mode flag
		lbz r9, 0(r9)
		cmpi 0, r9, 0
		fmr f3, f1 # Char frame ID
		beq p1_update_costume

		# else Team mode!
	    load r3, 0x803F0E06 # P1 char select data
	    lbz r4, 0(r3) # Which team

	    load r3, 0x803F0E08 # P1 char select data
	    lbz r3, 3(r3)
		bl color_to_costume_id
	    bl int_to_float
		
		b p1_animate_costume


p1_update_costume:
		# No team mode, just do costume:
	    load r3, 0x803F0E08 # P1 char select data
	    lbz r3, 1(r3)
	    bl int_to_float # f1 contains costume id
	    
p1_animate_costume:
	    load r3, 0x803F0E08 # P1 char select data
	    lbz r3, 1(r3)
		bl FP_CONST_30
		mflr r3
		lfs f2, 0(r3) # 30
        fmul f1, f1, f2 # Costume offset
		fadd f1, f1, f3 # Result frame (e.g. 0x2 + (1 * 0x30)) = 0x32, fox's orange (first) costume

        # Set frame
        load r3, css_p5_portrait # (P5 portrait JObj*) *
	    lwz r3, 0(r3)
		mr r4, r3 # Calc DObj*
		lwz r4, 0x18(r4) # First DObj
	    load r5, css_manually_animate # Load function addr from globals
	    lwz r5, 0(r5)
	    mtctr r5
        bctrl

		# Update P1 background color
		# Easy TODO to save instructions, combine this logic / store register state
		# for previous team check
		load r9, 0x804807C8 # Team mode flag
		lbz r9, 0(r9)
		cmpi 0, r9, 0
		beq p1_orange_background

		# Team mode!
	    load r3, 0x803F0E06 # P1 char select data
	    lbz r4, 0(r3) # Which team: R B G
		bl BG_COLOR_TABLE
	    mflr r5
		mulli r4, r4, 4
		add r5, r5, r4
		lwz r4, 0(r5) # R4 contains corresponding team color

		b set_p1_background
p1_orange_background:
		# No team mode
		load r4, 0xff982600 # P5 Orange

set_p1_background:
		load r3, css_p5_bg
		lwz r3, 0(r3)  # R3 contains P5 BG JObj*
		bl set_card_color

		# Update text for current character
        load r3, css_p5_text_gobj
		lwz r3, 0(r3) # GObj *
        load r4, css_p5_text_subtext
		lwz r4, 0(r4) # Subtext JObj *
	    load r5, 0x803F0E08 # P1 char select data
	    lbz r5, 3(r5) # CSS ID
		bl set_css_text
	    
		# Check if actually selected or hovering
		load r3, 0x81119ec0
		lbz r3, 5(r3)
		cmpi 0, r3, 0
		beq p1_opaque
		# else 
			bl FP_CONST_0_5
			mflr r4
			b set_p1_alpha
p1_opaque:
		bl FP_CONST_1
		mflr r4
set_p1_alpha:
		# Set alpha based on above
        load r3, css_p5_portrait # (P5 portrait JObj*) *
	    lwz r3, 0(r3)
		lfs f1, 0(r4) # f1 alpha value
		# Set alpha for job
			lwz r3, 0x18(r3)
			lwz r3, 0x8(r3)
			lwz r3, 0xc(r3)
			stfs f1, 0xc(r3)


p2:
	# r31 should be unmodified by us, and should contain player
	lbz r3, 4(r31)
	cmpi 0, r3, 2
	bne RETURN

	# Check if P2 is disabled
	lis r3, 0x803F
	lbz r4, 0x0E2C(r3) # P2 player type
    cmpli 0, r4, 3
	beq p2_disabled

	# Check if P2 has anything selected
	lbz r4, 0x0E2F(r3) # P2 char select data
	cmpi 0, r4, 0x19
	bne p2_update_frame # 0x19 is after the end of the CSS
	b p2_no_character

p2_disabled:
		# Set BG to gray before hiding portrait
		load r4, 0x65656500 # Disabled gray
		load r3, css_p6_bg
		lwz r3, 0(r3)  # R3 contains P5 BG JObj*
		bl set_card_color
p2_no_character:
		# Set hidden flag for JObj
		load r3, css_p6_portrait # (P5 portrait JObj*) *
		lwz r3, 0(r3)
		li r4, 1
		bl jobj_set_hidden
		
		# Hide text
		load r3, css_p6_text_gobj
		lwz r3, 0(r3) # GObj *
		load r4, css_p6_text_subtext
		lwz r4, 0(r4) # Subtext JObj *
		li r5, 400
		bl set_css_text

		b RETURN # Done with p2

p2_update_frame:
	# Remove hidden flag from JObj
	load r3, css_p6_portrait # (P5 portrait JObj*) *
	lwz r3, 0(r3)
	li r4, 0
	bl jobj_set_hidden

	# Convert to External ID
	load r3, 0x803F0E2C # P2 char select data
	lbz r3, 3(r3)
	bl convert_css_to_external_id
	bl int_to_float

	# Now apply costume
	# First check if team mode is active:
	fmr f3, f1 # Char frame ID
	load r9, 0x804807C8 # Team mode flag
	lbz r9, 0(r9)
	cmpi 0, r9, 0
	beq p2_update_costume

	# else Team mode!
	load r3, 0x803F0E2A # P2 char select data
	lbz r4, 0(r3) # Which team

	load r3, 0x803F0E2C # P1 char select data
	lbz r3, 3(r3)
	bl color_to_costume_id
	bl int_to_float
	
	b p2_animate_costume

p2_update_costume:
	# No team mode, just do costume:
	load r3, 0x803F0E2C # P2 char select data
	lbz r3, 1(r3)
	bl int_to_float # f1 contains costume id
	
p2_animate_costume:
	load r3, 0x803F0E2C # P2 char select data
	lbz r3, 1(r3)
	bl FP_CONST_30
	mflr r3
	lfs f2, 0(r3) # 30
	fmul f1, f1, f2 # Costume offset
	fadd f1, f1, f3 # Result frame (e.g. 0x2 + (1 * 0x30)) = 0x32, fox's orange (first) costume

	# Set frame
	load r3, css_p6_portrait # (P5 portrait JObj*) *
	lwz r3, 0(r3)
	mr r4, r3 # Calc DObj*
	lwz r4, 0x18(r4) # First DObj
	load r5, css_manually_animate # Load function addr from globals
	lwz r5, 0(r5)
	mtctr r5
	bctrl

	# Update P2 background color
	load r9, 0x804807C8 # Team mode flag
	lbz r9, 0(r9)
	cmpi 0, r9, 0
	beq p2_purple_background

	# Team mode!
	load r3, 0x803F0E2A # P2 char select data
	lbz r4, 0(r3) # Which team: R B G
	# TODO function?
	bl BG_COLOR_TABLE
	mflr r5
	mulli r4, r4, 4
	add r5, r5, r4
	lwz r4, 0(r5) # R4 contains corresponding team color

	b set_p2_background
p2_purple_background:
	# No team mode
	load r4, 0x984ce500 # P6 Purple

set_p2_background:
	load r3, css_p6_bg
	lwz r3, 0(r3)  # R3 contains P5 BG JObj*
	bl set_card_color

	# Update text for current character
	load r3, css_p6_text_gobj
	lwz r3, 0(r3) # GObj *
	load r4, css_p6_text_subtext
	lwz r4, 0(r4) # Subtext JObj *
	load r5, 0x803F0E2C # P2 char select data
	lbz r5, 3(r5) # CSS ID
	bl set_css_text
	
	# Check if actually selected or hovering
	load r3, 0x8111acc0
	lbz r3, 5(r3)
	cmpi 0, r3, 0
	beq p2_opaque
	# else 
		bl FP_CONST_0_5
		mflr r4
		b set_p2_alpha
p2_opaque:
	bl FP_CONST_1
	mflr r4
set_p2_alpha:
	# Set alpha based on above
	load r3, css_p6_portrait # (P5 portrait JObj*) *
	lwz r3, 0(r3)
	lfs f1, 0(r4) # f1 alpha value
	# Set alpha for job
		lwz r3, 0x18(r3)
		lwz r3, 0x8(r3)
		lwz r3, 0xc(r3)
		stfs f1, 0xc(r3)

# Return / original value
RETURN:
    lmw	r19, 0x00B4 (sp)

