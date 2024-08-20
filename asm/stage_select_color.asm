# ====================
#  Insert at 80259F00
# ====================

.include "common.s"

    b entry

.set stage_type_neutral, 0 # Neutral starts supported.
.set stage_type_frozen, 1  # Neutral starts supported + frozen stage codes.
.set stage_type_vanilla, 2 # Unchanged, unfair starting positions for 5+6.

.set reg_stage_index, 30

stage_types:
    blrl
    .byte stage_type_neutral # 00, Peach's Castle.
    .byte stage_type_neutral # 01, Rainbow Cruise.
    .byte stage_type_neutral # 02, Kongo Jungle.
    .byte stage_type_neutral # 03, Jungle Japes.
    .byte stage_type_vanilla # 04, Great Bay.
    .byte stage_type_vanilla # 05, Hyrule Temple.
    .byte stage_type_neutral # 06, Yoshi's Story.
    .byte stage_type_vanilla # 07, Yoshi's Island.
    .byte stage_type_neutral # 08, Fountain of Dreams.
    .byte stage_type_frozen  # 09, Green Greens.
    .byte stage_type_neutral # 0A, Corneria.
    .byte stage_type_neutral # 0B, Venom.
    .byte stage_type_neutral # 0C, Brinstar.
    .byte stage_type_vanilla # 0D, Brinstar Depths.
    .byte stage_type_vanilla # 0E, Onett.
    .byte stage_type_neutral # 0F, Fourside.
    .byte stage_type_vanilla # 10, Mute City.
    .byte stage_type_vanilla # 11, Big Blue.
    .byte stage_type_neutral # 12, Pokemon Stadium.
    .byte stage_type_vanilla # 13, Pokefloats.
    .byte stage_type_vanilla # 14, Mushroom Kingdom.
    .byte stage_type_vanilla # 15, Mushroom Kingdom II.
    .byte stage_type_vanilla # 16, Icicle Mountain.
    .byte stage_type_vanilla # 17, Flat Zone.
    .byte stage_type_neutral # 18, Battlefield.
    .byte stage_type_frozen  # 19, Final Destination.
    .byte stage_type_neutral # 1A, Dreamland 64.
    .byte stage_type_vanilla # 1B, Yoshi 64.
    .byte stage_type_neutral # 1C, Kongo Jungle 64.
    .byte stage_type_neutral # 1D, RANDOM.
    .align 4

color_table:
    blrl
    .long 0xFFFFFFFF # 0, neutral.
    .long 0x6060FFFF # 1, frozen.
    .long 0xFF6060FF # 2, vanilla.
    .align 4

entry:
    # r3 = stage_types[reg_stage_index]
    bl stage_types
    mflr r3
    add r3, r3, reg_stage_index
    lbz r3, 0(r3)

    # r3 = color_table[stage_type]
    bl color_table
    mflr r29
    mulli r3, r3, 4 # Size of color_table RGBA entry.
    add r29, r29, r3
    lwz r3, 0(r29)

.set cursor_color, 0x80C8EA04
.set stage_icon_color, 0x80C79964
.set stage_text_color, 0x80C73758
    load r29, cursor_color
    stw r3, 0(r29)
    load r29, stage_icon_color
    stw r3, 0(r29)
    load r29, stage_text_color
    stw r3, 0(r29)

return:
    # Undo clobber + original code line.
    li r3, 4
    stw	r28, 0x0030(sp)
