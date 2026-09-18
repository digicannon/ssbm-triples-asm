// Fragments of the stock structs the C code touches.  Fields it does not
// use are padding; offsets are pinned by the asserts.  Addresses come from
// melee.ld.

#ifndef MELEE_H
#define MELEE_H

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

typedef uint8_t u8;
typedef uint16_t u16;
typedef uint32_t u32;
typedef uint64_t u64;
typedef float f32;

#define ASSERT_OFFSET(type, field, offset) \
    _Static_assert(offsetof(type, field) == offset, #type "." #field)
#define ASSERT_SIZE(type, size) _Static_assert(sizeof(type) == size, #type)

typedef struct HSD_GObj {
    u8 pad0[0x28];
    void * hsd_obj;
    void * user_data;
} HSD_GObj;
ASSERT_SIZE(HSD_GObj, 0x30);

#define GX_TF_I4 0
#define GX_TF_IA4 2

typedef struct HSD_ImageDesc {
    void * image_ptr;
    u16 width;
    u16 height;
    u32 format;
    u32 mipmap;
    f32 min_lod;
    f32 max_lod;
} HSD_ImageDesc;
ASSERT_SIZE(HSD_ImageDesc, 0x18);

typedef struct GXColor {
    u8 r, g, b, a;
} GXColor;

typedef struct HSD_TObjTev {
    u8 pad0[0x10];
    GXColor konst;
    GXColor tev0;
    GXColor tev1;
    u32 active;
} HSD_TObjTev;

typedef struct HSD_TObj {
    u8 pad0[0x58];
    HSD_ImageDesc * imagedesc;
    u8 pad1[0xC];
    HSD_ImageDesc ** imagetbl;
    u8 pad2[0x3C];
    HSD_TObjTev * tev;
} HSD_TObj;
ASSERT_OFFSET(HSD_TObj, imagetbl, 0x68);
ASSERT_OFFSET(HSD_TObj, tev, 0xA8);

typedef struct HSD_Material {
    GXColor ambient;
    GXColor diffuse;
    GXColor specular;
    f32 alpha;
    f32 shininess;
} HSD_Material;

typedef struct HSD_MObj {
    u8 pad0[8];
    HSD_TObj * tobj;
    HSD_Material * mat;
} HSD_MObj;

typedef struct HSD_PObj {
    u8 pad0[0xE];
    u16 display_count;
} HSD_PObj;

typedef struct HSD_DObj {
    u8 pad0[4];
    struct HSD_DObj * next;
    HSD_MObj * mobj;
    HSD_PObj * pobj;
} HSD_DObj;

typedef struct HSD_JObj {
    u8 pad0[0x10];
    struct HSD_JObj * child;
    u32 flags;
    HSD_DObj * dobj;
    u8 pad1[0x10];
    f32 scale[3];
    f32 translate[3];
} HSD_JObj;
ASSERT_OFFSET(HSD_JObj, scale, 0x2C);
ASSERT_OFFSET(HSD_JObj, translate, 0x38);

typedef struct HSD_JObjDesc {
    u8 pad0[8];
    struct HSD_JObjDesc * child;
    struct HSD_JObjDesc * next;
    u8 pad1[0x1C];
    f32 position[3];
    u8 pad2[8];
} HSD_JObjDesc;
ASSERT_SIZE(HSD_JObjDesc, 0x40);
ASSERT_OFFSET(HSD_JObjDesc, position, 0x2C);

// The CSS's MnSlChr file entries: joint desc, anim, mat anim, shape anim.
typedef struct CSSAnim {
    void * desc[4];
} CSSAnim;

// CSSCursorData.state: 1 while holding the puck, 3 for a hand the Start
// check leaves out; 2 is a free hand.
#define HAND_HOLDING 1
#define HAND_FREE 2

typedef struct CSSCursorData {
    HSD_GObj * gobj;
    u8 x4;
    u8 state;
    u8 x6;
    u8 x7;
    u8 pad0[4];
    f32 x;
    f32 y;
} CSSCursorData;
ASSERT_SIZE(CSSCursorData, 0x14);

typedef struct CSSCharModel {
    HSD_GObj * gobj;
    u8 x4;
    u8 x5;
    u8 color;
    u8 refresh; // Refreshes the color anim when it runs past 0x27.
    f32 x;
    f32 y;
    f32 x10;
    f32 x14;
} CSSCharModel;
ASSERT_SIZE(CSSCharModel, 0x18);

typedef struct CSSDoor {
    // emblem, costume, team, door, bg, indicator, slider name, cpu slider,
    // cpu slider 2.
    u8 joints[9];
    u8 selected_since_load;
    u8 team;
    u8 p_kind;
    u8 p_kind_prev;
    u8 costume;
    u8 sel_icon;
    u8 sel_icon_prev;
    u8 dooranim_timer;
    u8 slideranim_timer;
    u8 is_hold_cpu_slider;
    u8 is_hold_handicap_slider;
    // HMN button left, right; team button left, right.
    f32 bounds[4];
} CSSDoor;
ASSERT_SIZE(CSSDoor, 0x24);
ASSERT_OFFSET(CSSDoor, bounds, 0x14);

#define PKIND_HUMAN 0
#define PKIND_CPU 1
#define PKIND_CLOSED 3

#define SFX_MOVE 2

#define ICON_COUNT 0x19
#define ICON_NONE 0x19

typedef struct Text {
    f32 pos_x;
    f32 pos_y;
    f32 pos_z;
    f32 box_size_x;
    f32 box_size_y;
    u8 pad0[0x10];
    f32 font_size_x;
    f32 font_size_y;
    u8 pad1[0x1C];
    u8 default_fitting;
    u8 default_kerning;
    u8 default_alignment;
    u8 x4b;
    u8 x4c;
    u8 hidden;
    u8 x4e;
} Text;
ASSERT_OFFSET(Text, font_size_x, 0x24);
ASSERT_OFFSET(Text, hidden, 0x4D);

typedef struct CSSTagData {
    Text * text;
    Text * name_ls; // The tag list.
    f32 x8; // List scroll, in text units.
    f32 scroll_amt;
    f32 scroll_force;
    int timer;
    u8 next_tag; // The list's NAME ENTRY row.
    u8 port;
    u8 state; // 0 closed, 1-2 opening, 3 open, 4-5 closing.
    u8 use_tag;
} CSSTagData;
ASSERT_SIZE(CSSTagData, 0x1C);

typedef struct CSSTag {
    CSSTagData * data;
    // nametag window, list, name, x7, KO star text.
    u8 joints[5];
    u8 pad0[3];
} CSSTag;
ASSERT_SIZE(CSSTag, 0xC);

typedef struct CSSIcon {
    u8 x0;
    u8 char_kind;
    u8 state;
    u8 anim_timer;
    u8 joint_id_vs;
    u8 joint_id_1p;
    u8 pad0[2];
    int sfx;
    f32 bound_l;
    f32 bound_r;
    f32 bound_u;
    f32 bound_d;
} CSSIcon;
ASSERT_SIZE(CSSIcon, 0x1C);

typedef struct Player {
    u8 ckind;
    u8 slot_type;
    u8 stocks;
    u8 color;
    u8 pad0[4];
    u8 handicap;
    u8 team;
    u8 nametag; // 0x78 for none.
    u8 pad1[4];
    u8 cpu_level;
    u8 pad2[0x14];
} Player;
ASSERT_SIZE(Player, 0x24);
ASSERT_OFFSET(Player, handicap, 8);
ASSERT_OFFSET(Player, cpu_level, 0xF);

typedef struct TextCanvas {
    struct TextCanvas * next;
    u8 pad0[6];
    u16 font;
} TextCanvas;

typedef int8_t s8;

#define PAD_BUTTON_LEFT 0x0001
#define PAD_BUTTON_RIGHT 0x0002
#define PAD_BUTTON_DOWN 0x0004
#define PAD_BUTTON_UP 0x0008
#define PAD_TRIGGER_Z 0x0010
#define PAD_TRIGGER_R 0x0020
#define PAD_TRIGGER_L 0x0040
#define PAD_BUTTON_A 0x0100
#define PAD_BUTTON_B 0x0200
#define PAD_BUTTON_X 0x0400
#define PAD_BUTTON_Y 0x0800
#define PAD_BUTTON_START 0x1000
#define PAD_STICK_UP 0x10000
#define PAD_STICK_DOWN 0x20000
#define PAD_STICK_LEFT 0x40000
#define PAD_STICK_RIGHT 0x80000
// gm_EvaluateAllControllerInputs' derived bits.
#define PAD_CONFIRM (1ULL << 32)
#define PAD_CANCEL (1ULL << 33)
#define PAD_LR_START (1ULL << 34)
#define PAD_LRA_START (1ULL << 35)
#define PAD_ANY_UP (1ULL << 36)
#define PAD_ANY_DOWN (1ULL << 37)
#define PAD_ANY_LEFT (1ULL << 38)
#define PAD_ANY_RIGHT (1ULL << 39)

// The pad library's raw status, as PADRead fills it.
typedef struct PADStatus {
    u16 button;
    s8 stick_x;
    s8 stick_y;
    s8 substick_x;
    s8 substick_y;
    u8 trigger_left;
    u8 trigger_right;
    u8 analog_a;
    u8 analog_b;
    s8 err;
    u8 pad0;
} PADStatus;
ASSERT_SIZE(PADStatus, 0xC);

// HSD's processed status.
typedef struct PadStatus {
    u32 button;
    u32 last_button;
    u32 trigger;
    u32 repeat;
    u32 release;
    int repeat_count;
    s8 stick_x;
    s8 stick_y;
    s8 substick_x;
    s8 substick_y;
    u8 analog_l;
    u8 analog_r;
    u8 analog_a;
    u8 analog_b;
    f32 nml_stick_x;
    f32 nml_stick_y;
    f32 nml_substick_x;
    f32 nml_substick_y;
    f32 nml_analog_l;
    f32 nml_analog_r;
    f32 nml_analog_a;
    f32 nml_analog_b;
    u8 cross_dir;
    u8 err; // 0 while plugged in.
    u8 pad0[2];
} PadStatus;
ASSERT_SIZE(PadStatus, 0x44);
ASSERT_OFFSET(PadStatus, stick_x, 0x18);
ASSERT_OFFSET(PadStatus, nml_substick_x, 0x28);
ASSERT_OFFSET(PadStatus, err, 0x41);

// One port's menu inputs.  Ports 0-3, then ANY_PORT as their OR.
typedef struct ControllerMapEntry {
    u64 button;
    u64 trigger;
    u64 repeat;
    u64 release;
    u64 repeat2;
    int repeat_timer;
    int held; // Frames without a change, saturating at fastest_after.
} ControllerMapEntry;
ASSERT_SIZE(ControllerMapEntry, 0x30);

typedef struct ControllerMap {
    ControllerMapEntry ports[5];
    void (* repeat_proc)(int port);
    u16 delay;
    u8 interval;
    u16 fast_after;
    u8 fast_interval;
    u16 fastest_after;
    u8 fastest_interval;
} ControllerMap;
ASSERT_SIZE(ControllerMap, 0x100);

// One port of the GameCube adapter's USB report.
typedef struct AdapterPort {
    u8 status;
    u8 buttons;
    u8 buttons2;
    u8 stick_x;
    u8 stick_y;
    u8 cstick_x;
    u8 cstick_y;
    u8 trigger_left;
    u8 trigger_right;
} AdapterPort;
ASSERT_SIZE(AdapterPort, 9);

typedef struct AdapterReport {
    u8 id;
    AdapterPort port[4];
} AdapterReport;

// Nintendont's HID device, as it publishes it to the game.
typedef struct HidControl {
    u32 vid;
    u32 pid;
} HidControl;

// Our adapter ports as raw pads for the pad loop, and what it takes to
// make them.
typedef struct AdapterPads {
    PADStatus pad[2];
    AdapterPort origin[2];
    bool plugged[2];
} AdapterPads;
ASSERT_OFFSET(AdapterPads, pad, 0);

// HSD's per-port rumble state.  Status 2 is motor on; 0 and 1 are stops.
typedef struct HSD_RumbleData {
    u8 last_status;
    u8 status;
    u8 direct_status;
    u16 nb_list;
    void * listdatap;
} HSD_RumbleData;
ASSERT_SIZE(HSD_RumbleData, 0xC);

typedef struct GameRules {
    u8 pad0[5];
    u8 handicap;
} GameRules;

typedef struct PauseData {
    HSD_JObj * background;
    HSD_JObj * analog_stick;
    HSD_JObj * lras;
    HSD_JObj * z;
    HSD_JObj * analog_stick_outline;
    int slot; // The pauser.
} PauseData;
ASSERT_OFFSET(PauseData, slot, 0x14);

typedef struct PauseImages PauseImages;

void * memset(void * dst, int value, size_t size);
void * memcpy(void * dst, const void * src, size_t size);

void * HSD_MemAlloc(u32 size);
void HSD_Free(void * block);
HSD_GObj * GObj_Create(int type, int subclass, int priority);
void GObj_AddUserData(HSD_GObj * gobj, int kind, void (*destructor)(void *), void * data);
void GObj_AddProc(HSD_GObj * gobj, void (*proc)(HSD_GObj *), int priority);
void GObj_AddToObj(HSD_GObj * gobj, int kind, void * obj);
void GObj_SetupGXLink(HSD_GObj * gobj, void (*callback)(HSD_GObj *, int), int link, int priority);
void HSD_GObj_JObjCallback(HSD_GObj * gobj, int pass);
HSD_JObj * HSD_JObjLoadJoint(HSD_JObjDesc * desc);
void HSD_JObjAddAnimAll(HSD_JObj * jobj, void * anim, void * matanim, void * shapeanim);
void HSD_JObjReqAnim(HSD_JObj * jobj, f32 frame);
void HSD_JObjReqAnimAll(HSD_JObj * jobj, f32 frame);
void HSD_JObjAnimAll(HSD_JObj * jobj);
void HSD_JObjSetFlagsAll(HSD_JObj * jobj, u32 flags);
void HSD_JObjClearFlagsAll(HSD_JObj * jobj, u32 flags);
void HSD_JObjAddChild(HSD_JObj * parent, HSD_JObj * child);
void HSD_JObjResolveRefsAll(HSD_JObj * jobj, HSD_JObjDesc * desc);
void HSD_JObjSetMtxDirty(HSD_JObj * jobj);
void HSD_IDInsertToTable(void * table, void * id, void * data);
void HSD_ForeachAnim(void * obj, u32 type, u32 mask, void (*fn)(), u32 arg_type, ...);
void HSD_AObjStopAnim();
void DCFlushRange(void * start, u32 size);
void DCInvalidateRange(void * start, u32 size);
void JObj_GetChild(HSD_JObj * root, HSD_JObj ** out, int index, int stop);
void JObj_WorldPos(HSD_JObj * jobj, void * unused, f32 out[3]);
bool lbLang_IsSavedLanguageUS();
u8 Player_GetPlayerSlotType(int slot);
bool gm_RumbleEnabledForPlayer(int port, int nametag);
// lb_80014574.  Plays effect from LbRb.dat; 0 frames loops until removed by id.
void rumble_start(u8 port, int id, int effect, int frames);
Text * Text_Create(int font, int canvas);
void Text_InitSubtext(Text * text, f32 x, f32 y, const char * string);
void Text_SetSubtext(Text * text, int subtext, const char * string);
void Text_SetSubtextColor(Text * text, int subtext, const GXColor * color);
char * GetNameText(int tag);
GameRules * gmMainLib_GetGameRules();

void mnCharSel_CursorThink(HSD_GObj * gobj);
void css_tag_think(HSD_GObj * gobj);
void css_puck_think(HSD_GObj * gobj);
void css_scene_think(HSD_GObj * gobj);
void css_door_refresh(int slot);
void css_pick_random_character(int slot, int arg1);
// Sends the slot's puck back to its door's character; 1 if it has none.
int css_return_puck(int slot);
void css_door_portrait(int slot, int frame, bool hidden);
void css_costume_change(int slot, u32 input);
bool css_duplicate_costume(int slot);
int costume_count(u32 char_kind);
void announce_character(u32 char_kind);
void menu_sfx(int sound);
int sfx_play(int sfx, int volume, int pan);
int sfx_play_id(int sfx, int volume, int pan, int id);
// Puts gobj on other's GX layer and priority.
void GObj_GXLinkLike(HSD_GObj * gobj, HSD_GObj * other);
void HSD_AObjReqAnim();
int HSD_Randi(int max);
#define AOBJ_ARG_AF 1
#define AOBJ_ARG_AOV 6

#define JOBJ_HIDDEN 0x10
#define TOBJ_MASK 0x400
#define ALL_TYPE_MASK 0xFFFF
#define HSD_TYPE_JOBJ 6

extern CSSAnim * css_anim_table;
extern HSD_JObj * css_scene_root;
extern CSSCursorData * css_hands[4];
extern CSSCharModel * css_pucks[4];
extern CSSDoor css_doors[4];
extern CSSTag css_tags[4];
extern CSSIcon css_icons[ICON_COUNT];
extern u8 css_exit_bits[4];
extern u8 css_is_teams;
extern u8 css_door_count;
extern u8 css_menu_id;
extern u8 match_init_flags;
extern Player players[6];
extern PadStatus HSD_PadMasterStatus[4];
extern PadStatus HSD_PadCopyStatus[4];
extern ControllerMap controller_map;
extern u32 sss_input_trigger;
extern s8 sss_input_stick_x;
extern s8 sss_input_stick_y;
extern s8 sss_input_port; // -1 reads every pad.
extern u8 scene_major;
extern u8 scene_minor;
extern u8 sss_stage_picked;
extern u8 css_pending_scene_change;
extern s8 css_name_entry_slot;
extern u8 css_tag_mark;
extern u32 css_name_entry_port;
extern u8 shield_colors_56[7][4];
extern u8 blastzone_colors_56[7][4];
extern u8 * ft_shield_colors;
extern u8 * ft_blastzone_colors;
#define NAMETAG_NONE 0x78
extern u8 menu_cur_menu;
extern TextCanvas * text_canvases;
extern PauseData pause_data;
extern PadStatus triples_converted_output[2];
extern ControllerMapEntry menu_inputs_56_ports[2];
extern u8 css_hands_held;
extern AdapterPads adapter_pads_data;
extern u32 hid_status;
extern HidControl hid_ctrl;
extern AdapterReport hid_report;
extern u32 hid_motor_56;
extern HSD_RumbleData rumble_data[6];
extern PauseImages * pause_56_images; // Heap block, per match.

#define CSS_DOOR_PITCH 10.3f // x spacing of the six squeezed doors.

#endif
