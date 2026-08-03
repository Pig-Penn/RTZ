#define COMPONENT spotting
#define COMPONENT_BEAUTIFIED Spotting
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#include "\x\rtz\addons\main\script_macros.hpp"

// Detection thresholds (fnc_spotCheck): knowsAbout value at/above which a
// group counts as heard/known (NATO marker on the leader) vs. individually
// confirmed (wedge chevron on the member).
#define SOFT_THRESHOLD 1.0
#define HARD_THRESHOLD 1.5

// Once a member's knowsAbout crosses HARD_THRESHOLD (chevron shown), that
// result is latched per (spotter side, unit) for this many seconds — the
// per-spotter knowsAbout loop for that unit is skipped entirely while the
// latch is live, since it's the expensive part of fnc_spotCheck (fnc_spotCheck).
#define CHEVRON_LATCH_DURATION 10
#define CHEVRON_LATCH_CAP 256

// Seconds a group must have been OUT of confirmed contact (below HARD_THRESHOLD
// for the reporting side) before it can trigger another radio contact report.
// GVAR(spotGroupLastSeen) is refreshed on every tick the group stays confirmed,
// so a group under continuous observation is announced exactly once; only one
// that is genuinely lost for this long and then re-acquired reports again
// (fnc_spotCheck).
#define GROUP_CALLOUT_COOLDOWN 120

// Spot marker naming + wedge (individual chevron) look.
#define MKR_PREFIX "rtz_spot_"
#define WEDGE_TEXTURE "\a3\ui_f\data\gui\rsc\RscDisplayEGSpectator\UnitIcon_ca.paa"
#define WEDGE_ALPHA 0.60
#define COLOR_INCAPACITATED [0.5, 0.0, 0.5, WEDGE_ALPHA]

// Housekeeping: bound the long-lived rate-limit maps (fnc_spotCheck).
#define BLINK_THROTTLE_CAP 128
#define BLINK_THROTTLE_WINDOW 5
#define FIRE_BLINK_THROTTLE 0.1
// GVAR(spotGroupLastSeen) holds one entry per (side, group) in or recently out of
// confirmed contact — sized to SIMULTANEOUS contacts, not to callouts, since it is
// stamped on every tick a group stays confirmed. Set well above the plausible live
// count so the prune walk isn't entered every tick to free nothing.
#define GROUP_LAST_SEEN_CAP 512

// Echelon/size amplifier squad-size breakpoints (fnc_echelonTex). ~8 men per
// squad — adjust if your squads differ.
#define ECHELON_FIRETEAM_MAX 4
#define ECHELON_SQUAD_MAX 8
#define ECHELON_MULTI_SQUAD_MAX 15

// The four amplifier textures, indexed by the dot count FUNC(echelonTex) resolves
// (0 = fire team … 3 = 2+ squads). A literal table rather than a `format` on the
// index: the function runs once per spotted group per curator side per detection
// tick, and the result never varies beyond these four. Kept on ONE line — a stray
// space after a line-continuation `\` silently truncates the macro (Gotchas §6).
#define ECHELON_TEXTURES ["\a3\ui_f\data\map\markers\nato\group_0.paa", "\a3\ui_f\data\map\markers\nato\group_1.paa", "\a3\ui_f\data\map\markers\nato\group_2.paa", "\a3\ui_f\data\map\markers\nato\group_3.paa"]

// How long a spotted unit's chevron flashes white after it fires
// (fnc_spottingSystem's FiredMan handler).
#define BLINK_DURATION 0.15

// ── Zeus MAP icon overlay (fnc_initCuratorDisplay) ───────────────────────────
// This component draws the spotting picture on the Zeus MAP; the 3D WORLD
// rendering of the same data lives in rtz_hud (fnc_drawSpots, fnc_drawRcIndicator)
// and is tuned by that component's own header. Only the map-side constants belong
// here — the world-side twins (WEDGE_MAX_DIST, CHEVRON_*, GROUP_ZMOD_*,
// AMP_GAPS_WORLD, RC_ICON_*) sat here as dead copies after the rtz_hud split and
// were silently ignored by the renderers that had moved, so tuning them did
// nothing. Keep it that way: a constant belongs to whichever component DRAWS with it.
//
// Echelon amplifier vertical gap above the group icon, indexed by side idx
// (0 = BLUFOR rectangle, 1 = OPFOR diamond — peaks highest, 2 = independent/
// civilian square), in map screen-space.
#define AMP_GAPS_MAP [0.005, 0.011, 0.005]
#define MAP_ICON_SIZE 24

// Officer editing-area zone ring overlay (fnc_initCuratorDisplay).
#define COLOR_ZONE_RING [0.25, 0.55, 1, 0.85]

// Remote-control DETECTION (fnc_remoteControlIndicator). RC_CHECK_TICK is the
// base tick (s) of the server scan PFH; the effective cadence is the
// GVAR(rcCheckInterval) CBA setting, read live and floored to this value.
// The indicator's LOOK is rtz_hud's (fnc_drawRcIndicator).
#define RC_CHECK_TICK 1
#define RC_OWNER_VAR "bis_fnc_moduleRemoteControl_owner"

#define ICON_TOGGLE_CHEVRONS "\a3\ui_f\data\igui\cfg\simpletasks\types\meet_ca.paa"
