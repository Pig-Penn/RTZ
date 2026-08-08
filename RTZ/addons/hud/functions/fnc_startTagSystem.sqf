#include "script_component.hpp"
/*
 * Author: Maxim
 * Declare one floating head-tag system: its cache state, the slices it wants
 * streamed, and its renderer's place in the shared frame loop. Registers the
 * record in GVAR(tagSystems) and syncs it in through FUNC(applyTagVisibility).
 *
 * This is the whole of what FUNC(unitTags) and FUNC(vehicleTags) used to be, and
 * they were near-identical: a visible flag, a cache, a dirty flag, one
 * CBA_SettingChanged watcher matching a setting-name prefix, and a call to
 * FUNC(applyTagVisibility). Keeping two copies meant every consumer of the state
 * — the toggle, the context action's label, both receivers, both renderers — read
 * two separate globals behind `isNil` guards, because either system may be
 * switched off in settings and a nil read aborts the whole enclosing script
 * (docs/Knowledge Base/Gotchas.md §2). A registry makes "this system does not
 * exist" the absence of a key instead, so the guards go away with the copies, and
 * a third tag system is one more declaration rather than one more file.
 *
 * The setting watcher is NOT registered here — it is one handler over the whole
 * registry, installed in XEH_preInit. Registering it per system would have fired
 * every system's prefix test once per system per settings change.
 *
 * The system id is used for THREE things — the registry key, the renderer id
 * passed to EFUNC(core,registerRenderer), and the consumer id passed to
 * EFUNC(core,setDemand). One name deliberately: a renderer that is registered
 * while its demand is withdrawn draws from a store the server stopped filling.
 *
 * Loading: called from XEH_postInit after CBA_settingsInitialized, gated on this
 *   system's own master setting. Client-only; registers a renderer and a demand,
 *   no scheduled ops and no event handlers — `call`ed, not `spawn`ed.
 *
 * Arguments:
 * 0: System id — unique, also the renderer and demand id <STRING>
 * 1: Setting-name prefix whose changes dirty this system's cache <STRING>
 * 2: Variable name of this system's master enable setting <STRING>
 * 3: Renderer function, pass LINKFUNC(drawX) <CODE>
 * 4: Draw priority within the frame loop, ascending <NUMBER>
 * 5: Selection slices to demand, SRC_* <ARRAY> (default: [])
 *
 * Return Value:
 * None
 *
 * Example:
 * [QGVAR(unitTags), QGVAR(tag), QGVAR(enableUnitTags), LINKFUNC(drawUnitTags), 30, [SRC_UNITS]] call rtz_hud_fnc_startTagSystem
 *
 * Public: No
 */

params ["_id", "_prefix", "_master", "_renderer", "_priority", ["_slices", []]];

if (!hasInterface) exitWith {};

// Lowercased on the way in: CBA_SettingChanged is not guaranteed to report a
// setting's name in the case it was registered with, and the watcher in
// XEH_preInit compares against these directly rather than lowercasing per event.
GVAR(tagSystems) set [_id, [
    true,             // TAG_VISIBLE  — systems start shown; the toggle hides them
    createHashMap,    // TAG_CACHE
    true,             // TAG_DIRTY    — nothing built yet
    _renderer,        // TAG_RENDERER
    _priority,        // TAG_PRIORITY
    _slices,          // TAG_SLICES
    toLower _prefix,  // TAG_PREFIX
    toLower _master   // TAG_MASTER
]];

// Registers the renderer and declares the demand. Not done inline: that pairing
// is what must never drift, so it lives in exactly one place and every later
// visibility change funnels through it too.
call FUNC(applyTagVisibility);
