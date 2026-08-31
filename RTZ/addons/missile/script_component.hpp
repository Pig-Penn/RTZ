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
// One entry per reported launch, held on the curator's client in GVAR(tracked).
// Records are appended in arrival order, which is what makes "evict the oldest"
// a deleteAt 0 rather than a scan.
#define REC_MISSILE 0
#define REC_TARGET  1
#define REC_COLOR   2
#define REC_EXPIRY  3
#define REC_SEEN    4

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
#define RECENT_CAP 64

// Guided-ammo verdict cache (FUNC(detectIncoming)), keyed by ammo classname.
// Flushed whole at the cap rather than evicted one by one — there are only so
// many ammo classes in a modset, so this realistically never fires.
#define GUIDED_CACHE_MAX 128

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
#define ICON_SIZE_3D 2.4
#define ICON_SIZE_MAP 56
#define LINE_WIDTH_3D 4
#define LINE_WIDTH_MAP 3
