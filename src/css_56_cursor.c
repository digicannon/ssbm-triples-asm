#include "css_56_cursor.h"

#include <float.h>

#include "css.h"
#include "css_56_card.h"
#include "triples.h"

// assets/css_digit_*.png, 16x24 IA4.
extern const u8 css_digit_5[];
extern const u8 css_digit_6[];

// The label: 32x24 IA4 in 8x4 tiles.
#define TILE_W 8
#define TILE_H 4
#define TILE (TILE_W * TILE_H)
#define LABEL_TILE_COLUMNS 4
#define LABEL_TILE_ROWS 6
#define LABEL_SIZE (LABEL_TILE_COLUMNS * LABEL_TILE_ROWS * TILE)
#define PENDING_NAME_ENTRY 4 // css_pending_scene_change.

// Hand and puck frames: row = the vanilla P1..P4 label (set_label replaces
// it), column = red/blue/yellow/green.
static const u8 hand_frames[2] = {2, 7};

// Per port, HSD_MemAlloc'd and owned by the hand GObj.  The vanilla structs
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
    HSD_JObj * root; // The port's card.
    HSD_GObj stub; // Stands in for a GObj when running the scene and tag procs.
    // What the vanilla's slot 0 holds while this port is swapped out: this
    // port's hand and puck, and the other way round while swapped in.
    CSSCursorData * hand_slot;
    CSSCharModel * puck_slot;
    HSD_ImageDesc label_desc;
    u8 label[LABEL_SIZE] __attribute__((aligned(32)));
} PortBlock;
ASSERT_OFFSET(PortBlock, cursor, 0);

// P5 and P6's blocks.  Set on every four-door CSS load; on any other screen
// they point at freed memory.
static PortBlock * css_56_blocks[2];

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

static void setup_model(HSD_GObj * gobj, HSD_JObj * jobj, const CSSAnim * anim, int gx_link) {
    GObj_AddToObj(gobj, 4, jobj);
    GObj_SetupGXLink(gobj, HSD_GObj_JObjCallback, gx_link, 0x80);
    HSD_JObjAddAnimAll(jobj, anim->desc[1], anim->desc[2], anim->desc[3]);
    HSD_JObjReqAnimAll(jobj, 0.0f);
    HSD_JObjAnimAll(jobj);
    HSD_ForeachAnim(jobj, HSD_TYPE_JOBJ, ALL_TYPE_MASK, HSD_AObjStopAnim, HSD_TYPE_JOBJ, 0, 0);
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

// Points a label joint's texture at ours; the vanilla's anim puts P1 back
// whenever it re-requests the frame.
static void set_label(PortBlock * bk, HSD_JObj * joint) {
    label_tobj(joint)->imagedesc = &bk->label_desc;
}

// Requests the frame on the child and re-animates that subtree only, so
// the rest of the model keeps the vanilla's frame count.
static HSD_JObj * recolor(HSD_JObj * root, int child, int frame) {
    HSD_JObj * joint = css_child(root, child);
    HSD_JObjReqAnim(joint, frame);
    HSD_JObjAnimAll(joint);
    return joint;
}

static GXColor port_color(const PortBlock * bk) {
    static const GXColor colors[2] = {P5_COLOR, P6_COLOR};
    return colors[bk->port - 4];
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

// Exchanges the vanilla's slot 0 with this port's copies; doing it twice
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

// GObj procs.

static void hand_think(HSD_GObj * gobj) {
    PortBlock * bk = gobj->user_data;
    HSD_JObj * jobj = gobj->hsd_obj;
    swap_in(bk);
    mnCharSel_CursorThink(gobj);
    swap_out(bk);

    if (!css_is_teams) {
        HSD_TObjTev * tev = label_tobj(recolor(jobj, 3, bk->frame))->tev;
        GXColor color = port_color(bk);
        tev->konst.r = color.r;
        tev->konst.g = color.g;
        tev->konst.b = color.b;
    }

    set_label(bk, css_child(jobj, 3));
}

static void puck_think(HSD_GObj * gobj) {
    PortBlock * bk = (PortBlock *)((u8 *)gobj->user_data - offsetof(PortBlock, puck));
    HSD_JObj * jobj = gobj->hsd_obj;
    // A mode change need not change the color index for this port, so
    // force the vanilla's refresh by running out its timer.
    if (bk->puck_teams != css_is_teams) {
        bk->puck_teams = css_is_teams;
        bk->puck.refresh = 0x28;
    }

    swap_in(bk);
    css_puck_think(gobj);
    swap_out(bk);

    // Vanilla colors the puck by port unless it is CPU gray or a team color
    // (index >= 4); in teams the color is the team's, so only the label is
    // ours.  The body carries the port color in all three of its material
    // colors, and re-hueing them every frame leaves the anim's pulse toward
    // white intact.
    if (!css_is_teams && bk->puck.color < 4) {
        HSD_Material * mat = css_child(jobj, 3)->dobj->next->mobj->mat;
        GXColor hue = color_hue(port_color(bk));
        mat->ambient = color_retint(hue, mat->ambient);
        mat->diffuse = color_retint(hue, mat->diffuse);
        mat->specular = color_retint(hue, mat->specular);
    }

    // Joint 4 is the label (row * 4).  Follow the vanilla's refresh (timer
    // reset to 0) so the color anim plays out in between.
    if (bk->puck.refresh != 0 || bk->puck.color >= 4) return;
    HSD_JObj * label = recolor(jobj, 4, bk->frame & ~3);
    // The label holds its frame; the color plays.
    HSD_ForeachAnim(label, HSD_TYPE_JOBJ, TOBJ_MASK, HSD_AObjStopAnim, HSD_TYPE_JOBJ, 0, 0);
    set_label(bk, label);
}

static void card_think(HSD_GObj * gobj) {
    PortBlock * bk = gobj->user_data;
    // The scene proc also counts down the icon flash timers and resets the
    // icon on the tree it was given; leave that to the real scene proc.
    u8 timers[ICON_COUNT];
    for (int i = 0; i < ICON_COUNT; ++i) timers[i] = css_icons[i].anim_timer;
    swap_in(bk);
    css_scene_think(&bk->stub);
    swap_out(bk);
    for (int i = 0; i < ICON_COUNT; ++i) css_icons[i].anim_timer = timers[i];
    if (!css_is_teams && bk->doors[0].p_kind == PKIND_HUMAN) css_56_card_set_color(bk->root, port_color(bk));
}

static void tag_think(HSD_GObj * gobj) {
    PortBlock * bk = gobj->user_data;

    // An unplugged pad only finishes closing the list.
    if (triples_converted_output[bk->port - 4].err != 0 && bk->tag.state == 0) {
        return;
    }

    u8 pending = css_pending_scene_change;
    swap_in(bk);
    css_tag_think(&bk->stub);
    swap_out(bk);

    // Did P5/6 ask for name entry?
    if (pending != PENDING_NAME_ENTRY && css_pending_scene_change == PENDING_NAME_ENTRY) {
        css_name_entry_slot = CSS_NAME_ENTRY_SLOT_56;
        css_name_entry_port = bk->port;
    }
}

static void create_port(int port) {
    PortBlock * bk = HSD_MemAlloc(sizeof(*bk));
    memset(bk, 0, sizeof(*bk));
    css_56_blocks[port - 4] = bk;
    bk->port = port;
    bk->frame = hand_frames[port - 4];
    css_hand_warp_to_spawn(&bk->cursor, port);
    bk->cursor.state = HAND_FREE;
    bk->hand_slot = &bk->cursor;
    bk->puck.color = 0xFF;
    bk->puck_slot = &bk->puck;

    // Shadow doors start from the real ones for the joint ids.
    memcpy(bk->doors, css_doors, sizeof(bk->doors));
    for (int i = 0; i < 4; ++i) {
        CSSDoor * door = &bk->doors[i];
        door->p_kind = door->p_kind_prev = PKIND_CLOSED;
        door->sel_icon = door->sel_icon_prev = ICON_NONE;
        door->dooranim_timer = door->slideranim_timer = 0;
        // No button can be hit: their pieces are the real doors'.
        door->bounds[0] = door->bounds[2] = FLT_MAX;
        door->bounds[1] = door->bounds[3] = -FLT_MAX;
    }
    for (int i = 0; i < 4; ++i) bk->doors[0].bounds[i] = css_doors[0].bounds[i] + CSS_DOOR_PITCH * port;

    // Door 0 comes back from players[port] like the vanilla doors do, so a
    // pick survives a match.
    Player * player = &players[port];
    bk->doors[0].p_kind = player->slot_type;
    bk->doors[0].costume = player->color;
    bk->doors[0].team = player->team;
    // The vanilla floors every door's CPU level to 1 at CSS entry, but only
    // for its four slots.
    if (player->cpu_level == 0) player->cpu_level = 1;

    for (int i = 0; i < ICON_COUNT; ++i) {
        if (css_icons[i].char_kind != player->ckind) continue;
        bk->doors[0].sel_icon = bk->doors[0].sel_icon_prev = i;
        bk->puck.x = bk->puck.x10 = css_icons[i].bound_l + 3.4f;
        bk->puck.y = bk->puck.x14 = css_icons[i].bound_u - 3.0f;
        break;
    }

    bk->tag_slot = css_tags[0];
    bk->tag_slot.data = &bk->tag;
    css_56_card_set_joint_ids(port, &bk->doors[0], &bk->tag_slot);

    // Shadow tag data starts from P1's (valid text pointers).
    bk->tag = *css_tags[0].data;
    bk->tag.state = 0;
    // Back from this port's name entry: the new tag is the first one the
    // vanilla did not know at the last build.
    if (css_name_entry_slot == CSS_NAME_ENTRY_SLOT_56 && css_name_entry_port == port && css_tag_mark < bk->tag.next_tag) {
        player->nametag = css_tag_mark - 1;
        css_tag_mark = bk->tag.next_tag;
    }
    bk->tag.use_tag = player->nametag != NAMETAG_NONE;

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

    bk->root = css_56_card_create(port, &bk->tag);
    bk->stub.hsd_obj = css_scene_root;
    bk->stub.user_data = &bk->tag;

    // The card and tag procs only need a GObj to run from.
    HSD_GObj * card_gobj = GObj_Create(4, 5, 0x80);
    GObj_AddProc(card_gobj, card_think, 4);
    GObj_AddUserData(card_gobj, 4, noop, bk);
    HSD_GObj * tag_gobj = GObj_Create(4, 5, 0x80);
    GObj_AddProc(tag_gobj, tag_think, 4);
    GObj_AddUserData(tag_gobj, 4, noop, bk);

    // Draw the door in its restored state, name included.
    swap_in(bk);
    css_door_refresh(0);
    swap_out(bk);
}

CSSCursorData * css_port_cursor(int port) {
    return (port < 4) ? css_hands[port] : &css_56_blocks[port - 4]->cursor;
}

CSSDoor * css_port_door(int port) {
    return (port < 4) ? &css_doors[port] : &css_56_blocks[port - 4]->doors[0];
}

const CSSDoor * css_get_door_for_port_swap_aware(int port) {
    int swapped = css_56_swapped_port();
    if (swapped < 0 || (port >= 4 && port != swapped)) return css_port_door(port);
    if (port == swapped) return &css_doors[0];
    return &css_56_blocks[swapped - 4]->doors[port];
}

CSSTagData * css_port_tag(int port) {
    return (port < 4) ? css_tags[port].data : &css_56_blocks[port - 4]->tag;
}

CSSCharModel * css_port_puck(int port) {
    return (port < 4) ? css_pucks[port] : &css_56_blocks[port - 4]->puck;
}

const PadStatus * css_port_pad(int port) {
    return (port < 4) ? &HSD_PadCopyStatus[port] : &triples_converted_output[port - 4];
}

bool css_port_sees(int port, int door) {
    return (port < 4) ? (door < 4) : (door == port);
}

int css_port_swap_in(int port) {
    if (port < 4) return port;
    swap_in(css_56_blocks[port - 4]);
    return 0;
}

void css_port_swap_out(int port) {
    if (port >= 4) swap_out(css_56_blocks[port - 4]);
}

void css_port_refresh(int port, bool pick_rand_char) {
    int slot = css_port_swap_in(port);
    if (pick_rand_char) css_pick_random_character(slot, 1);
    css_door_refresh(slot);
    css_port_swap_out(port);
}

void css_56_create() {
    for (int port = 4; port < 6; ++port) create_port(port);
}
