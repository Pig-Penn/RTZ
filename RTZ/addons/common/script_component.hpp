#define COMPONENT common
#define COMPONENT_BEAUTIFIED Common
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_COMMON
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_COMMON
    #define DEBUG_SETTINGS DEBUG_SETTINGS_COMMON
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// This component is shared INFRASTRUCTURE only: selection normalizers, the
// errand engine, and presentation helpers other components call. Features that
// happen to be small do not belong here — the deploy-countermeasures order, the
// curator keybind orders and the spawned-unit skill table all used to live in
// this file's component and are now rtz_smoke, rtz_orders and rtz_skill. Every
// other addon requires rtz_common, so anything parked here is loaded by
// everyone whether they use it or not.

// FUNC(sideColor) palette index for a side with no entry of its own (civilian)
#define SIDE_COLOR_DEFAULT 4

// ── The Zeus 3D marker (FUNC(drawZeusIcon)) ─────────────────────────────────
// Vanilla's own placement marker, rebuilt. The engine draws one for ITS ghost
// and not for ours — an RTZ ghost is a plain createVehicleLocal object, never
// the curator's placement preview — so RTZ draws the same composite by hand,
// with the textures and colours vanilla uses in CfgCurator >> DrawObject >> 3D:
//
//   fill   entity_selected_ca.paa (a solid disc)  colorPreviewBackground {1,1,1,0.25}
//   ring   entity_ca.paa          (a thin ring)   colorPreview           {1,1,1,1}
//   glyph  CfgVehicles >> icon                    colorPreview
//
// Both textures are 128x128 with the shape entirely in the alpha channel and
// white RGB throughout, so drawIcon3D's colour argument tints them freely —
// which is what lets rtz_place hand the same function a side colour.
#define ICON_ZEUS_DISC "\a3\ui_f_curator\data\cfgcurator\entity_selected_ca.paa"
#define ICON_ZEUS_RING "\a3\ui_f_curator\data\cfgcurator\entity_ca.paa"
#define ZEUS_ICON_FILL_ALPHA 0.25
#define ZEUS_ICON_GLYPH_COEF 0.75

// A FLAT NUMBER, AND NOT A DISTANCE MULTIPLE. drawIcon3D already holds an icon
// at a constant apparent size — the same property rtz_hud leans on when it sizes
// tag icons straight off the tag TEXT size (ICON_DRAW) and expects them to stay
// glued to it at any range. Vanilla's sizeCoefStartDistance / sizeCoefEndDistance
// are the engine compensating inside a system that needs it; scaling by camera
// range here just made the marker grow as the curator pulled back. The one knob
// worth turning if the ring wants to be bigger or smaller.
//
// 0.65 is vanilla's own iconSize, one level up from the 3D block the colours come
// from. It was 1.0, which is where the two differences against a side-by-side
// vanilla screenshot came from — and they were ONE difference wearing two hats.
// An oversized ring is a thicker white band in pixels, so it reads heavy; an
// oversized disc lays its wash over more ground, so it reads as a darker fill.
// Shrinking the composite fixes both, and the glyph rides along because
// ZEUS_ICON_GLYPH_COEF is a fraction of this rather than a size of its own.
#define ZEUS_ICON_SIZE 1

// Size the placement preview's hint text draws at
#define PREVIEW_TEXT_SIZE 0.03

// ── Surface tracing (FUNC(surfaceStack), FUNC(cursorSurface)) ────────────────
// A surface counts as standable when its normal points mostly up. 0.5 is the
// cosine of 60 degrees, so anything shallower than a 60-degree slope qualifies —
// the value both trace sites have always used, defined once now that they share
// a pair of functions.
#define SURFACE_FLAT_MIN 0.5

// The vertical column FUNC(surfaceStack) probes, in metres above and below the
// TERRAIN height at the sampled x/y. Up has to clear the tallest building on the
// map (a Kavala apartment block is ~30 m; 200 covers towers and comms masts with
// room to spare) because the roof is a legitimate answer. Down only has to reach
// through the terrain surface itself.
#define SURFACE_PROBE_UP 200
#define SURFACE_PROBE_DOWN 10

// Hits the column probe will collect. This is a FLOOR COUNT, not a safety
// margin: every storey of a building is one hit, and a stack truncated at the
// top silently loses the ground floor — the very answer an indoor placement
// wants. 10 covers anything on the shipped terrains. Paid once per sampled
// point, never per frame.
#define SURFACE_PROBE_HITS 10

// Hits the CURSOR ray collects. Only the nearest flat one is ever used, so this
// just has to be enough to see past the intervening non-flat geometry (walls,
// railings, foliage) between the camera and it. Unchanged from the value the
// placement preview has always used.
#define SURFACE_CURSOR_HITS 5

// Icons for the shared context-menu submenu anchors (CfgZenContext.hpp)
#define ICON_SUBMENU_OVERLAYS "\a3\ui_f\data\igui\cfg\simpletasks\types\documents_ca.paa"
#define ICON_SUBMENU_CONTROL "\a3\ui_f\data\igui\cfg\simpletasks\types\help_ca.paa"

// The icon ZEN's own Vehicle Logistics folder carried, reused deliberately:
// RTZ_Vehicle REPLACES that folder (FUNC(regroupVehicleActions) moves ZEN's
// entries in and deletes it), so keeping the truck means a curator sees the same
// glyph in the same place under a shorter name rather than a folder that looks
// new. rtz_supply defines the same path as ICON_RESUPPLY for the same reason.
#define ICON_SUBMENU_VEHICLE "\a3\ui_f\data\igui\cfg\simpleTasks\types\truck_ca.paa"
