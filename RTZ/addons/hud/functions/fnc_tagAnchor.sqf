#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT. Resolves the world point a head tag hangs above, for either kind of
 * tagged entity — a fixed height over a man's model, or a vehicle's crew aim
 * point. Returns [] when the model has not resolved on this machine yet.
 *
 * A man anchors to the flat MAN_TAG_TOP — NOT to HEAD_POS, and NOT to his
 * bounding box, because BOTH of those are animated.
 *
 * `selectionPosition` is the documented half (Gotchas §`selectionPosition` is
 * animated): the live head sits ~1.65 m up in model space standing and ~0.3 m up
 * prone, so a tag hung on it fell about a metre and a third the moment its unit
 * went prone and landed on the basegame Zeus entity icon, which stays put.
 * FUNC(drawUnitTags)' Tag Height lift is a flat offset and cannot compensate for
 * a moving floor.
 *
 * `boundingBoxReal` was the fix for that, and it was WRONG IN THE SAME WAY. It
 * took a screenshot of a chest-height tag to catch. Measured on three men:
 *
 *   O_soldier_M_F   PRONE    [[-0.8, -1.15, -0.1], [0.8, 1.05, 0.8]]
 *   O_Soldier_AR_F  CROUCH   [[-0.8, -1.15, -0.1], [0.8, 1.05, 1.9]]
 *   O_medic_F       PRONE    [[-0.8, -1.15, -0.1], [0.8, 1.05, 0.8]]
 *
 * The x/y extents are identical across all three and far too big for a man
 * (1.6 x 2.2 m — a prone footprint): for CAManBase the engine returns a GENERIC
 * box rather than a model-fitted one, and its top is STANCE-QUANTIZED — 1.9
 * upright, 0.8 prone. `boundingBox` returns byte-identical values, so it is no
 * escape hatch either. Nothing about it is the per-class model constant it was
 * taken for.
 *
 * Which made the per-class memo this function used to run a bug rather than a
 * saving: it froze whichever stance the first man of a class happened to be in
 * when the cache was populated, so one prone rifleman pinned every rifleman of
 * that class to a 0.8 m anchor — a tag at chest height — for the rest of the
 * mission. That is exactly the failure the HEAD_POS macro warns about, reached
 * through the one command that was supposed to be immune to it.
 *
 * So men take a constant. It is the only genuinely stance-free anchor available,
 * and it costs no engine call and no cache lookup at all.
 *
 * The body-tracking renderers still want the animated read and still use
 * HEAD_POS: a spot chevron (EFUNC(spotting,drawSpots)) and the remote-control
 * portrait (EFUNC(spotting,drawRcIndicator)) mean "this man", not "this entity's
 * label", and should follow him down.
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
    // Flat model-space height — see the header for why nothing the engine can be
    // asked about a man is stance-free. Clears a standing man's head (~1.8 m) and
    // holds through every stance, so a squad in mixed stances reads as one row of
    // labels rather than a staircase.
    _obj modelToWorldVisual [0, 0, MAN_TAG_TOP]
} else {
    // unitAimPositionVisual resolves through the crew's aim point and returns []
    // for a vehicle that has none to offer — an empty hull, or any vehicle in the
    // frames between Zeus creating it and its crew being moved in. Fall back to
    // the model's bounding-box top centre.
    private _aim = unitAimPositionVisual _obj;
    if (count _aim >= 3) then {
        _aim
    } else {
        // Model-space top, MEMOIZED PER CLASS. Only crewless VEHICLES reach this
        // now — a vehicle's box is a real model fit, not the generic CAManBase
        // one the header dissects, and a hull has no stance to quantize it by.
        // (Unverified for animated hulls: a ramp or a raised turret could in
        // principle move it, and this memo would freeze the first state seen.
        // Cold path — worth re-measuring only if an empty hull's tag looks off.)
        private _class = typeOf _obj;
        private _top = GVAR(modelTopCache) get _class;

        if (isNil "_top") then {
            _top = MODEL_TOP(_obj);

            // A 0 is deliberately NOT stored. MODEL_TOP yields 0 rather than
            // throwing while the model has not resolved on this machine
            // (Gotchas §3) — the frames right after Zeus creates an object — and
            // caching that would pin every entity of the class to its own feet
            // for the rest of the mission. That is the same unresolved-model
            // frame the `count < 3` test at the bottom already absorbs, except
            // cached it would be permanent instead of lasting one frame.
            if (_top > 0) then {
                GVAR(modelTopCache) set [_class, _top];
            };
        };

        _obj modelToWorldVisual [0, 0, _top]
    }
};

[[], _pos] select (count _pos >= 3)
