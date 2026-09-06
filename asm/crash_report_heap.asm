# ====================
#  Insert at 803882A0
# ====================

.include "common.s"

.set lbHeap_Report, 0x80015DF8
    branchl r12, lbHeap_Report

return:
    lwz r0, -0x3F8C(r13) # Original code.
