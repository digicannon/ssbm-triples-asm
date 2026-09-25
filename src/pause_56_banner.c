// GmPause's player label is a 42x20 I4 texture per port, P1-P4, loaded
// once per match.  P5 and P6 are made from the loaded P1 image: two copies
// in a heap block with the digit's three tile columns overwritten from the
// assets.  The English file reads "P 1" (digit on the right), the Japanese
// one "1 P", so the assets come in both layouts.

#include "melee.h"

// assets/pause_digit_*.png, 24x24 I4: the digit's three tile columns for
// each language.
extern const u8 pause_digit_5_us[];
extern const u8 pause_digit_6_us[];
extern const u8 pause_digit_5_jp[];
extern const u8 pause_digit_6_jp[];

#define LABEL_JOINT 8
#define TILE 32
#define TILE_COLUMNS 6
#define DIGIT_COLUMNS 3
#define DIGIT_ROWS 3
#define IMAGE_SIZE (TILE_COLUMNS * DIGIT_ROWS * TILE)

typedef struct {
    u8 image[2][IMAGE_SIZE];
    HSD_ImageDesc desc[2];
} PauseImages;

static PauseImages * pause_56_images; // Heap block, per match.

static HSD_TObj * label_tobj(HSD_JObj * root) {
    HSD_JObj * label = NULL;
    JObj_GetChild(root, &label, LABEL_JOINT, -1);
    return label->dobj->mobj->tobj;
}

// At the end of the banner load, when the label shows P1.
void pause_56_banner_load(HSD_JObj * root) {
    PauseImages * images = HSD_MemAlloc(sizeof(*images));
    pause_56_images = images;
    const HSD_ImageDesc * p1 = label_tobj(root)->imagedesc;

    bool us = lbLang_IsSavedLanguageUS();
    const u8 * digits[2] = {us ? pause_digit_5_us : pause_digit_5_jp, us ? pause_digit_6_us : pause_digit_6_jp};
    for (int i = 0; i < 2; ++i) {
        u8 * image = images->image[i];
        memcpy(image, p1->image_ptr, IMAGE_SIZE);

        const u8 * digit = digits[i];
        u8 * row = image + (us ? DIGIT_COLUMNS * TILE : 0);
        for (int r = 0; r < DIGIT_ROWS; ++r) {
            memcpy(row, digit, DIGIT_COLUMNS * TILE);
            digit += DIGIT_COLUMNS * TILE;
            row += TILE_COLUMNS * TILE;
        }

        images->desc[i] = *p1;
        images->desc[i].image_ptr = image;
    }

    DCFlushRange(images, sizeof(*images));
}

// At the end of the banner proc, after its HSD_JObjAnimAll: for a P5/P6
// pauser point the label at our image (the anim asked for frame 5 or 6 and
// clamped to P4).  A later pause by P1-P4 animates the stock image back in.
void pause_56_banner_label() {
    int port = pause_data.slot;
    if (port < 4 || !pause_56_images) return;
    label_tobj(pause_data.background)->imagedesc = &pause_56_images->desc[port - 4];
}

HOOK(0x801A129C,
    "mr r3, r28\n"
    "bl pause_56_banner_load\n"
    "li r0, 99"); // Original code.

HOOK(0x801A10E8,
    "bl pause_56_banner_label\n"
    "lmw r26, 0x18(r1)"); // Original code.
