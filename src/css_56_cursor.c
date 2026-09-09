// P5 and P6 on the CSS: a hand, puck and door card each, run by the stock
// procs.  Those index 4-entry per-port arrays, so each P5/P6 proc call runs
// with slot 0 swapped for the port's own copy (pad, hand, puck, doors, tag,
// player data) and swapped back after.
//
// The card is a copy of door 0's pieces grafted onto the end of the scene
// tree, so the stock door code reaches it through the scene root with joint
// ids past the stock ones.

#include "css_56_cursor.h"

#include <float.h>

#include "css.h"

// assets/css_digit_*.png, 16x24 IA4.
extern const u8 css_digit_5[];
extern const u8 css_digit_6[];

#define PLATE_JOINT 0x3D // Door 0's name plate: skinned, six joints.
#define PLATE_JOINTS 6
#define SCENE_JOINTS 0xAD // Joints in the VS scene; grafts index from here.
#define GRAFT_JOINTS 31 // Root plus door 0's pieces.
// The label: 32x24 IA4 in 8x4 tiles.
#define TILE_W 8
#define TILE_H 4
#define TILE (TILE_W * TILE_H)
#define LABEL_TILE_COLUMNS 4
#define LABEL_TILE_ROWS 6
#define LABEL_SIZE (LABEL_TILE_COLUMNS * LABEL_TILE_ROWS * TILE)

// Joint indices of door 0's pieces in a P5/P6 card, the copy grafted onto
// the scene, in door_pieces order.
#define CARD_BG 1
#define CARD_EMBLEM 2
#define CARD_COSTUME 3
#define CARD_TEAM 4
#define CARD_PLATE 5 // Six joints.
#define CARD_CPUSLIDER2 8
#define CARD_CPUSLIDER 9
#define CARD_DOTS 11
#define CARD_NAMETAG_WINDOW 17
#define CARD_NAME 21
#define CARD_DOOR 22
#define CARD_INDICATOR 30

// Door 0's top-level joints in the VS scene with their group parents:
// background, emblem, costume, team, name plate and sliders, stock dots,
// nametag window and its two text anchors, door frame, indicator.
static const u8 door_pieces[][2] = {
    {0x29, 0x28}, {0x2E, 0x2D}, {0x33, 0x32}, {0x38, 0x37}, {0x3D, 0x3C},
    {0x57, 0x56}, {0x70, 0x6F}, {0x73, 0x6F}, {0x74, 0x6F}, {0x85, 0x84},
    {0xA5, 0xA4},
};

// CSSDoor joints, then CSSTag joints, in the graft.
static const u8 door_graft_ids[9] = {CARD_EMBLEM, CARD_COSTUME, CARD_TEAM, CARD_DOOR, CARD_BG, CARD_INDICATOR, 5, CARD_CPUSLIDER, CARD_CPUSLIDER2};
static const u8 tag_graft_ids[5] = {CARD_NAMETAG_WINDOW, 20, CARD_NAME, 19, 18};

// Hand and puck frames: row = the stock P1..P4 label (set_label replaces
// it), column = red/blue/yellow/green.
static const u8 hand_frames[2] = {2, 7};

// Four SJIS dots: what the texts are sized for at init.
static const char placeholder[] = "\x81\x45\x81\x45\x81\x45\x81\x45";

// Per port, HSD_MemAlloc'd and owned by the hand GObj.  The stock structs
// sit first so the hand's user data is its CSSCursorData and the puck's is
// its CSSCharModel.
typedef struct PortBlock {
    CSSCursorData cursor;
    u8 port;
    u8 frame;
    u8 teams; // css_is_teams as of the last swap.
    u8 puck_teams; // ...and as of the puck's last frame.
    CSSCharModel puck;
    CSSDoor doors[4]; // Door 0 is this port's; the rest never open.
    CSSTagData tag;
    CSSTag tag_slot;
    HSD_JObj * root; // The port's grafted subtree.
    HSD_GObj stub; // Stands in for a GObj when running the scene proc.
    // What the stock's slot 0 holds while this port is swapped out: this
    // port's hand and puck, and the other way round while swapped in.
    CSSCursorData * hand_slot;
    CSSCharModel * puck_slot;
    HSD_ImageDesc label_desc;
    u8 label[LABEL_SIZE] __attribute__((aligned(32)));
} PortBlock;
ASSERT_OFFSET(PortBlock, cursor, 0);

// P5 and P6's blocks, at a fixed address so code outside the procs can find
// them.  Set on every four-door CSS load; on any other screen they point at
// freed memory.
extern PortBlock * css_56_blocks[2];

bool css_56_cursor_holding() {
    if (css_door_count != 4) return false;
    for (int i = 0; i < 2; ++i) {
        const PortBlock * bk = css_56_blocks[i];
        if (bk->cursor.state == HAND_HOLDING || bk->tag.state != 0) return true;
    }
    return false;
}

int css_56_swapped_port() {
    const PortBlock * bk = (const PortBlock *)css_hands[0];
    return css_pucks[0] == &bk->puck ? bk->port : -1;
}

static HSD_TObj * label_tobj(HSD_JObj * joint) {
    return joint->dobj->mobj->tobj;
}

static void noop(void * data) {
    (void)data;
}

static void * copy_chain(const void * node, int kind);

// A copy of the node, without its siblings.
static void * copy_node(const void * node, int kind, bool with_children) {
    if (!node) return NULL;
    void * copy = HSD_MemAlloc(css_node_kinds[kind].size);
    memcpy(copy, node, css_node_kinds[kind].size);
    NEXT(copy, kind) = NULL;
    CHILD(copy, kind) = with_children ? copy_chain(CHILD(node, kind), kind) : NULL;
    return copy;
}

static void * copy_chain(const void * node, int kind) {
    if (!node) return NULL;
    void * copy = copy_node(node, kind, true);
    NEXT(copy, kind) = copy_chain(NEXT(node, kind), kind);
    return copy;
}

static void free_tree(void * node, int kind) {
    if (!node) return;
    free_tree(CHILD(node, kind), kind);
    free_tree(NEXT(node, kind), kind);
    HSD_Free(node);
}

// A copy of the scene's root of that kind whose only children are door 0's
// pieces, in door_pieces order.  Only needed while loading; free_tree after.
static void * build_tree(int kind) {
    void * scene = css_anim_table[ANIM_SCENE].desc[kind];
    void * root = copy_node(scene, kind, false);
    void * prev = NULL;
    for (unsigned i = 0; i < sizeof(door_pieces) / sizeof(door_pieces[0]); ++i) {
        int index = door_pieces[i][0];
        void * copy = copy_node(css_find_node(scene, kind, &index), kind, true);
        if (kind == KIND_JOINT) {
            // Joints lose their group parent, so its translation moves into
            // the copy (the groups have no scale or rotation).
            index = door_pieces[i][1];
            HSD_JObjDesc * group = css_find_node(scene, kind, &index);
            HSD_JObjDesc * joint = copy;
            for (int axis = 0; axis < 3; ++axis) joint->position[axis] += group->position[axis];
        }
        if (prev) NEXT(prev, kind) = copy;
        else CHILD(root, kind) = copy;
        prev = copy;
    }
    return root;
}

// Maps the plate's six original descs to that tree's plate joints.
static void bind_plate(HSD_JObj * tree, int plate) {
    for (int i = 0; i < PLATE_JOINTS; ++i) {
        int index = PLATE_JOINT + i;
        void * desc = css_find_node(css_anim_table[ANIM_SCENE].desc[KIND_JOINT], KIND_JOINT, &index);
        HSD_IDInsertToTable(NULL, desc, css_child(tree, plate + i));
    }
}

static void setup_model(HSD_GObj * gobj, HSD_JObj * jobj, const CSSAnim * anim, int gx_link) {
    GObj_AddToObj(gobj, 4, jobj);
    GObj_SetupGXLink(gobj, HSD_GObj_JObjCallback, gx_link, 0x80);
    HSD_JObjAddAnimAll(jobj, anim->desc[1], anim->desc[2], anim->desc[3]);
    HSD_JObjReqAnimAll(jobj, 0.0f);
    HSD_JObjAnimAll(jobj);
    HSD_ForeachAnim(jobj, HSD_TYPE_JOBJ, ALL_TYPE_MASK, HSD_AObjStopAnim, HSD_TYPE_JOBJ, 0, 0);
}

// Melee places the list text from its joint before css_rescale_doors runs.
static void move_list(HSD_JObj * anchor, Text * list) {
    f32 squeeze = css_child(css_scene_root, BG_JOINT)->scale[0];
    f32 pos[3];
    JObj_WorldPos(anchor, NULL, pos);
    list->pos_x = pos[0] - 0.6f * squeeze;
    list->box_size_x = 154.0f * squeeze * NAMETAG_WINDOW_STRETCH;
}

// A door's character name text as the stock makes it, but squeezed like the
// door.  css_door_refresh fills in the name and shows or hides it.
static void make_text(HSD_JObj * anchor, CSSTagData * tag) {
    // The CSS's own canvas is the latest font 0 one.
    int canvas = -1;
    for (const TextCanvas * c = text_canvases; c; c = c->next) {
        if (c->font == 0) ++canvas;
    }
    Text * text = Text_Create(0, canvas);
    text->x4c = text->default_fitting = text->default_alignment = 1;
    text->font_size_x = 0.058f;
    text->font_size_y = 0.055f;

    // The text fits itself to its box, so only the box is squeezed.  A
    // little wider than the stock 160 so long names fit the squeezed plate.
    f32 squeeze = css_child(css_scene_root, BG_JOINT)->scale[0];
    text->box_size_x = 162.0f * squeeze;
    text->box_size_y = 32.0f;

    f32 pos[3];
    JObj_WorldPos(anchor, NULL, pos);
    text->pos_x = pos[0] + 0.5f * squeeze;
    text->pos_y = -0.4f - pos[1];
    text->pos_z = pos[2];

    Text_InitSubtext(text, 81.0f * squeeze, 0.0f, placeholder);
    // A tag in use is written once at CSS build; css_door_refresh leaves it.
    if (tag->use_tag) {
        Text_SetSubtext(text, 0, GetNameText(players[tag->port].nametag));
        text->default_kerning = 0;
    }
    tag->text = text;
}

// Our label: the loaded P1 image with the digit half replaced from the
// asset: tile columns 2-3 in English, 0-1 in Japanese.  The "P" reaches one
// pixel into that half, so the boundary column (the half's first in
// English, last in Japanese) keeps P1's pixels.
static void make_label(PortBlock * bk, const HSD_ImageDesc * p1) {
    memcpy(bk->label, p1->image_ptr, LABEL_SIZE);

    bool us = lbLang_IsSavedLanguageUS();
    const u8 * digit = bk->port == 4 ? css_digit_5 : css_digit_6;
    int column = us ? 2 : 0;
    for (int r = 0; r < LABEL_TILE_ROWS; ++r) {
        for (int y = 0; y < TILE_H; ++y) {
            u8 * dst = bk->label + (r * LABEL_TILE_COLUMNS + column) * TILE + y * TILE_W;
            const u8 * src = digit + r * 2 * TILE + y * TILE_W;
            if (us) {
                memcpy(dst + 1, src + 1, TILE_W - 1);
                memcpy(dst + TILE, src + TILE, TILE_W);
            } else {
                memcpy(dst, src, TILE_W);
                memcpy(dst + TILE, src + TILE, TILE_W - 1);
            }
        }
    }

    bk->label_desc = *p1;
    bk->label_desc.image_ptr = bk->label;
    DCFlushRange(bk->label, LABEL_SIZE);
}

// Points a label joint's texture at ours; the stock's anim puts P1 back
// whenever it re-requests the frame.
static void set_label(PortBlock * bk, HSD_JObj * joint) {
    label_tobj(joint)->imagedesc = &bk->label_desc;
}

// Requests the frame on the child and re-animates that subtree only, so
// the rest of the model keeps the stock's frame count.
static HSD_JObj * recolor(HSD_JObj * root, int child, int frame) {
    HSD_JObj * joint = css_child(root, child);
    HSD_JObjReqAnim(joint, frame);
    HSD_JObjAnimAll(joint);
    return joint;
}

static bool pad_plugged(const PortBlock * bk) {
    return triples_converted_output[bk->port - 4].err == 0;
}

// The shadow door's button bounds are door 0's shifted by the card's
// offset.  Reasserted on every swap (real door 0 is P1's then) so nothing
// that writes the door array between frames can stick.
static void set_boxes(PortBlock * bk) {
    for (int i = 0; i < 4; ++i) bk->doors[0].bounds[i] = css_doors[0].bounds[i] + CSS_DOOR_PITCH * bk->port;
}

static void swap(void * a, void * b, size_t size) {
    u8 * p = a;
    u8 * q = b;
    for (size_t i = 0; i < size; ++i) {
        u8 t = p[i];
        p[i] = q[i];
        q[i] = t;
    }
}

// Exchanges the stock's slot 0 with this port's copies; doing it twice
// puts everything back, with the port's copies updated.
static void swap_slot(PortBlock * bk) {
    swap(&HSD_PadCopyStatus[0], &triples_converted_output[bk->port - 4], sizeof(PadStatus));
    swap(css_doors, bk->doors, sizeof(css_doors));
    swap(&players[0], &players[bk->port], sizeof(Player));
    swap(&css_hands[0], &bk->hand_slot, sizeof(void *));
    swap(&css_pucks[0], &bk->puck_slot, sizeof(void *));
    swap(&css_tags[0], &bk->tag_slot, sizeof(CSSTag));
}

// Slot 0 becomes this port until swap_out.
static void swap_in(PortBlock * bk) {
    set_boxes(bk);
    swap_slot(bk);
    css_exit_bits[0] = 1 << bk->port;

    // The teams toggle refreshes only the four doors swapped in at the
    // time, so a change made by a real port reaches the shadow door here.
    if (bk->teams != css_is_teams) {
        bk->teams = css_is_teams;
        css_door_refresh(0);
    }
}

static void swap_out(PortBlock * bk) {
    css_exit_bits[0] = 1;
    swap_slot(bk);

    // ...and one made by this port reaches the real doors.
    if (bk->teams != css_is_teams) {
        bk->teams = css_is_teams;
        for (int i = 0; i < 4; ++i) css_door_refresh(i);
    }
}

// GObj procs.  All three skip the stock proc while the pad is unplugged:
// hand and puck hide, the card closes the door.

static void hand_think(HSD_GObj * gobj) {
    PortBlock * bk = gobj->user_data;
    HSD_JObj * jobj = gobj->hsd_obj;
    if (!pad_plugged(bk)) {
        HSD_JObjSetFlagsAll(jobj, JOBJ_HIDDEN);
        return;
    }
    HSD_JObjClearFlagsAll(jobj, JOBJ_HIDDEN);

    swap_in(bk);
    mnCharSel_CursorThink(gobj);
    swap_out(bk);

    // Stock colors the hand by port; in teams it uses the team color.
    // Either way its label comes back as P1 each frame.
    if (!css_is_teams) recolor(jobj, 3, bk->frame);
    set_label(bk, css_child(jobj, 3));
}

static void puck_think(HSD_GObj * gobj) {
    PortBlock * bk = (PortBlock *)((u8 *)gobj->user_data - offsetof(PortBlock, puck));
    HSD_JObj * jobj = gobj->hsd_obj;
    if (!pad_plugged(bk)) {
        HSD_JObjSetFlagsAll(jobj, JOBJ_HIDDEN);
        return;
    }
    // A mode change need not change the color index for this port, so
    // force the stock's refresh by running out its timer.
    if (bk->puck_teams != css_is_teams) {
        bk->puck_teams = css_is_teams;
        bk->puck.refresh = 0x28;
    }

    swap_in(bk);
    css_puck_think(gobj);
    swap_out(bk);

    // Stock colors the puck by port unless it is CPU gray or a team color
    // (index >= 4).  Joint 4 is the label (row * 4), joint 3 the color
    // (column * 0x28); in teams the color is the team's, so only the label
    // is ours.  Follow the stock's refresh (timer reset to 0) so the color
    // anim plays out in between.
    if (bk->puck.refresh != 0 || bk->puck.color >= 4) return;
    HSD_JObj * label = recolor(jobj, 4, bk->frame & ~3);
    // The label holds its frame; the color plays.
    HSD_ForeachAnim(label, HSD_TYPE_JOBJ, TOBJ_MASK, HSD_AObjStopAnim, HSD_TYPE_JOBJ, 0, 0);
    set_label(bk, label);
    if (!css_is_teams) recolor(jobj, 3, (bk->frame & 3) * 0x28);
}

// Unplugging closes the door (the stock would make it a CPU), and the
// player table follows in css_player_data_update.
static void card_unplugged(PortBlock * bk) {
    if (bk->doors[0].p_kind == PKIND_CLOSED) return;
    bk->doors[0].p_kind = PKIND_CLOSED;
    bk->doors[0].sel_icon = ICON_NONE;
    bk->cursor.state = 0;
    bk->puck.x5 = 0;

    swap_in(bk);
    css_door_refresh(0);
    swap_out(bk);

    // The name box follows the door only while the shadow scene proc runs.
    HSD_JObjSetFlagsAll(css_child(css_scene_root, BOX_JOINT_BASE + bk->port), JOBJ_HIDDEN);
}

static void card_think(HSD_GObj * gobj) {
    PortBlock * bk = gobj->user_data;
    if (!pad_plugged(bk)) {
        card_unplugged(bk);
        return;
    }
    // The scene proc also counts down the icon flash timers and resets the
    // icon on the tree it was given; leave that to the real scene proc.
    u8 timers[ICON_COUNT];
    for (int i = 0; i < ICON_COUNT; ++i) timers[i] = css_icons[i].anim_timer;
    swap_in(bk);
    css_scene_think(&bk->stub);
    swap_out(bk);
    for (int i = 0; i < ICON_COUNT; ++i) css_icons[i].anim_timer = timers[i];
}

static void create_port(int port, void * joint_tree, void * anim_tree, void * matanim_tree) {
    PortBlock * bk = HSD_MemAlloc(sizeof(*bk));
    memset(bk, 0, sizeof(*bk));
    css_56_blocks[port - 4] = bk;
    bk->port = port;
    bk->frame = hand_frames[port - 4];
    bk->cursor.x = port == 4 ? 20.0f : 26.0f;
    bk->cursor.y = -21.5f;
    bk->cursor.state = HAND_FREE;
    bk->hand_slot = &bk->cursor;
    bk->puck.color = 0xFF;
    bk->puck_slot = &bk->puck;

    // Shadow doors start from the real ones for the joint ids, all closed
    // with nothing picked.  Door 0 keeps P1's team, which is 0.
    memcpy(bk->doors, css_doors, sizeof(bk->doors));
    for (int i = 0; i < 4; ++i) {
        CSSDoor * door = &bk->doors[i];
        door->p_kind = door->p_kind_prev = PKIND_CLOSED;
        door->sel_icon = door->sel_icon_prev = ICON_NONE;
        // No button can be hit: their pieces are the real doors'.  Door 0's
        // bounds are set by set_boxes.
        door->bounds[0] = door->bounds[2] = FLT_MAX;
        door->bounds[1] = door->bounds[3] = -FLT_MAX;
    }

    // Door 0 comes back from players[port] like the stock doors do, so a
    // pick survives a match.
    Player * player = &players[port];
    bk->doors[0].p_kind = player->slot_type;
    bk->doors[0].costume = player->color;
    bk->doors[0].team = player->team;
    // The stock floors every door's CPU level to 1 at CSS entry, but only
    // for its four slots.
    if (player->cpu_level == 0) player->cpu_level = 1;

    for (int i = 0; i < ICON_COUNT; ++i) {
        if (css_icons[i].char_kind != player->ckind) continue;
        bk->doors[0].sel_icon = bk->doors[0].sel_icon_prev = i;
        bk->puck.x = bk->puck.x10 = css_icons[i].bound_l + 3.4f;
        bk->puck.y = bk->puck.x14 = css_icons[i].bound_u - 3.0f;
        break;
    }

    // Door 0's and tag 0's joint ids move to the graft.
    int graft = SCENE_JOINTS + GRAFT_JOINTS * (port - 4);
    for (int i = 0; i < 9; ++i) bk->doors[0].joints[i] = door_graft_ids[i] + graft;
    bk->tag_slot = css_tags[0];
    for (int i = 0; i < 5; ++i) bk->tag_slot.joints[i] = tag_graft_ids[i] + graft;
    bk->tag_slot.data = &bk->tag;

    // Shadow tag data starts from P1's (valid text pointers) with no tag in
    // use.
    bk->tag = *css_tags[0].data;
    bk->tag.state = 0;
    bk->tag.use_tag = 0;

    HSD_GObj * hand = GObj_Create(4, 5, 0x80);
    bk->cursor.gobj = hand;
    const CSSAnim * hand_anim = &css_anim_table[ANIM_HAND];
    HSD_JObj * hand_jobj = HSD_JObjLoadJoint(hand_anim->desc[0]);
    setup_model(hand, hand_jobj, hand_anim, 3);
    GObj_AddProc(hand, hand_think, 1);
    GObj_AddUserData(hand, 4, HSD_Free, bk);

    HSD_GObj * puck = GObj_Create(4, 5, 0x80);
    bk->puck.gobj = puck;
    const CSSAnim * puck_anim = &css_anim_table[ANIM_PUCK];
    HSD_JObj * puck_jobj = HSD_JObjLoadJoint(puck_anim->desc[0]);
    setup_model(puck, puck_jobj, puck_anim, 2);
    // The hand and puck share one set of label textures, P1-P4 and CP; the
    // puck's label (joint 4) shows P1 at frame 0.
    make_label(bk, label_tobj(css_child(puck_jobj, 4))->imagedesc);
    GObj_AddProc(puck, puck_think, 2);
    GObj_AddUserData(puck, 4, noop, &bk->puck);

    // Card: door 0's pieces, squeezed like the stock doors, placed
    // CSS_DOOR_PITCH * port right of where door 0 ended up, and grafted
    // onto the scene.
    HSD_JObj * card = HSD_JObjLoadJoint(joint_tree);
    bk->root = card;
    // The plate is skinned to joints found by desc through the ID table,
    // which still names the real door 0's.  Point those descs at the copy,
    // resolve again, and point them back.
    bind_plate(card, CARD_PLATE);
    HSD_JObjResolveRefsAll(card, joint_tree);
    bind_plate(css_scene_root, PLATE_JOINT);
    HSD_JObjAddAnimAll(card, anim_tree, matanim_tree, NULL);
    HSD_JObjReqAnimAll(card, 0.0f);
    HSD_JObjAnimAll(card);
    HSD_ForeachAnim(card, HSD_TYPE_JOBJ, ALL_TYPE_MASK, HSD_AObjStopAnim, HSD_TYPE_JOBJ, 0, 0);
    bk->stub.hsd_obj = css_scene_root;

    const HSD_JObj * bg0 = css_child(css_scene_root, BG_JOINT);
    f32 squeeze = bg0->scale[0];
    card->scale[0] = squeeze;
    card->translate[0] = bg0->translate[0] - css_child(card, CARD_BG)->translate[0] * squeeze + CSS_DOOR_PITCH * port;
    HSD_JObjSetMtxDirty(card);
    HSD_JObj * window = css_child(card, CARD_NAMETAG_WINDOW);
    window->scale[0] = NAMETAG_WINDOW_STRETCH;
    window->translate[0] = css_child(card, CARD_BG)->translate[0];
    HSD_JObjSetMtxDirty(window);

    // The KO stars are the stock dots subtree; triples shows none.
    HSD_JObjSetFlagsAll(css_child(card, CARD_DOTS), JOBJ_HIDDEN);
    HSD_JObjAddChild(css_scene_root, card);

    // The card proc only needs a GObj to run from.
    HSD_GObj * card_gobj = GObj_Create(4, 5, 0x80);
    GObj_AddProc(card_gobj, card_think, 4);
    GObj_AddUserData(card_gobj, 4, noop, bk);

    set_boxes(bk);
    make_text(css_child(card, CARD_NAME), &bk->tag);

    // Draw the door in its restored state, name included.
    swap_in(bk);
    css_door_refresh(0);
    swap_out(bk);

    // CPU level knob at the saved level, as the stock leaves its doors.
    // With handicap on the level moves to cpuslider2 and css_door_refresh
    // places the handicap knob.
    HSD_JObj * knob = css_child(card, gmMainLib_GetGameRules()->handicap ? CARD_CPUSLIDER2 : CARD_CPUSLIDER);
    knob->translate[0] = (player->cpu_level - 1) * 1.25f;
    HSD_JObjSetMtxDirty(knob);
}

void css_56_create() {
    // One compact copy of the descs (joint, anim, mat anim) serves both ports.
    void * joint_tree = build_tree(KIND_JOINT);
    void * anim_tree = build_tree(KIND_ANIM);
    void * matanim_tree = build_tree(KIND_MATANIM);

    // The stock doors' texts were laid out before css_rescale_doors.c ran
    // and are text, not joints.
    for (int i = 0; i < 4; ++i) {
        css_tags[i].data->text->hidden = 1;
        make_text(css_child(css_scene_root, 0x74 + 5 * i), css_tags[i].data);
        move_list(css_child(css_scene_root, 0x73 + 5 * i), css_tags[i].data->name_ls);
        css_door_refresh(i);
    }

    for (int port = 4; port < 6; ++port) create_port(port, joint_tree, anim_tree, matanim_tree);
    free_tree(joint_tree, KIND_JOINT);
    free_tree(anim_tree, KIND_ANIM);
    free_tree(matanim_tree, KIND_MATANIM);
}
