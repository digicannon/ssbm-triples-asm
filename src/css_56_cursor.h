#ifndef CSS_56_CURSOR_H
#define CSS_56_CURSOR_H

#include "melee.h"

#define PORT_COUNT 6

// The port whose block is swapped into slot 0, or -1.
int css_56_swapped_port();

// Whether a P5/P6 hand is holding its puck or picking a tag.
bool css_56_cursor_holding();

CSSCursorData * css_port_cursor(int port);
CSSDoor * css_port_door(int port);
// css_port_door that also works inside a swapped region, where slot 0 is
// the swapped port's door and the real doors sit in its block.
const CSSDoor * css_get_door_for_port_swap_aware(int port);
CSSTagData * css_port_tag(int port);
CSSCharModel * css_port_puck(int port);

const PadStatus * css_port_pad(int port);

// Whether Melee's own hand think covers this port acting on this door.
bool css_port_sees(int port, int door);

// The slot the port is in until css_port_swap_out.
int css_port_swap_in(int port);
void css_port_swap_out(int port);

void css_port_refresh(int port, bool pick_rand_char);

#endif
