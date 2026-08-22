#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT. Resolves the world point a head tag hangs above, for either kind of
 * tagged entity — the top of a man's model, or a vehicle's crew aim point.
 * Returns [] when the model has not resolved on this machine yet.
 *
 * A man anchors to MODEL_TOP, NOT to HEAD_POS, and the difference is a stance.
 * `selectionPosition` is animated (Gotchas §`selectionPosition` is animated), so the
 * live head sits ~1.65 m up in model space standing and ~0.3 m up prone — a tag hung
 * on it fell about a metre and a third the moment its unit went prone and landed on
 * the basegame Zeus entity icon, which stays put. FUNC(drawUnitTags)' Tag Height lift
 * is a flat offset and cannot compensate for a moving floor. The bounding box is the
 * MODEL's, not the animation's, so the tag holds one height through every stance and a
 * squad in mixed stances reads as a row of labels instead of a staircase.
 *
 * The body-tracking renderers still want the animated read and still use HEAD_POS:
 * a spot chevron (EFUNC(spotting,drawSpots)) and the remote-control portrait
 * (EFUNC(spotting,drawRcIndicator)) mean "this man", not "this entity's label", and
 * should follow him down.
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
    // Top of the model, not the live head — see the header. Stance-independent, so
    // the tag does not dive onto the Zeus icon when the man goes prone.
    _obj modelToWorldVisual [0, 0, MODEL_TOP(_obj)]
} else {
    // unitAimPositionVisual resolves through the crew's aim point and returns []
    // for a vehicle that has none to offer — an empty hull, or any vehicle in the
    // frames between Zeus creating it and its crew being moved in. Fall back to
    // the model's bounding-box top centre.
    private _aim = unitAimPositionVisual _obj;
    if (count _aim >= 3) then {
        _aim
    } else {
        _obj modelToWorldVisual [0, 0, MODEL_TOP(_obj)]
    }
};

[[], _pos] select (count _pos >= 3)
