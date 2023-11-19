################################################################################
# Address: 0x802662D0
################################################################################
.include "common.s"
.include "triples_globals.s"

.set REG_TextGObj,31
.set REG_TextProperties,30

NTSC102:
	.set	Injection,0x802662D0
	.set	Text_CreateTextGObj,0x803a6754
	.set	Text_InitializeSubtext,0x803a6b98
	.set	Text_UpdateSubtextSize,0x803a7548
/*
NTSC101:
	.set	Injection,0x80265B34
	.set	Text_CreateTextGObj,0x803A5A74
	.set	Text_InitializeSubtext,0x803A5EB8
	.set	Text_UpdateSubtextSize,0x803A6868
NTSC100:
	.set	Injection,0x80264FB8
	.set	Text_CreateTextGObj,0x803A4890
	.set	Text_InitializeSubtext,0x803A4CD4
	.set	Text_UpdateSubtextSize,0x803A5684

PAL100:
	.set	Injection,0x802669EC
	.set	Text_CreateTextGObj,0x803A6664
	.set	Text_InitializeSubtext,0x803a6b54
	.set<F20>	Text_UpdateSubtextSize,0x803A74FC
*/
backup

#GET PROPERTIES TABLE
	bl TEXTPROPERTIES
	mflr REG_TextProperties

########################
## Create Text Object ##
########################

#CREATE TEXT OBJECT, RETURN POINTER TO STRUCT IN r3
	li r3,0
	li r4,0
	branchl r12,Text_CreateTextGObj

#BACKUP STRUCT POINTER
	mr REG_TextGObj,r3

#SET TEXT SPACING TO TIGHT
	li r4,0x1
	stb r4,0x49(REG_TextGObj)

##SET TEXT TO CENTER AROUND X LOCATION
#	li r4,0x1
#	stb r4,0x4A(REG_TextGObj)

#Scale Canvas Down
	lfs f1,0xC(REG_TextProperties)
	stfs f1,0x24(REG_TextGObj)
	stfs f1,0x28(REG_TextGObj)

####################################
## INITIALIZE PROPERTIES AND TEXT ##
####################################

#Initialize Line of Text
	mr r3,REG_TextGObj       #struct pointer
	bl 	TEXT
	mflr 	r4		#pointer to ASCII
	lfs f1,0x0(REG_TextProperties) #X offset of REG_TextGObj
	lfs f2,0x4(REG_TextProperties) #Y offset of REG_TextGObj
	branchl r12,Text_InitializeSubtext
	
# Store GObj and Subtext to globals
    lis    r28, dbg_text_gobj @h
    ori    r28, r28, dbg_text_gobj @l
    stw    REG_TextGObj, 0(r28)
    lis    r28, dbg_subtext_str @h
    ori    r28, r28, dbg_subtext_str @l
    stw    r3, 0(r28)

# Set Size/Scaling
    mr      r4,r3
    mr      r3,REG_TextGObj
    lfs     f1,0x8(REG_TextProperties) #get REG_TextGObj scaling value from table
    lfs     f2,0x8(REG_TextProperties) #get REG_TextGObj scaling value from table
    branchl	r12,Text_UpdateSubtextSize

# Set text color
    lis   r5, dbg_text_gobj @h
	ori   r3, r5, dbg_text_gobj @l
	ori   r4, r5, dbg_subtext_str @l
	lwz   r3, 0(r3)
	lwz   r4, 0(r4)
	addi  r5, REG_TextProperties, COLOR_BLUE
    branchl	r12, Text_ChangeTextColor

b end


#**************************************************#
TEXTPROPERTIES:
blrl
.float -300		  # x offset
.float 14		  # y offset
.float 0.7		  # REG_TextGObj scaling
.float 0.1		  # canvas scaling
# Begin Colors
.set COLOR_RED, 0x10
.long  0xFF0000F
.set COLOR_ORANGE, COLOR_RED + 0x4
.long  0xF38E0BFF
.set COLOR_BLUE, COLOR_ORANGE + 0x4
.long  0x4B4CE5FF


TEXT:
blrl
.string "Triples    INDEV     Triples    INDEV"
# 80001da4 is where literal starts (inline)
.align 2

#**************************************************#
end:
restore

addi	r4, r24, 0

