#include "melee.h"

enum {
    VID_NINTENDO = 0x57E,
    PID_GC_ADAPTER = 0x337,
    PORT_WIRED = 0x10,
    PORT_WAVEBIRD = 0x22,
    PAD_ERR_NONE = 0,
    PAD_ERR_NO_CONTROLLER = -1,
    RESET_BUTTONS = PAD_BUTTON_X | PAD_BUTTON_Y | PAD_BUTTON_START,
};

static bool plugged(const AdapterPort * port) {
    return (port->status & PORT_WIRED) == PORT_WIRED || (port->status & PORT_WAVEBIRD) == PORT_WAVEBIRD;
}

static u16 buttons(const AdapterPort * port) {
    // Byte 1: A B X Y in the low nibble, D-pad in the high; byte 2: Start Z R L.
    return (port->buttons & 0x0F) << 8 | port->buttons >> 4 | (port->buttons2 & 1) << 12 | (port->buttons2 & 0xE) << 3;
}

static s8 stick(u8 raw, u8 origin) {
    int v = (int)raw - origin;
    return v < -128 ? -128 : v > 127 ? 127 : v;
}

static u8 trigger(u8 raw, u8 origin) {
    return raw > origin ? raw - origin : 0;
}

void read_adapter_pads() {
    DCInvalidateRange(&hid_status, sizeof hid_status);
    DCInvalidateRange(&hid_ctrl, sizeof hid_ctrl);
    DCInvalidateRange(&hid_report, sizeof hid_report);

    bool adapter = hid_status != 0 && hid_ctrl.vid == VID_NINTENDO && hid_ctrl.pid == PID_GC_ADAPTER;

    for (int i = 0; i < 2; ++i) {
        PADStatus * pad = &adapter_pads_data.pad[i];
        const AdapterPort * port = &hid_report.port[i];

        if (!adapter || !plugged(port)) {
            pad->err = PAD_ERR_NO_CONTROLLER;
            adapter_pads_data.plugged[i] = false;
            continue;
        }

        u16 button = buttons(port);
        AdapterPort * origin = &adapter_pads_data.origin[i];
        if (!adapter_pads_data.plugged[i] || (button & RESET_BUTTONS) == RESET_BUTTONS) {
            *origin = *port;
            adapter_pads_data.plugged[i] = true;
        }

        pad->button = button;
        pad->stick_x = stick(port->stick_x, origin->stick_x);
        pad->stick_y = stick(port->stick_y, origin->stick_y);
        pad->substick_x = stick(port->cstick_x, origin->cstick_x);
        pad->substick_y = stick(port->cstick_y, origin->cstick_y);
        pad->trigger_left = trigger(port->trigger_left, origin->trigger_left);
        pad->trigger_right = trigger(port->trigger_right, origin->trigger_right);
        pad->analog_a = pad->analog_b = 0;
        pad->err = PAD_ERR_NONE;
    }

    DCFlushRange(&adapter_pads_data, sizeof adapter_pads_data);
}
