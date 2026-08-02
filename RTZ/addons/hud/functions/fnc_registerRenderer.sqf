#include "script_component.hpp"
/*
 * Author: Maxim
 * Add a renderer to the shared frame loop (FUNC(frameLoop)). Idempotent: calling
 * it again for the same id replaces that entry rather than drawing the display
 * twice, so a display whose start path can run more than once (a setting flipped
 * back on, a toggle re-fired) cannot double-register.
 *
 * The function is stored as a LINKFUNC-style reference by the CALLER — pass
 * LINKFUNC(drawX), not a literal code block — so a PREP recompile is picked up
 * without re-registering.
 *
 * Renderers are kept sorted by priority so the draw order is a property of the
 * declaration, not of which display happened to initialise first. Lower numbers
 * draw first (and so end up UNDER later ones where they overlap).
 *
 * A RENDER_WORLD renderer is called with the frame context array (see the CTX_*
 * indices in script_component.hpp); a RENDER_UI renderer is called with the
 * curator display, or displayNull when Zeus is closed.
 *
 * Arguments:
 * 0: Renderer id — unique per display <STRING>
 * 1: Renderer function <CODE>
 * 2: Renderer class, RENDER_WORLD or RENDER_UI <NUMBER>
 * 3: Draw priority, ascending <NUMBER> (default: 50)
 *
 * Return Value:
 * None
 *
 * Example:
 * [QGVAR(unitTags), LINKFUNC(drawUnitTags), RENDER_WORLD, 30] call rtz_hud_fnc_registerRenderer
 *
 * Public: No
 */

params ["_id", "_fnc", "_mode", ["_priority", 50]];

if (!hasInterface) exitWith {};

private _list = [GVAR(worldRenderers), GVAR(uiRenderers)] select (_mode == RENDER_UI);

// Replace any existing entry for this id, then re-sort. Both halves matter: the
// find keeps a re-run of a display's start path from stacking a second copy of
// its draw, and the sort keeps priority authoritative regardless of the order
// displays initialise in.
private _index = _list findIf {(_x select 0) == _id};
if (_index != -1) then {
    _list set [_index, [_id, _fnc, _priority]];
} else {
    _list pushBack [_id, _fnc, _priority];
};

// sort on the trailing priority: [id, fnc, priority] sorts by id first, which
// would order alphabetically, so build the ordering key explicitly.
private _sorted = [];
{ _sorted pushBack [_x select 2, _forEachIndex] } forEach _list;
_sorted sort true;
private _out = _sorted apply {_list select (_x select 1)};

if (_mode == RENDER_UI) then {
    GVAR(uiRenderers) = _out;
} else {
    GVAR(worldRenderers) = _out;
};
