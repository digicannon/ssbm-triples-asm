# ====================
#  Insert at 8016e2c0
#  Runs once before match starts
# ====================

.include "common.s"
.include "triples.s"

# Goto code
b BEGIN_CODE

FP_CONST_0:
blrl
.float 0.0
FP_CONST_206_5:
blrl
.float 206.5

CONST_STR_TRIPLES:
blrl
.string "Triples"
END_CONST_TABLE:

BEGIN_CODE:
# Backup 
	stmw r28, -16(sp) # Save r28-r31
	mflr r30          # Backup LR
	mr r31, sp        # Backup SP
	stwu sp, -16(sp)

# Load create_text function into LR
	load r30, fn_create_text
	lwz r30, 0(r30)

# Create some text 
	bl CONST_STR_TRIPLES
	mflr r3
	bl FP_CONST_0
	mflr r5
	lfs f1, 0(r5) # X offset
	bl FP_CONST_0
	mflr r5
	lfs f2, 0(r5) # Y Offset

	# r30 contrains move_trxt
	mtctr r30
	bctrl 
	# r3 is the GObj
	# r4 is the subtext 

# Restore
	mtlr r30           # Restore LR
	mr sp, r31         # Pop the stack
	lmw r28, -16(sp)   # Restore r28-31

# Done our code
# Original instruction
	lis	r3, 0x8047
