#ifndef MEX_H
#define MEX_H

#include "melee.h"

/** m-ex (github.com/akaneia/m-ex), which Akaneia and its forks build on.
    What Triples does differently under it lives in src/mex.c. */

/** m-ex hooks the CSS's archive load here.  Keep in step with test_mex in
    asm/common.s. */
#define MEX_CSS_LOAD_SITE ((const u32 *)0x80266984)
#define MEX_CSS_LOAD_VANILLA 0x806DB630 // lwz r3, -0x49D0(r13)

#define mex_is_loaded() (*MEX_CSS_LOAD_SITE != MEX_CSS_LOAD_VANILLA)

// mexSelectChr.dat: the CSS icons and portraits.
typedef struct MexSelectChr {
    void * icon_model;
    void * icon_anim_joint;
    void * icon_matanim;
    void * csp_matanim; // Frame is external id + costume * csp_stride.
    int csp_stride;
} MexSelectChr;

// Its globals, in src/mex.ld; only valid under m-ex.
extern MexSelectChr * mex_select_chr; // NULL without mexSelectChr.dat.
extern HSD_JObj * mex_icon_root; // Child icon + 1 is that icon's model.
extern u8 * mex_css_data; // Its copy of the CSS data vanilla keeps at 0x803F0A48.
#define MEX_CSS_ICONS 0xDC
extern int mex_css_icon_count;

// The CSS icons, their count (also the no-icon index), and an icon's model.
CSSIcon * css_icon_table();
int css_icon_count();
HSD_JObj * css_icon_joint(int icon);

/** Whether a drop off the icons picks random.  m-ex skips the vanilla
    RANDOM area test and rolls on any such drop, so RANDOM works wherever a
    mod draws it. */
bool css_miss_picks_random();

/** m-ex's portrait and series emblem anims, which it adds to the vanilla
    doors at CSS load, on a copy of a door's pieces.  Nothing without m-ex. */
void mex_add_door_anims(HSD_JObj * costume, HSD_JObj * emblem);


#endif
