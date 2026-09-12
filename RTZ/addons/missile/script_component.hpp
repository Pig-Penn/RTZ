#define COMPONENT missile
#define COMPONENT_BEAUTIFIED Missile
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_MISSILE
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_MISSILE
    #define DEBUG_SETTINGS DEBUG_SETTINGS_MISSILE
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// RENDER_WORLD / CTX_* — the 3D marker registers with rtz_core's frame loop
// (FUNC(start) / FUNC(draw3D)).
#include "\x\rtz\addons\core\script_macros_core.hpp"

// ── Track record layout ─────────────────────────────────────────────────────
// One entry per reported threat, held on the curator's client in GVAR(tracked).
// Records are appended in arrival order, which is what makes "evict the oldest"
// a deleteAt 0 rather than a scan.
//
// ONE store holds both kinds, and they use it in two different ways.
//
// A MISSILE record TRACKS: it rides its projectile, falls back to the unit that
// projectile is chasing while the projectile has not resolved on this machine, and
// is promoted to a longer life by FUNC(pruneTracked) the first frame it does.
//
// A GRENADE record tracks NOTHING. ZEN's throw action aims at a POSITION, and that
// aim point is the whole warning — so the record carries objNull in both object
// slots for its entire life and its marker sits STATIC on REC_FALLBACK until it
// expires. That is not a degraded fallback, it is the intended display: "a grenade
// is landing HERE" is what a curator needs, and it stays put and readable where a
// marker riding a tumbling grenade would be a fast-moving dot.
//
// REC_KIND is what the draw passes read to pick a glyph and to decide whether a
// line to target is meaningful.
#define REC_MISSILE  0   // objNull for a grenade, always
#define REC_TARGET   1   // objNull for a grenade, always
#define REC_COLOR    2
#define REC_EXPIRY   3
#define REC_SEEN     4
#define REC_KIND     5
#define REC_FALLBACK 6   // [] for a missile, ASL aim point for a grenade

#define KIND_MISSILE 0
#define KIND_GRENADE 1

// Maximum live tracks on a curator's client. A dozen simultaneous missiles is
// already an unreadable screen; the cap exists so a scripted mass launch cannot
// grow the list without bound. The OLDEST record is evicted rather than the new
// one refused, matching rtz_battery's contact registry.
#define TRACK_CAP 32

// Server-side coalescing (FUNC(reportIncoming)). One warning per target per
// window is enough: a launcher salvo would otherwise cost one
// curatorEditableObjects walk per missile. Long enough to swallow a salvo, short
// enough that a genuine second engagement still reports.
#define RECENT_WINDOW 3

// Shared cap for BOTH coalescing windows, enforced by FUNC(claimWindow) — the
// missile half's GVAR(recent) and the grenade half's GVAR(recentGrenades) are
// separate maps with separate key spaces but the same bound.
#define RECENT_CAP 64

// Shared cap for BOTH ammo verdict caches, enforced by FUNC(ammoVerdict) —
// GVAR(guidedAmmo) and GVAR(explosiveAmmo). Flushed whole at the cap rather than
// evicted one by one: the key space is the set of ammo classes in the modset, so
// this is a safety net rather than a working mechanism.
#define AMMO_CACHE_MAX 128

// Hard ceiling on a track's life once its projectile has actually been seen, in
// seconds. Normal end-of-life is the projectile going null on impact; this only
// catches a record whose projectile somehow never nulls, so that a mission
// running for hours cannot accumulate them.
#define MISSILE_TIMEOUT 30

// How long a track survives when its projectile never resolves on this machine at
// all, in seconds. Missiles are network objects, but if one is not synced here
// there is nothing to ride, and the marker falls back to the threatened unit for
// this long rather than vanishing silently. Sized to a plausible flight time.
#define FALLBACK_DURATION 5

// Marker drawing. The vanilla sensor-panel missile silhouette — the symbol the
// engine's own targeting display uses for a missile track, so it reads as a
// missile rather than as a generic hazard.
//
// The sizes look large next to the ICON_SIZE_* of the other components because
// this glyph is small inside its own texture: its alpha fills 0.375 of a 64x64
// sheet, against 0.75-0.875 for the simpleTasks glyphs everything else uses. The
// ~2.2x here buys back the dead margin, it does not draw a bigger marker.
#define ICON_MISSILE "\a3\ui_f\data\IGUI\RscCustomInfo\Sensors\Targets\missileAlt_ca.paa"
#define ICON_SIZE_3D 1
#define ICON_SIZE_MAP 28
#define LINE_WIDTH_3D 4
#define LINE_WIDTH_MAP 3

// ── Incoming grenades (ZEN curator-ordered throws) ──────────────────────────
// How long a grenade warning stays on screen, in seconds.
//
// This is a DISPLAY duration, not a safety ceiling. A grenade record tracks no
// projectile and has no promotion path (FUNC(receiveTrack), FUNC(pruneTracked)), so
// this number IS the marker's entire life. Sized to a flight of a second or two plus
// a fuse of about four, plus a beat to read it.
//
// It was 12 and named GRENADE_TIMEOUT while it was a dud-catching ceiling reached
// only AFTER a projectile had been seen. That meaning is gone with the static
// marker, so the name went with it — keeping the old one over new semantics is the
// trap Gotchas §3 spends three paragraphs on.
#define GRENADE_DURATION 8

// Server-side coalescing (FUNC(reportGrenade)). A ZEN throw order to an eight-man
// squad is eight grenades onto one aim point, and each would otherwise cost a
// curatorEditableObjects walk per curator. There is no shared target object to key
// on the way FUNC(reportIncoming) does, so the key is the AIM POINT quantized to a
// cell — as the two cell indices in an ARRAY, which is a legal HashMap key and is
// hashed by value.
//
// It was ONE NUMBER, packed as `xCell * 100000 + yCell`, and that was WRONG in a way
// the comment justifying it could not see. The stride was chosen to exceed the
// largest cell index a map can produce, which it does — but the PRODUCT is the
// problem, not the stride. SQF Numbers are 32-bit floats, exact for integers only to
// 2^24; on a 30 km terrain an x cell index reaches 6144, so the key reached ~6.14e8,
// where the gap between representable floats is 64. The y term was rounded away, and
// the intended 5 m cell silently became 8 m of y resolution at the west edge and
// 320 m at the east one. The Biki's own HashMap page warns about exactly this. The
// symptom was invisible: two distinct throws merge, and the SECOND WARNING IS
// DROPPED — the one failure this component exists to prevent.
//
// An array costs one small allocation per grenade. That is a per-THROW path, not the
// per-tick or per-entity path CLAUDE.md's allocation rule is about, and correctness
// at map scale is not purchasable any cheaper.
//
// The cell is small because it no longer has to absorb a squad's spread:
// zen_context_actions_fnc_selectThrowPos hands every unit in the selection the
// IDENTICAL position, so all that is left to quantize away is float noise and two
// curators aiming at very nearly the same spot inside the window. It was 15 back
// when the key was built from each THROWER's own position. Erring small also costs
// less now — a false merge drops the second warning outright rather than merely
// merging two markers that were both moving anyway.
#define GRENADE_COALESCE_CELL 5
#define GRENADE_WINDOW 2

// Fallback helper search in FUNC(detectGrenade), for the case where ZEN's doTarget
// does not survive the disableAI in the same call and assignedTarget comes back null.
//
// The radius is ZEN's own cap plus a margin: zen_context_actions_fnc_selectThrowPos
// refuses a unit further than 75 m from the aim point (MAX_DISTANCE), and ZEN disables
// PATH for the duration, so the thrower is not going anywhere.
//
// The arc is ZEN's own throw gate: zen_ai_fnc_throwGrenade only fires the magazine
// once `_unit getRelDir _helper` is inside a tolerance that widens from 10 to 45
// degrees, so a unit that has just thrown IS facing its own helper.
#define THROW_HELPER_RADIUS 80
#define THROW_HELPER_ARC 45

// Vanilla's warning triangle — read as "hazard here" at a glance and impossible to
// confuse with the missile silhouette. Unlike missileAlt_ca.paa its alpha fills
// most of its own sheet, so it needs none of that glyph's ~2.2x compensation.
#define ICON_GRENADE "\a3\ui_f\data\map\markers\military\warning_ca.paa"
#define ICON_GRENADE_SIZE_3D 1
#define ICON_GRENADE_SIZE_MAP 24
