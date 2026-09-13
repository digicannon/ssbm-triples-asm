#ifndef CSS_56_CURSOR_H
#define CSS_56_CURSOR_H

#include "melee.h"

// The port whose block is swapped into slot 0, or -1.
int css_56_swapped_port();

// Whether a P5/P6 hand is holding its puck or picking a tag.
bool css_56_cursor_holding();

CSSCursorData * css_port_cursor(int port);
CSSDoor * css_port_door(int port);
CSSTagData * css_port_tag(int port);
CSSCharModel * css_port_puck(int port);

void css_port_refresh(int port, bool pick_rand_char);

#endif
