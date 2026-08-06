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

// Trashcan drawn to match the rest of the context menu — a solid white
// silhouette with rounded corners and a margin, like the vanilla simpleTasks
// glyphs. The 3DEN entity-list icon it replaces was hard-cornered and bled to
// the edge of its canvas, so it read heavier than every action beside it.
// No slot cut-outs: the menu draws icons at roughly 18px, where slots average
// out to grey and leave the can looking washed out next to solid neighbours
// like ICON_LOCKED. The lid gap and the taper carry the shape at that size.
#define ICON_DELETE "\x\rtz\addons\delete\ui\trash_ca.paa"

// Seconds the group-cleanup pass waits before counting a group's members.
// The deletions are issued on the server and reach a remote owner a network
// tick later, so an immediate count would still see the dead members and skip
// a group that is in fact empty. Comfortably past one tick on any playable
// connection, and the check is idempotent — a group that refilled in the
// meantime is simply left alone.
#define GROUP_CLEANUP_DELAY 1
