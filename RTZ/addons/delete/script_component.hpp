#define COMPONENT delete
#define COMPONENT_BEAUTIFIED Delete
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_DELETE
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_DELETE
    #define DEBUG_SETTINGS DEBUG_SETTINGS_DELETE
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

#define ICON_DELETE "\a3\3DEN\Data\Displays\Display3DEN\PanelLeft\entityList_delete_ca.paa"

// Seconds the group-cleanup pass waits before counting a group's members.
// The deletions are issued on the server and reach a remote owner a network
// tick later, so an immediate count would still see the dead members and skip
// a group that is in fact empty. Comfortably past one tick on any playable
// connection, and the check is idempotent — a group that refilled in the
// meantime is simply left alone.
#define GROUP_CLEANUP_DELAY 1
