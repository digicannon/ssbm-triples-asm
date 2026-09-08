#include "melee.h"

extern const u8 indicator_5_us[];
extern const u8 indicator_6_us[];
extern const u8 indicator_5_jp[];
extern const u8 indicator_6_jp[];

#define IMAGE_COUNT 7 // CP, P1-P4, blank, heart.
#define IMAGE_P1 1

#define FRAME_RED 0
#define FRAME_BLUE 1
#define FRAME_YELLOW 2
#define FRAME_GREEN 3

#define TEAM_RED 0
#define TEAM_BLUE 1
#define TEAM_GREEN 2

static const GXColor colors[2] = {
    {0xFF, 0x98, 0x26, 0xFF}, {0x98, 0x4C, 0xE5, 0xFF}
};

static const HSD_ImageDesc labels[2][2] = {
    {{(u8 *)indicator_5_jp, 32, 44, GX_TF_IA4}, {(u8 *)indicator_6_jp, 32, 44, GX_TF_IA4}},
    {{(u8 *)indicator_5_us, 32, 44, GX_TF_IA4}, {(u8 *)indicator_6_us, 32, 44, GX_TF_IA4}},
};

f32 indicator_56_frame(int team, bool teams) {
    if (teams) {
        if (team == TEAM_GREEN) return FRAME_GREEN;
        return team;
    }

    return FRAME_RED;
}

void indicator_56_recolor(HSD_JObj * root, int slot) {
    if (css_is_teams || Player_GetPlayerSlotType(slot) != PKIND_HUMAN) return;
    for (HSD_DObj * dobj = root->child->dobj; dobj; dobj = dobj->next) dobj->mobj->mat->diffuse = colors[slot - 4];
}

void indicator_56_label(HSD_JObj * root, int slot) {
    if (Player_GetPlayerSlotType(slot) != PKIND_HUMAN) return;

    HSD_ImageDesc * label = (HSD_ImageDesc *)&labels[lbLang_IsSavedLanguageUS()][slot - 4];
    HSD_ImageDesc ** images = HSD_MemAlloc(IMAGE_COUNT * sizeof(*images));

    HSD_TObj * tobj = root->child->dobj->mobj->tobj;
    memcpy(images, tobj->imagetbl, IMAGE_COUNT * sizeof(*images));
    images[IMAGE_P1] = label;

    tobj->imagetbl = images;
    tobj->imagedesc = label;
    indicator_56_recolor(root, slot);
}
