# Inserted at 0x8036fb70
.include "common.s"
.include "triples_globals.s"

# Preserve the JOBJ arg in a non-volatile register
load r26, css_backup_dbg # r25 get clobbered 1 instruction later
stw r3, 0(r26)

RETURN:
    addi r26, r4, 0x0
