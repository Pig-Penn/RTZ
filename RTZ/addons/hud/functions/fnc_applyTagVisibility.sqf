#include "script_component.hpp"
/*
 * Author: Maxim
 * Sync every tag system's renderer registration and stream demand with its
 * TAG_VISIBLE flag. The flags stay the single source of truth; this is what makes
 * them take effect.
 *
 * Registration, not an early exit, is how a hidden tag system is switched off: an
 * unregistered renderer is never called, and with every renderer gone
 * EFUNC(core,frameLoop) skips building the camera basis entirely. A system that
 * merely returned early still cost a call per frame forever.
 *
 * The demand is set from the SAME loop as the registration, which is the point of
 * this function existing rather than each caller doing both. A renderer that is
 * registered while its demand is withdrawn draws from a store the server has
 * stopped filling; a demand left standing while the renderer is gone keeps the
 * server gathering and pushing packets nobody draws. The engine used to work the
 * infantry half out for itself by reading GVAR(unitTagsVisible) by name — the
 * display knowledge that kept it welded to this component — and needed a
 * defensive GETGVAR to do it, because that flag did not exist until the tag
 * system started (docs/Knowledge Base/Gotchas.md §2). Declaring it from the
 * consumer side removed both problems.
 *
 * Systems that were never started (master setting off) are simply not in
 * GVAR(tagSystems), so there is nothing to guard against here.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_hud_fnc_applyTagVisibility
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

{
    // ALIAS THE KEY: every call below runs code that loops internally, and _x is
    // read after them (docs/Knowledge Base/Gotchas.md §2).
    private _id = _x;
    _y params ["_visible", "", "", "_renderer", "_priority", "_slices"];

    if (_visible) then {
        [_id, _renderer, RENDER_WORLD, _priority] call EFUNC(core,registerRenderer);
    } else {
        [_id, RENDER_WORLD] call EFUNC(core,unregisterRenderer);
        // Drop the built entries with the renderer. Withdrawing the demand below
        // stops the feed, so anything left here would be re-drawn on the next
        // show against however stale the data had become — and on a multi-hour
        // operation a hidden system would otherwise sit on a cache entry per
        // entity the curator ever selected.
        _y set [TAG_CACHE, createHashMap];
        _y set [TAG_DIRTY, true];
    };

    // Withdrawing is an empty slice list — the entry is dropped rather than kept
    // as a row of falses. No `detailed`: no tag shows a field that needs the
    // expensive per-unit intel, which only the selection dialog does.
    [_id, [[], _slices] select _visible] call EFUNC(core,setDemand);
} forEach GVAR(tagSystems);
