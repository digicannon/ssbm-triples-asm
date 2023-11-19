# ====================
#  Insert at 80262614
# ====================

.include "common.s"
.include "triples_globals.s"

# Get P2's hover (debug mode)
.set p2_char_select, 0x803F0E2C # 2 bytes off from the sheet, but i watched it happen
.set reg_stringtable, 31

b END_STR_NAME_TABLE
STR_NAME_TABLE:
nop
nop
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
    lwz   r28, 0(r28)
    andi. r28, r28, 0xff
    
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

# Return / original value
lmw	r19, 0x00B4 (sp)
