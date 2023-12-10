# ====================
#  Insert at 80262614
# ====================

.include "common.s"
.include "triples_globals.s"

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
FP_CONST_0_1:
blrl
.float 0.6
FP_CONST_1:
blrl
.float 1.0
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
.string "Samus"
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
.string " "
.align 4, 0
END_STR_NAME_TABLE:

BEGIN_CHAR_ID_TABLE:
# We need a mapping of CSS ID -> External ID, and also to know how many 
# Costumes each character has.
# NOTE due to sheik existing, everyone's "external id" after her is actually -1 here for CSS. I dont know why this is.

blrl
.byte 0x15 # Dr Mario
.byte 0x05
.byte 0x08 # Mario
.byte 0x05
.byte 0x07 # Luigi
.byte 0x04
.byte 0x05 # Bowser
.byte 0x04 
.byte 0x0c # Peach
.byte 0x05 
.byte 0x11 # Yoshi
.byte 0x06
.byte 0x01 # Donkey Kong
.byte 0x05
.byte 0x00 # Cpt Falcon
.byte 0x06
.byte 0x18 # Gannon
.byte 0x05
.byte 0x13 # Falco
.byte 0x04
.byte 0x02 # Fox
.byte 0x04
.byte 0x0b # Ness
.byte 0x04
.byte 0x0e # Ice Climbers
.byte 0x04
.byte 0x04 # Kirby
.byte 0x06
.byte 0x10 # Samus
.byte 0x05
.byte 0x12 # Zelda
.byte 0x05
.byte 0x06 # Link
.byte 0x05
.byte 0x14 # Young Link
.byte 0x05
.byte 0x17 # Pichu
.byte 0x04
.byte 0x0d # Pikachu
.byte 0x04
.byte 0x0f # Jigglypuff
.byte 0x05
.byte 0x0a # Mewtwo
.byte 0x04
.byte 0x03 # Game and Watch
.byte 0x04
.byte 0x09 # Marth
.byte 0x05
.byte 0x16 # Roy
.byte 0x05
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

	mulli r3, r3, 2 # table entries are 2b each
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

    # Set alpha to 0.5 or 1 depending if character is selected
	# (Not dependent on keypress, just use existing state)


	# Check if we're P1 (so it only runs once per frame)
p1:
	lbz r3, 4(r31)
	cmpi 0, r3, 1
	bne p2

		# Check if P1 actually has a character selected
	    load r3, 0x803F0E08 # P1 char select data
	    lbz r3, 3(r3)
		cmpi 0, r3, 0x19
		bne p1_update_frame # 0x19 is after the end of the CSS

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
		fmr f3, f1 # Char frame ID
	    load r3, 0x803F0E08 # P1 char select data
	    lbz r3, 1(r3)
	    bl int_to_float # f1 contains costume id
	    
		bl FP_CONST_30
		mflr r3
		lfs f2, 0(r3) # 30
        fmul f1, f1, f2 # Costume offset
		fadd f1, f1, f3 # Result frame (e.g. 0x2 + (1 * 0x30)) = 0x32, fox's orange (first) costume

        # Set frame
        load r3, css_p5_portrait # (P5 portrait JObj*) *
	    lwz r3, 0(r3)
	    load r4, css_manually_animate # Load function addr from globals
	    lwz r4, 0(r4)
	    mtctr r4
        bctrl

		# Update text for current character
        load r3, css_p5_text_gobj
		lwz r3, 0(r3) # GObj *
        load r4, css_p5_text_subtext
		lwz r4, 0(r4) # Subtext JObj *
	    load r5, 0x803F0E08 # P1 char select data
	    lbz r5, 3(r5) # CSS ID
		bl set_css_text


p2:
run_debug_code:

	# Check if P1 A button is pressed
	load r3, 0x804C1FAC # Controller 1 Data
	lwz r4, 0(r3)
	rlwinm. r4, r4, 0, 0x17, 0x17 # Check if A
	beq RETURN

	# Check previous frame was 0
	load r3, 0x804C1FB0 # Controller 1 Data Prev Frame
	lwz r4, 0(r3)
	rlwinm. r4, r4, 0, 0x17, 0x17 # Check if A was prev not pressed
	bne RETURN

	nop
	nop
	li r3, 1
	load r4, css_open_doors
	lwz r4, 0(r4)
	mtctr r4
	bctrl

	nop
	nop
	nop
	
	b RETURN

# Debug code - DOES NOT RUN - keeping for reference
    # Get current frame
	load r3, css_backup_space
	lfs f1, 0(r3) # Current frame

    load r3, css_p5_portrait # (P5 portrait JObj*) *
	lwz r3, 0(r3)
	mtctr r28
    bctrl

	# Increment frame
	load r3, css_backup_space
	lfs f1, 0(r3) # Current frame

	bl FP_CONST_0
	mflr r3
	lfs f2, 0(r3) # 1
	fadd f1, f1, f2

	load r3, css_backup_space
	stfs f1, 0(r3)
		
	## Check if P1 A button is pressed
	#load r3, 0x804C1FAC # Controller 1 Data
	#lwz r4, 0(r3)
	#rlwinm. r4, r4, 0, 0x17, 0x17 # Check if A
	#beq RETURN

	## Check previous frame was 0
	#load r3, 0x804C1FB0 # Controller 1 Data Prev Frame
	#lwz r4, 0(r3)
	#rlwinm. r4, r4, 0, 0x17, 0x17 # Check if A was prev not pressed
	#bne RETURN
		

after_inc_portrait:

# Return / original value
RETURN:
    lmw	r19, 0x00B4 (sp)

