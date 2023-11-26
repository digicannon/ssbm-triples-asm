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
FP_CONST_SIXTY_SIX:
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
	#mulli  r28, r28, 0x10 # r28 is the index in the string table
	li    r28, 400
	add   r5, r5, r28
	branchl r12, Text_UpdateSubtextContents

# Return / original value
RETURN:
    mr r3, r7
    lmw	r19, 0x00B4 (sp)

