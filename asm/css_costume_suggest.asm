# ====================
#  Insert at 8025DCD4
# ====================

.include "common.s"

    mr r3, r31
    branchl r12, css_costume_suggest
    lbz r0, -0x49AA(r13) # Original code.
