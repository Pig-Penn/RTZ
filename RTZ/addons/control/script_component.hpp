#define COMPONENT control
#define COMPONENT_BEAUTIFIED Control
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_CONTROL
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_CONTROL
    #define DEBUG_SETTINGS DEBUG_SETTINGS_CONTROL
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// Toggle icon/tint pair for the "Disable/Enable Simulation" context action and
// its modifierFunction.
//
// Both are solid white silhouettes carried entirely by their alpha, because
// ZEN tints them with ctrlSetTextColor and that multiplies the texture. RGB is
// white even where alpha is 0 — transparent texels still bleed into the edge
// when the engine scales the sheet down to the ~18px the menu draws, and black
// ones showed up as a dark fringe.
//
// Sized against ICON_DELETE so the three RTZ glyphs carry the same weight in
// one submenu: 128px sheets, a 100px vertical extent, and an ink fraction in
// the 30-34% band. The play triangle sits 3px right of centre, since a
// triangle is optically centred nearer its centroid than its bounding box.
// Regenerate with tools/icons — see tools/icons/README.md.
#define ICON_HIDE "\x\rtz\addons\control\ui\pause_ca.paa"
#define ICON_SHOW "\x\rtz\addons\control\ui\play_ca.paa"
// Orange
#define COLOR_HIDE [1.00, 0.60, 0.20, 1]
// Green
#define COLOR_SHOW [0.40, 1.00, 0.40, 1]

// Third state for the same action: a group still under the editor-placed
// Dynamic Simulation system. Reuses ICON_SHOW (blue tint) rather than a new
// asset — clicking it turns Dynamic Simulation off, after which the toggle
// above reverts to its normal orange/green behaviour.
// Blue
#define COLOR_DYNSIM [0.20, 0.60, 1.00, 1]

#define ICON_OWNERSHIP "\x\zen\addons\context_actions\ui\add_ca.paa"
#define ICON_RESET "\a3\3DEN\Data\CfgWaypoints\cycle_ca.paa"
#define ICON_RELOAD "\a3\ui_f\data\IGUI\Cfg\Actions\reload_ca.paa"

// Toggle icon/tint pair for the "Forbid/Allow Dismount" context action and its
// modifierFunction — amber padlock while vanilla (will lock crew in), cyan
// unlock once locked (will release).
#define ICON_LOCKED "\a3\modules_f\data\iconlock_ca.paa"
#define ICON_UNLOCKED "\a3\modules_f\data\iconunlock_ca.paa"
// Amber
#define COLOR_LOCKED [1.00, 0.78, 0.22, 1]
// Cyan
#define COLOR_UNLOCKED [0.40, 0.80, 1.00, 1]

// Bound on FUNC(rcResetApply)'s wait for the remote-control ownership handover.
// `objNull remoteControl` returns the unit to its previous owner over the
// network, so the machine that will run the reset is NOT known at dispatch time
// — see the dispatch note in fnc_rcReset.sqf. Seconds; generous, because the
// only cost of overshooting is a `local` test per frame on the machines that
// never get the unit, and the only cost of undershooting is a reset that never
// lands.
#define RC_RESET_TIMEOUT 3

// Seconds a rebuild claim is remembered by FUNC(rcClaim) before it lapses. Only has to
// outlast the spread between the first candidate machine settling and the last one — a
// round trip, generously over-covered here — and it is what bounds GVAR(rcClaims) on a
// multi-hour operation.
#define RC_CLAIM_WINDOW 30

// ── Remote-control rebuild ───────────────────────────────────────────────────
// Seconds between the three steps of FUNC(rcRebuild): create, then apply state and
// delete the original, then place the replacement. Wargame uses 0.2 and 0.1 sleeps
// for the same two gaps; this is unscheduled code where sleep is illegal, so they
// are CBA_fnc_waitAndExecute steps instead.
#define RC_REBUILD_SETTLE 0.25

// Every AI feature the engine exposes, captured and re-applied by FUNC(rcRebuild).
// Read with checkAIFeature rather than assumed, because a unit can arrive here with
// features another RTZ order deliberately disabled, and a rebuild must not quietly
// switch them back on. Kept on one line: a line-continuation in a macro that is then
// used inside `apply` is exactly the trailing-backslash trap in Gotchas.md §6.
#define RC_AI_FEATURES ["AIMINGERROR","ANIM","AUTOCOMBAT","AUTOTARGET","CHECKVISIBLE","COVER","FSM","LIGHTS","MINEDETECTION","MOVE","NVG","PATH","RADIOPROTOCOL","SUPPRESSION","TARGET","TEAMSWITCH","WEAPONAIM"]
