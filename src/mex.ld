/** m-ex's globals (github.com/akaneia/m-ex).
    Should only be used once mex presence is detected. */

mex_css_data = 0x804DF9E0; /* r2 + 0x0 */
mex_audio = 0x804DFA40; /* r2 + 0x60; +0x14 is the SSM list sorted by size. */
mex_ext_count = 0x804DFB2C; /* r2 + 0x14C; also the no-character id. */
mex_css_icon_count = 0x804DFB30; /* r2 + 0x150 */
mex_sss_icon_count = 0x804DFB34; /* r2 + 0x154; RANDOM is the last. */
mex_heap_data = 0x804DFB64; /* r2 + 0x184; lbHeap_80431FA0 with a 7th heap. */
mex_select_chr = 0x804D6F74; /* r13 - 0x472C */
mex_icon_root = 0x804D6F78; /* r13 - 0x4728 */
