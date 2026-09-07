#ifndef CSS_56_CURSOR_H
#define CSS_56_CURSOR_H

#include <stdbool.h>

// The port whose block is swapped into slot 0, or -1.
int css_56_swapped_port();

// Whether a P5/P6 hand is holding its puck or picking a tag.
bool css_56_cursor_holding();

#endif
