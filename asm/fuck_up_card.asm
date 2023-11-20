# ====================
#  Insert at 8025db34 for animation    mflr  r0
#  Insert at 8025db68 for dbg
#  Insert at 8025d5ac
# ====================

.include "triples_globals.s"

ForceZelda:
    # Change local variable to zelda (Forces flashing animation)
    #li r20, 0x0f #animation
    #li r21, 0x0f #dbg
	blr
    
# return
#mflr  r0
	
# Change Global variable for P2 to Zelda
    #lis   r5, p2_char_select @h
    #ori   r5, r5, p2_char_select @l
	#li    r4, 0x0f
    #stb   r4, 2(r5)
    #stb   r4, 3(r5)

