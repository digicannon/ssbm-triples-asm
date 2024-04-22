# Insert at 80264E48 
# At this point the puck has already been created.
# GObj, data pointer, etc. all done.
# r0 is free.
# r3 is free.
# r4 maybe free?

.include "Common.s"
.include "triples.s"

.set reg_puck_gobj, 17
.set reg_puck_data_ptr_dest_iter, 20 # Current pointer to slot in CSS_PuckObjPointers.
.set reg_player_idx_iter, 22
.set reg_puck_data_ptr, 23

.set addr_puck_creation, 0x80264D88

    b begin

init_puck_data:
    li r3, 0
    li r0, 0xFF
    stw reg_puck_gobj, 0(reg_puck_data_ptr)
    stb r3, 5(reg_puck_data_ptr)
    stb r0, 6(reg_puck_data_ptr)
    stb r3, 7(reg_puck_data_ptr)
    blr

begin:

    # Don't do anything if not on main CSS (ID 2).
    lis r3, 0x8047
    ori r3, r3, 0x9D30
    lbz r3, 0(r3)
    cmpi 0, r3, 2
    bne return

    load r3, triples_puck_data_p5
    lwz r0, 0(r3)
    cmpi 0, r0, 0
    bne p5_done
    # Steal this puck for P5.
    stw reg_puck_data_ptr, 0(r3)
    bl init_puck_data
    li r3, 2 # temp
    stb r3, 4(reg_puck_data_ptr) #temp
    branch r3, addr_puck_creation
p5_done:

    load r3, triples_puck_data_p6
    lwz r0, 0(r3)
    cmpi 0, r0, 0
    bne p6_done
    # Steal this puck for P6.
    stw reg_puck_data_ptr, 0(r3)
    bl init_puck_data
    li r3, 3 # temp
    stb r3, 4(reg_puck_data_ptr) #temp
    branch r3, addr_puck_creation
p6_done:

return:
    # Original instruction.
    stw reg_puck_data_ptr, 0(reg_puck_data_ptr_dest_iter)
