/* Stock symbols the code uses, by GALE01 address.  Names follow the melee
 * decomp where it has one; numbered ones get a descriptive name instead. */

memset = 0x80003100;
memcpy = 0x800031F4;
memzero = 0x8000C160;
OSReport = 0x803456A8;

HSD_MemAlloc = 0x8037F1E4;
HSD_Free = 0x8037F1B0;
GObj_Create = 0x803901F0;
GObj_AddUserData = 0x80390B68; /* GObj_InitUserData */
GObj_AddProc = 0x8038FD54; /* HSD_GObj_SetupProc */
GObj_AddToObj = 0x80390A70; /* HSD_GObjObject_80390A70 */
GObj_SetupGXLink = 0x8039069C;
HSD_GObj_JObjCallback = 0x80391070;
HSD_JObjLoadJoint = 0x80370E44;
HSD_JObjAddAnimAll = 0x8036FB5C;
HSD_JObjReqAnim = 0x8036F934;
HSD_JObjReqAnimAll = 0x8036F8BC;
HSD_JObjAnimAll = 0x80370928;
HSD_JObjSetFlagsAll = 0x80371D9C;
HSD_JObjClearFlagsAll = 0x80371F9C;
HSD_JObjAddChild = 0x803717A8;
HSD_JObjResolveRefsAll = 0x80370FF4;
HSD_JObjSetMtxDirty = 0x800C6AFC;
HSD_IDInsertToTable = 0x8037CDEC;
HSD_ForeachAnim = 0x80364C08;
HSD_AObjStopAnim = 0x8036414C;
DCFlushRange = 0x8034480C;
DCInvalidateRange = 0x803447DC;
JObj_GetChild = 0x80011E24; /* lb_80011E24 */
JObj_WorldPos = 0x8000B1CC; /* lb_8000B1CC */
lbLang_IsSavedLanguageUS = 0x8000AE90;
Text_Create = 0x803A6754; /* HSD_SisLib_803A6754 */
Text_InitSubtext = 0x803A6B98; /* HSD_SisLib_803A6B98 */
gmMainLib_GetGameRules = 0x8015CC34;
Player_GetPlayerSlotType = 0x8003241C;
Player_GetEntity = 0x80034110;
Player_GetEntityAtIndex = 0x8003418C;

mnCharSel_CursorThink = 0x802602A0;
css_puck_think = 0x80262648; /* fn_80262648 */
css_scene_think = 0x8025F0E0; /* fn_8025F0E0 */
css_door_refresh = 0x8025DB34; /* mnCharSel_8025DB34 */

css_anim_table = 0x804D6CD8; /* mnCharSel_804D6CD8 */
css_scene_root = 0x804D6CC0; /* mnCharSel_804D6CC0 */
css_hands = 0x804A0BC0; /* mnCharSel_804A0BC0 */
css_pucks = 0x804A0BD0; /* mnCharSel_804A0BD0 */
css_doors = 0x803F0DFC; /* mnCharSel_803F0DFC */
css_tags = 0x803F0E8C; /* mnCharSel_803F0E8C */
css_icons = 0x803F0B24; /* icons */
css_exit_bits = 0x804D50C8; /* mnCharSel_804D50C8 */
css_is_teams = 0x804807C8;
css_door_count = 0x804D6CF5; /* mnCharSel_804D6CF5 */
css_menu_id = 0x80479D30; /* state_machine; 2 on the main CSS */
scene_major = 0x80479D30; /* state_machine byte 0 */
scene_minor = 0x80479D33; /* state_machine byte 3 */
sss_stage_picked = 0x804D6CAF; /* mnStageSel_804D6CAF */
css_pending_scene_change = 0x804D6CF6; /* mnCharSel_804D6CF6; 5 inside the rules or nametag menu */
menu_cur_menu = 0x804A04F0; /* mn_804A04F0.cur_menu */
match_init_flags = 0x804807C0;
players = 0x80480820;
HSD_PadMasterStatus = 0x804C1FAC;
HSD_PadCopyStatus = 0x804C20BC;
text_canvases = 0x804D797C; /* HSD_SisLib_804D797C */

pause_data = 0x80479B10; /* lbl_80479B10 */
