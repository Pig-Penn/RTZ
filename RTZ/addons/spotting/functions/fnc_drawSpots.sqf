#include "script_component.hpp"
/*
 * Author: Maxim
 * RENDER_WORLD renderer for the spotting picture: group icons (pass 1, each on a
 * stem down to its leader as the basegame's own Zeus icons are) and individual
 * chevrons (pass 2) above spotted enemies in the Zeus cursor view.
 * Positions are sampled live from the unit each frame so icons track smoothly
 * between the server's spot cycles; texture, colour, echelon amplifier, side
 * index and display name are all pre-resolved server-side.
 *
 * Lives in this component because this component owns the DATA: FUNC(spotCheck)
 * decides what is spotted and FUNC(spottingClient) keeps the stores below
 * current. It used to sit in rtz_hud on the reasoning that rtz_hud owns every
 * display — but reading seven of this component's globals from over there made
 * the two addons mutually dependent (rtz_spotting required rtz_hud to register
 * the renderer, rtz_hud needed rtz_spotting's stores to run it) while only one
 * direction was ever declared, leaving their load order undefined. rtz_supply
 * and rtz_mine already own their own renderers; this follows them.
 *
 * Registered with EFUNC(core,frameLoop), which resolves the Zeus test, the camera
 * position and the mouse position once for every display — this pass does no
 * camera query of its own, and is skipped entirely while the Zeus map is up.
 *
 * Distance/size tunables (WEDGE_MAX_DIST, CHEVRON_MAX_DIST, CHEVRON_W_NEAR/FAR,
 * HOVER_MAX_DIST, HOVER_HIT_R2, GROUP_HOVER_R2, AMP_GAPS_WORLD, GROUP_ZMOD_*) are
 * #defined in script_component.hpp.
 *
 * Arguments:
 * 0: Frame context, see the CTX_* indices in script_component.hpp <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * _ctx call rtz_spotting_fnc_drawSpots
 *
 * Public: No
 */

params ["_ctx"];

private _groups   = GVAR(spotGroups);
private _chevrons = GVAR(spotChevrons);
// Empty-store test first: cheapest check and the common case on a quiet mission.
if (count _groups == 0 && { count _chevrons == 0 }) exitWith {};

private _camPos   = _ctx select CTX_CAMPOS;
private _mousePos = _ctx select CTX_MOUSE;
private _viewDist = _ctx select CTX_VIEWDIST;

// Blink state, hoisted out of the per-icon colour blocks below: `time` is read once per
// frame instead of once per icon, and the map is empty except in the moments right
// after a spotted unit fires — so _anyBlink lets the common case skip the per-icon
// lookup outright.
private _blinkUntil = GVAR(blinkUntil);
private _now        = time;
private _anyBlink   = count _blinkUntil > 0;

// Echelon amplifier vertical gap above the group icon, indexed by the payload's
// side index (0 = BLUFOR rectangle, 1 = OPFOR diamond — peaks highest so needs
// the most lift, 2 = independent/civilian square). World-space fraction scaled by
// camera distance (constant screen gap at any zoom).
private _AMP_GAPS = AMP_GAPS_WORLD;

// Hoisted once per frame: is anything actually under remote control? Testing only
// that the map EXISTS made this true whenever the RC indicator is merely enabled,
// so every chevron paid a netId + hashmap lookup every frame for nothing.
// Plain read, no default: this component's preInit creates the store unconditionally
// on every interface machine. It used to carry a `createHashMap` default for the
// case where the RC system is switched off — and SQF evaluates that argument
// eagerly, so it built and threw away a hashmap on every frame of every curator's
// session, whether or not the store existed.
private _rcDisplay = GVAR(rcDisplay);
private _hasRC     = count _rcDisplay > 0;

// The distance fade × stored base alpha, with a white flash while the unit is firing,
// is spelled INLINE in both passes below rather than factored into a `_fnc_drawColor`
// helper. It is four lines duplicated once, and it runs per icon per frame on every
// curator's machine — a `call` there buys a fresh scope and a `params` destructure per
// icon per frame for nothing, which is the same cost pass 2 already refuses to pay for
// its size ramp (see the linearConversion note there). The two copies are kept
// deliberately identical; change one, change the other.

// ── Pass 1: group icons ─────────────────────────────────────────────────────
// Also records which group leaders the mouse is currently near, so pass 2 can
// reveal that group's chevrons past the cutoff. The hover test only feeds pass 2 —
// with no chevrons stored, skip the per-icon worldToScreen entirely.
private _chevronsEnabled = GVAR(chevronsEnabled);
private _anyChevrons     = _chevronsEnabled && {count _chevrons > 0};
// Built unconditionally, even though only pass 2 reads it and only under _anyChevrons.
// Making it conditional would save one small map allocation per frame and leave a
// possibly-nil private in a renderer — and a nil read aborts the whole enclosing scope
// (Gotchas §2), which here means silently dropping every remaining icon for the frame.
// That is a poor trade for one allocation: the costs this component is written to avoid
// are per-ENTITY-per-frame, not per-frame.
private _groupHoverByLeader = createHashMap;
{
    // _x = markerName (HashMap key); _y = stored display data.
    _y params ["_unit", "_texture", "_colorArray", "_echelonTex", "_sideIdx", "_ldrId"];

    if (!alive _unit) then { continue };   // alive objNull is false — covers deleted units too
    // Anchor on the vehicle so a mounted leader is handled (vehicle = unit on foot).
    private _anchor = vehicle _unit;
    // `distance` throws a Generic error on a null object, and a runtime error
    // ABORTS THE WHOLE forEach — so a single bad entry costs every icon after it
    // in the store, not just its own. `alive` does not cover this: it is false for
    // objNull, but a live unit can still resolve to a null vehicle.
    if (isNull _anchor) then { continue };
    private _dist   = _camPos distance _anchor;
    // Past view distance the fade alpha is 0 — there was never anything to see, so
    // skip the icon (and its hover worldToScreen) rather than issue invisible
    // draws. Group icons, unlike chevrons, have no cutoff of their own.
    if (_dist >= _viewDist) then { continue };

    // Native Zeus group-icon recipe: world-space height offset grows with camera
    // distance (GROUP_ZMOD_MIN→MAX over GROUP_ZMOD_NEAR→FAR m, floored close in),
    // holding a roughly constant screen gap above the unit as you zoom. Aim pos
    // from the VEHICLE, not the crewman (else it skews out along the gun).
    private _zMod = linearConversion [GROUP_ZMOD_NEAR, GROUP_ZMOD_FAR, _dist, GROUP_ZMOD_MIN, GROUP_ZMOD_MAX, true];
    if (_dist >= GROUP_ZMOD_NEAR) then { _zMod = _zMod * GROUP_ZMOD_FLOOR_SCALE };
    // unitAimPositionVisual returns [] for a vehicle with no crew aim point to
    // resolve through (empty hull, or the frames before Zeus moves its crew in),
    // and [] vectorAdd [...] stays [] — fall back to the bounding-box top centre.
    // That fallback returns [] as well while the model has not resolved on this
    // machine (the frames right after Zeus creates the object), so re-test: every
    // draw below would be an invisible no-op on an [] position anyway.
    private _aim = unitAimPositionVisual _anchor;
    if (count _aim < 3) then {
        private _top = ((boundingBoxReal _anchor) param [1, []]) param [2, 0];
        _aim = _anchor modelToWorldVisual [0, 0, _top];
    };
    if (count _aim < 3) then { continue };
    private _iconPos = _aim vectorAdd [0, 0, _zMod];
    // Size amplifier lifted in world space (drawIcon3D offsetY is clamped); scaled
    // by _dist (not _zMod, which floors close up) for a constant screen gap. Each
    // side's frame peaks at a different height, so the gap comes from the per-side
    // table above via the payload's side index.
    private _ampPos = _iconPos vectorAdd [0, 0, _dist * (_AMP_GAPS select _sideIdx)];
    private _iconW  = GROUP_ICON_WIDTH;

    if (_anyChevrons) then {
        private _scr = worldToScreen _iconPos;
        if (_scr isNotEqualTo []) then {
            private _dx = (_scr#0) - (_mousePos#0);
            private _dy = (_scr#1) - (_mousePos#1);
            if ((_dx * _dx) + (_dy * _dy) <= GROUP_HOVER_R2) then {
                _groupHoverByLeader set [_ldrId, true];
            };
        };
    };

    // Distance fade × stored base alpha (_dist >= _viewDist is skipped above), flashing
    // white while the unit is firing. Inlined — see the note above pass 1.
    private _alpha = ((_viewDist - _dist) / _viewDist) * (_colorArray#3);
    private _col = if (_anyBlink && {_now <= (_blinkUntil getOrDefault [_x, 0])})
        then { [1, 1, 1, _alpha] }
        else { [_colorArray#0, _colorArray#1, _colorArray#2, _alpha] };
    // Native Zeus stem. The icon floats _zMod above the leader, so on its own it
    // reads as hanging over whatever terrain happens to be under it — from a
    // shallow camera angle that can be a hillside a hundred metres behind the
    // group. The line back down to the body says which unit the icon is for.
    //
    // Black rather than the side colour, as the basegame draws it: a red stem
    // over dry Altis terrain is nearly invisible, and black reads against both
    // sky and ground. Alpha is lifted straight off _col so the stem fades with
    // the icon in step — including the white muzzle-flash blink, which changes
    // only the RGB.
    //
    // Drawn BEFORE the icon so the frame covers the point where the line meets
    // it; the path renderer's air stalk lands on its handle icon the same way.
    drawLine3D [_iconPos, _aim, [0, 0, 0, _col select 3]];
    drawIcon3D [_texture, _col, _iconPos, _iconW, _iconW, 0, "", 0, 0.03, "RobotoCondensed", "center", false, 0, -0.035];
    if (_echelonTex != "") then {
        drawIcon3D [_echelonTex, _col, _ampPos, _iconW, _iconW, 0, "", 0, 0.03, "RobotoCondensed", "center", false, 0, -0.035];
    };
} forEach _groups;

// ── Pass 2: individual chevrons ─────────────────────────────────────────────
// Skipped entirely while chevrons are toggled off (FUNC(toggleChevrons)) —
// group icons above are unaffected.
if (!_chevronsEnabled) exitWith {};

private _chevronNames = GVAR(chevronNames);
{
    _y params ["_unit", "_texture", "_colorArray", "_ldrId", "_name", "_unitId"];

    if (!alive _unit) then { continue };
    private _anchor = vehicle _unit;
    if (isNull _anchor) then { continue };   // see the group pass above
    private _dist   = _camPos distance _anchor;
    if (_dist > WEDGE_MAX_DIST || {_dist >= _viewDist}) then { continue };

    // Past the normal cutoff, only show this chevron if its group's icon is
    // currently hovered — lets the curator "peek" at squad composition from afar.
    // Leader netId is pre-resolved server-side, so no group traversal per frame.
    if (_dist > CHEVRON_MAX_DIST && {!(_groupHoverByLeader getOrDefault [_ldrId, false])}) then { continue };

    // Suppress chevron when the RC indicator is already showing for this unit.
    // The netId is carried in the payload (pre-resolved server-side, where it is already
    // the unit half of the spot key) rather than re-derived here: `netId` is an engine
    // call, and this ran once per chevron per frame for every curator whenever anything
    // at all was under remote control.
    if (_hasRC && {_unitId in _rcDisplay}) then { continue };

    // Native EG-spectator chevron (ACE recipe): head + 1 m, size scaled by
    // distance. Smooth ramp rather than a stepped table — same endpoints, one
    // engine call, and no per-chevron `call {}` scope per frame.
    private _iconPos = (_unit modelToWorldVisual ([_unit] call EFUNC(common,headOffset))) vectorAdd [0, 0, 1];
    // modelToWorldVisual returns [] while the model has not resolved on this
    // machine — the handful of frames after Zeus places a unit — and
    // [] vectorAdd [...] stays []. drawIcon3D would then silently draw nothing
    // and worldToScreen below would throw, aborting the scope and dropping
    // every REMAINING chevron this frame. The group pass above guards the same
    // way (Gotchas §3).
    if (count _iconPos < 3) then { continue };

    private _iconW   = linearConversion [0, WEDGE_MAX_DIST, _dist, CHEVRON_W_NEAR, CHEVRON_W_FAR, true];

    // Inlined twin of the group pass's fade/blink block — see the note above pass 1.
    private _alpha = ((_viewDist - _dist) / _viewDist) * (_colorArray#3);
    private _col = if (_anyBlink && {_now <= (_blinkUntil getOrDefault [_x, 0])})
        then { [1, 1, 1, _alpha] }
        else { [_colorArray#0, _colorArray#1, _colorArray#2, _alpha] };
    drawIcon3D [_texture, _col, _iconPos, _iconW, _iconW, 0, "", 0, 0.03, "RobotoCondensed", "center", false, 0, 0];

    if (_chevronNames && {_dist <= HOVER_MAX_DIST}) then {
        private _scr = worldToScreen _iconPos;
        if (_scr isNotEqualTo []) then {
            private _dx = (_scr#0) - (_mousePos#0);
            private _dy = (_scr#1) - (_mousePos#1);
            if ((_dx * _dx) + (_dy * _dy) <= HOVER_HIT_R2) then {
                // Display name pre-resolved server-side — no configOf per frame.
                drawIcon3D ["", _col, _iconPos vectorAdd [0, 0, 0.6], 0, 0, 0, _name, 1, 0.025, "RobotoCondensed", "center", false, 0, 0];
            };
        };
    };
} forEach _chevrons;
