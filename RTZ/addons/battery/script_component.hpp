#define COMPONENT battery
#define COMPONENT_BEAUTIFIED Battery
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_BATTERY
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_BATTERY
    #define DEBUG_SETTINGS DEBUG_SETTINGS_BATTERY
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// This component owns both halves of the artillery domain: counter-battery
// DETECTION (the map overlay, everything below the Detection heading) and the
// outgoing FIRE MISSION context action. They share nothing but the subject and
// are gated by separate settings — detection is Global and off by default because
// it changes PvP balance, the action is Local and on by default because it is one
// curator's menu.
//
// rtz_core's script_macros_core.hpp is deliberately NOT included. This component
// draws on the Zeus MAP only — one Draw handler on the curator display's map
// control, the pattern EFUNC(mine,drawMap) and EFUNC(spotting,initCuratorDisplay)
// already use. The "never add your own Draw3D handler" rule in CLAUDE.md is about
// the 3D view; there is no RENDER_WORLD renderer here, no stream and no setDemand,
// so there is no rtz_core contract to parse and no rtz_core edge to declare. The
// fire mission picker adds no renderer either — it runs on ZEN's own
// zen_common_fnc_selectPosition, which brings its own draw handlers.

// ── Detection ────────────────────────────────────────────────────────────────
// Side relation below which a curator counts as hostile to the firing side. The
// mod's existing convention (EFUNC(attack,findTarget), EFUNC(captive,captureTick),
// EFUNC(spotting,spotCheck) all use 0.5).
#define HOSTILE_THRESHOLD 0.5

// Time-of-flight estimate (FUNC(detectShot)). Taken ONCE from the shell's initial
// vertical velocity as a symmetric ballistic arc — t = 2*vz/g — which ignores the
// gun/target altitude difference and is simply wrong for a rocket that keeps
// burning after launch. Both are why the result is clamped and why the display
// lingers past it (SPLASH_HOLD) rather than cutting at the estimate.
//
// The alternative was watching the shell object until isNull, which is a per-frame
// condition per round of every salvo on a mission that runs for hours — exactly the
// cost CLAUDE.md rules out. An estimate that is a few seconds off costs nothing
// here: it only decides when a warning ring stops being drawn.
#define GRAVITY 9.81
#define TOF_MIN 5
#define TOF_MAX 180
// Used when the shell object is already null, or reports [0,0,0] — the frames
// before a projectile's velocity resolves. Roughly a medium mortar's flight time.
#define TOF_FALLBACK 40

// ── Server send coalescing (FUNC(dispatchContact)) ───────────────────────────
// Minimum seconds between two sends for ONE track. A rocket battery empties a
// 12-round salvo in about two seconds; without this that is 12 packets per hostile
// curator, and the fan-out is the side of this component where cost multiplies.
// Rounds arriving inside the window bump the count and arm a single deferred flush
// instead, so a salvo costs one or two packets rather than twelve.
#define SEND_INTERVAL 1

// ── Store caps ───────────────────────────────────────────────────────────────
// GVAR(tracks) on the server, GVAR(contacts) on each curator's client. Both drop
// the OLDEST entries when exceeded, so a contact is never refused — what is lost is
// the least recent one.
//
// Sized well above the plausible live count for the same reason rtz_spotting's caps
// were raised (see its script_component.hpp): the cap scan fires whenever the map
// sits over the line, so a cap set NEAR the real working set means walking the whole
// map on every event to free almost nothing. A mission's artillery count is in the
// tens.
#define TRACK_CAP 128
#define CONTACT_CAP 128

// ── Display ──────────────────────────────────────────────────────────────────
// Seconds the incoming-impact ring stays up past its estimated splash time. Covers
// the error in the TOF estimate above and gives the ring a moment to be read after
// the rounds land.
#define SPLASH_HOLD 5

// Contact colours. Origin is the hostile-artillery red-orange; incoming is a
// lighter amber so the two never read as the same thing on a busy map — one marks
// ground to attack, the other ground to leave.
#define COLOR_ORIGIN [0.90, 0.35, 0.10, 0.90]
#define COLOR_INCOMING [1.00, 0.75, 0.15, 0.85]

// Map icon + label. Sizes match the spotting overlay's map icons (MAP_ICON_SIZE /
// 0.03 / RobotoCondensed) so the two overlays read as one mod.
#define MAP_ICON_SIZE 24
#define LABEL_TEXT_SIZE 0.03
#define LABEL_FONT "RobotoCondensed"

// Textures. All three are already referenced elsewhere in RTZ, so none of them is
// an unverified path. Note that the simpletasks family insets its glyph about 12%
// on every side (Gotchas §3) — both icons below come from families that are drawn
// consistently with the mod's other map icons.
#define ICON_ORIGIN "\a3\ui_f\data\igui\cfg\simpletasks\types\destroy_ca.paa"
#define ICON_INCOMING "\a3\ui_f\data\igui\cfg\targeting\impactpoint_ca.paa"
#define ICON_TOGGLE "\a3\ui_f\data\igui\cfg\simpletasks\types\search_ca.paa"

// Context-action tint (FUNC(displayActionModifier)): white while the overlay is
// shown and the action will hide it, grey while it is hidden. Named rather than
// written inline because SET_ACTION is a macro and the preprocessor splits its
// arguments on commas — a bare [1, 1, 1, 1] there reads as four arguments.
#define COLOR_ACTION_ON [1, 1, 1, 1]
#define COLOR_ACTION_OFF [0.5, 0.5, 0.5, 1]

// ── Fire mission ─────────────────────────────────────────────────────────────
// The ZEN identifiers this component reaches into, named here so a ZEN upgrade has
// exactly one place to re-check:
//
//   ZEN/addons/modules/CfgVehicles.hpp   zen_modules_moduleFireMission
//                                        zen_modules_moduleCreateTarget
//   ZEN/addons/modules/gui.hpp           zen_modules_RscFireMission
//   ZEN/addons/modules/XEH_preInit.sqf   zen_modules_saved (CBA namespace)
//   ZEN/addons/modules/stringtable.xml   the target name format ("Target %1")
//   ZEN/addons/common/XEH_postInit.sqf   zen_common_setName (CBA event)
//
// The namespace key holds the dialog's last-used field values as
// [mode, grid, target, spread, units, ammo, rounds] — read at
// zen_modules_fnc_gui_fireMission:23, written back on every confirm at its
// line 146. Mode 0 is Map Grid, mode 1 is Target Module, and in target mode the
// third element is an INDEX into zen_position_logics' list for the target type
// (negative values -3/-2/-1 being its random/nearest/farthest modes).
#define FIRE_MISSION_MODULE "zen_modules_moduleFireMission"
#define FIRE_MISSION_DIALOG "zen_modules_RscFireMission"
#define FIRE_MISSION_TARGET "zen_modules_moduleCreateTarget"
#define TARGET_NAME_FORMAT "STR_ZEN_Modules_ModuleCreateTarget_Format"
// ZEN's own naming event, the one zen_position_logics_fnc_add raises. Used to name the
// target a SECOND time, after initModule's group rehome has wiped the first — see
// FUNC(selectFireMission). Raised rather than calling setName directly so the name is
// applied on every machine the way ZEN applies it.
#define ZEN_EVENT_SETNAME "zen_common_setName"
#define ZEN_SAVED_FIREMISSION "zen_modules_fireMission"
#define ZEN_SAVED_DEFAULT [1, "", -3, 0, 99, "", 1]
#define SAVED_INDEX_MODE 0
#define SAVED_INDEX_TARGET 2
#define SAVED_MODE_TARGET 1

// Standard BI dialog exit codes, read in FUNC(guiFireMission)'s Unload handler.
// RTZ has no macro for these and ZEN's are private to its own components.
#define IDC_OK 1

// Seconds FUNC(selectFireMission) waits for a freshly created target to appear in
// zen_position_logics' list AND to be rehomed out of its throwaway group by
// zen_modules_fnc_initModule, before giving up and deleting it. The rehome is a
// next-frame server action and costs nothing here; the registration is a
// server round trip (zen_position_logics_fnc_add hands off with CBA_fnc_serverEvent
// when called from a client and the server broadcasts the list back), so it is
// instant on a hosted session and a network hop on a dedicated one. Bounded because
// CLAUDE.md forbids an unbounded waitUntilAndExecute — a lost packet must not leave
// a permanent condition running for the rest of a multi-hour mission.
#define TARGET_REGISTER_TIMEOUT 5

// The icon ZEN's own removed FireArtillery entry used, so the replacement lands
// in the same place looking like the same thing.
#define ICON_FIREMISSION "\a3\ui_f\data\gui\cfg\communicationmenu\artillery_ca.paa"

// Cursor tint while picking. ZEN's values from
// zen_context_actions_fnc_selectArtilleryPos, kept identical so the two mods'
// pickers do not disagree about what green means. UNKNOWN is for a selection with
// no artillery magazine to test against (a pure-VLS battery): the picker says
// nothing about range rather than claiming a verdict it cannot reach.
#define COLOR_IN_RANGE [0, 0.9, 0, 1]
#define COLOR_OUT_OF_RANGE [0.9, 0, 0, 1]
#define COLOR_UNKNOWN_RANGE [1, 1, 1, 1]
