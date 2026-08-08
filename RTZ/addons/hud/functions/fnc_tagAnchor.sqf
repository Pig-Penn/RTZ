#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT. Resolves the world point a head tag hangs above, for either kind of
 * tagged entity — a man's head, or a vehicle's crew aim point. Returns [] when
 * the model has not resolved on this machine yet.
 *
 * The [] return is the whole reason this is one function rather than four lines
 * in each renderer. Every position command here can return [] in the frames right
 * after Zeus creates an object (docs/Knowledge Base/Gotchas.md §3), `distance`
 * throws a Generic error on [], and that error ABORTS THE WHOLE forEach — so one
 * unresolved entity used to drop every tag after it in the store, not just its
 * own. Both renderers had to know that, and both had to know that
 * unitAimPositionVisual's bounding-box fallback is not guaranteed either. One
 * caller-side `count < 3` test now covers all of it.
 *
 * Arguments:
 * 0: Tagged entity <OBJECT>
 *
 * Return Value:
 * World position, or [] if the model is not resolved yet <ARRAY>
 *
 * Example:
 * private _base = [_unit] call rtz_hud_fnc_tagAnchor
 *
 * Public: No
 */

params ["_obj"];

private _pos = if (_obj isKindOf "CAManBase") then {
    _obj modelToWorldVisual ([_obj] call EFUNC(common,headOffset))
} else {
    // unitAimPositionVisual resolves through the crew's aim point and returns []
    // for a vehicle that has none to offer — an empty hull, or any vehicle in the
    // frames between Zeus creating it and its crew being moved in. Fall back to
    // the model's bounding-box top centre.
    private _aim = unitAimPositionVisual _obj;
    if (count _aim >= 3) then {
        _aim
    } else {
        private _top = ((boundingBoxReal _obj) param [1, []]) param [2, 0];
        _obj modelToWorldVisual [0, 0, _top]
    }
};

[[], _pos] select (count _pos >= 3)
