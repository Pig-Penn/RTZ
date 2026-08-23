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

// Model-space top, MEMOIZED PER CLASS. boundingBoxReal is a model-geometry query,
// and this function runs once per tagged entity per frame — up to SEL_MAX_UNITS +
// SEL_MAX_VEHICLES times a frame on every curator's machine, i.e. well over a
// thousand of them a second at 60 fps. What it returns is the MODEL's extent, which
// is exactly what the header above argues a tag anchor wants: a per-class constant
// that no stance, no animation and no torso turn moves. A value that cannot vary
// per object never needed to be asked per object per frame.
//
// This is NOT the mistake the MODEL_TOP macro warns about, and the distinction is
// the whole reason that warning is phrased the way it is: memoizing the ANIMATED
// read (selectionPosition, HEAD_POS) fakes a constant that does not exist and
// freezes every man of a class in one pose. The bounding box already IS the
// constant, so caching it changes no output on any frame — only how often the
// engine is asked for it.
//
// Cached HERE rather than hoisted into an EFUNC(common,...) helper, which is the
// same call-cost decision HEAD_POS documents from the other side. The mod's two
// other bounding-box reads (EFUNC(spotting,drawSpots), EFUNC(spotting,drawRcIndicator))
// sit INLINE in their renderers' per-entity loops, where routing through a function
// would buy a fresh scope and a `params` destructure per entity per frame — more
// than the read it replaced. Both are also cold: each is a fallback behind
// unitAimPositionVisual, reached only by a hull with no crew aim point. This is the
// only hot site, and being a function already, it pays no new `call` to cache.
private _class = typeOf _obj;
private _top = GVAR(modelTopCache) get _class;

if (isNil "_top") then {
    _top = MODEL_TOP(_obj);

    // A 0 is deliberately NOT stored. MODEL_TOP yields 0 rather than throwing while
    // the model has not resolved on this machine (Gotchas §3) — the frames right
    // after Zeus creates an object — and caching that would pin every entity of the
    // class to its own feet for the rest of the mission. That is the same
    // unresolved-model frame the `count < 3` test at the bottom already absorbs,
    // except cached it would be permanent instead of lasting one frame.
    if (_top > 0) then {
        GVAR(modelTopCache) set [_class, _top];
    };
};

private _pos = if (_obj isKindOf "CAManBase") then {
    // Top of the model, not the live head — see the header. Stance-independent, so
    // the tag does not dive onto the Zeus icon when the man goes prone.
    _obj modelToWorldVisual [0, 0, _top]
} else {
    // unitAimPositionVisual resolves through the crew's aim point and returns []
    // for a vehicle that has none to offer — an empty hull, or any vehicle in the
    // frames between Zeus creating it and its crew being moved in. Fall back to
    // the model's bounding-box top centre.
    private _aim = unitAimPositionVisual _obj;
    if (count _aim >= 3) then {
        _aim
    } else {
        _obj modelToWorldVisual [0, 0, _top]
    }
};

[[], _pos] select (count _pos >= 3)
