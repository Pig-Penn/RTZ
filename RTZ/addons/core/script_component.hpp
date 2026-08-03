#define COMPONENT core
#define COMPONENT_BEAUTIFIED Core
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_CORE
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_CORE
    #define DEBUG_SETTINGS DEBUG_SETTINGS_CORE
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// NOTE: the two contracts this component implements are declared in main's
// script_macros.hpp, NOT here — RENDER_WORLD / RENDER_UI and the CTX_* frame
// context indices for the frame loop, SRC_UNITS / SRC_VEHS / SRC_HULLS for the
// stream engine, plus SEL_MAX_UNITS / SEL_MAX_VEHICLES / VEH_SIDE_OK / SIDE_NUM
// which the engine applies and the displays must agree with. Any component may
// register a renderer or declare a stream, and component headers are not visible
// to each other.

// Base tick (s) of the single server stream loop (FUNC(streamServer)) — the
// fastest any stream can run. Each stream declares its own effective cadence (see
// FUNC(registerStream)), read live from its CBA setting each tick and floored to
// this value, so one loop serves feeds that want 0.3 s and feeds that want 2 s
// without either paying the other's rate.
#define STREAM_TICK 0.25

// Client selection poll (s). ONE poll owns the curator's selection for every
// display and every stream subscription — the overlays used to re-resolve
// `curatorSelected` inside their Draw3D handler, i.e. sixty times a second, to
// notice a change this poll already tracks four times a second.
#define SEL_POLL_INTERVAL 0.25

// Icon tint every overlay toggle takes while it is RUNNING — grey, meaning "click
// to hide". The off-state tint is the stream's own accent, declared with it
// (FUNC(registerStream)); this one is shared so the running state reads
// identically across all of them.
#define COLOR_OVERLAY_ON [0.50, 0.50, 0.50, 1]
