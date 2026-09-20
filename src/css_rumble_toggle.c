#include "css_56_cursor.h"

#define RUMBLE_ID_MENU 0
#define RUMBLE_FRAMES_TOGGLE 14
#define SHAKE_START -3.0f
#define SHAKE_DAMPING 0.8f
#define SHAKE_STOP 0.015625f

static f32 shake[PORT_COUNT];

static void start_shake(CSSCursorData * cursor, f32 * velocity) {
    if (*velocity > 0) {
        cursor->x += *velocity;
    }
    *velocity = SHAKE_START;
    cursor->x7 = 1;
}

void css_rumble_toggle(CSSCursorData * cursor, u32 triggered) {
    int port = css_56_swapped_port();
    if (port < 0) port = cursor->x4;

    f32 * velocity = &shake[port];

    if ((triggered & PAD_BUTTON_UP)) {
        gmMainLib_SetRumbleEnabled(port, true);
        HSD_PadRumbleRemoveId(port, RUMBLE_ID_MENU);
        HSD_PadRumbleAdd(port, RUMBLE_ID_MENU, RUMBLE_FRAMES_TOGGLE, 0, mn_rumble_test_effect);
        start_shake(cursor, velocity);
    } else if ((triggered & PAD_BUTTON_DOWN)) {
        gmMainLib_SetRumbleEnabled(port, false);
        HSD_PadRumbleRemoveId(port, RUMBLE_ID_MENU);
        start_shake(cursor, velocity);
    }

    if (cursor->x7 != 0) {
        f32 step = *velocity;
        cursor->x += step;
        f32 next = -step;
        if (step >= 0) next *= SHAKE_DAMPING;
        *velocity = next;

        if (step <= 0 && next <= SHAKE_STOP) {
            *velocity = 0;
            cursor->x7 = 0;
        }
    }
}
