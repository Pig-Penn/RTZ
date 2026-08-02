#include "script_component.hpp"
/*
 * Author: Maxim
 * RENDER_WORLD renderer for the spotting picture: group icons (pass 1) and
 * individual chevrons (pass 2) above spotted enemies in the Zeus cursor view.
 * Positions are sampled live from the unit each frame so icons track smoothly
 * between the server's spot cycles; texture, colour, echelon amplifier, side
 * index and display name are all pre-resolved server-side.
 *
 * The DATA is owned by rtz_spotting, which decides what is spotted and keeps the
 * client stores current; this component owns how it looks. Hence the EGVAR reads
 * below — they mark exactly where the detection/presentation seam runs. The
 * renderer is registered by rtz_spotting's client half, so it only ever runs when
 * those stores exist, and rtz_hud carries no dependency on rtz_spotting.
 *
 * Registered with FUNC(frameLoop), which resolves the Zeus test, the camera
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
 * _ctx call rtz_hud_fnc_drawSpots
 *
 * Public: No
 */

params ["_ctx"];

private _groups   = EGVAR(spotting,spotGroups);
private _chevrons = EGVAR(spotting,spotChevrons);
// Empty-store test first: cheapest check and the common case on a quiet mission.
if (count _groups == 0 && {count _chevrons == 0}) exitWith {};

private _camPos   = _ctx select CTX_CAMPOS;
private _mousePos = _ctx select CTX_MOUSE;
private _viewDist = _ctx select CTX_VIEWDIST;

// Blink state, hoisted out of _fnc_drawColor: `time` is read once per frame
// instead of once per icon, and the map is empty except in the moments right
// after a spotted unit fires — so the common case skips the per-icon lookup
// outright.
private _blinkUntil = EGVAR(spotting,blinkUntil);
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
private _rcDisplay = GETEGVAR(spotting,rcDisplay,createHashMap);
private _hasRC     = count _rcDisplay > 0;

// Distance fade × stored base alpha; flash white while the unit is firing.
private _fnc_drawColor = {
    params ["_dist", "_colorArray", "_blinkKey"];
    private _alpha = ((_viewDist - _dist) / _viewDist) * (_colorArray#3);   // callers skip _dist >= _viewDist
    if (_anyBlink && {_now <= (_blinkUntil getOrDefault [_blinkKey, 0])})
        then { [1, 1, 1, _alpha] }
        else { [_colorArray#0, _colorArray#1, _colorArray#2, _alpha] }
};

// ── Pass 1: group icons ─────────────────────────────────────────────────────
// Also records which group leaders the mouse is currently near, so pass 2 can
// reveal that group's chevrons past the cutoff. The hover test only feeds pass 2 —
// with no chevrons stored, skip the per-icon worldToScreen entirely.
private _chevronsEnabled    = EGVAR(spotting,chevronsEnabled);
private _anyChevrons        = _chevronsEnabled && {count _chevrons > 0};
private _groupHoverByLeader = createHashMap;
{
    // _x = markerName (HashMap key); _y = stored display data.
    _y params ["_unit", "_texture", "_colorArray", "_echelonTex", "_sideIdx", "_ldrId"];
    if (!alive _unit) then { continue };   // alive objNull is false — covers deleted units too
    // Anchor on the vehicle so a mounted leader is handled (vehicle = unit on foot).
    private _anchor = vehicle _unit;
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
    private _iconPos = (unitAimPositionVisual _anchor) vectorAdd [0, 0, _zMod];
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

    private _col = [_dist, _colorArray, _x] call _fnc_drawColor;
    drawIcon3D [_texture, _col, _iconPos, _iconW, _iconW, 0, "", 0, 0.03, "RobotoCondensed", "center", false, 0, -0.035];
    if (_echelonTex != "") then {
        drawIcon3D [_echelonTex, _col, _ampPos, _iconW, _iconW, 0, "", 0, 0.03, "RobotoCondensed", "center", false, 0, -0.035];
    };
} forEach _groups;

// ── Pass 2: individual chevrons ─────────────────────────────────────────────
// Skipped entirely while chevrons are toggled off (EFUNC(spotting,toggleChevrons)) —
// group icons above are unaffected.
if (!_chevronsEnabled) exitWith {};

private _chevronNames = EGVAR(spotting,chevronNames);
{
    _y params ["_unit", "_texture", "_colorArray", "_ldrId", "_name"];
    if (!alive _unit) then { continue };
    private _anchor = vehicle _unit;
    private _dist   = _camPos distance _anchor;
    if (_dist > WEDGE_MAX_DIST || {_dist >= _viewDist}) then { continue };

    // Past the normal cutoff, only show this chevron if its group's icon is
    // currently hovered — lets the curator "peek" at squad composition from afar.
    // Leader netId is pre-resolved server-side, so no group traversal per frame.
    if (_dist > CHEVRON_MAX_DIST && {!(_groupHoverByLeader getOrDefault [_ldrId, false])}) then { continue };

    // Suppress chevron when the RC indicator is already showing for this unit.
    if (_hasRC && {(netId _unit) in _rcDisplay}) then { continue };

    // Native EG-spectator chevron (ACE recipe): head + 1 m, size scaled by
    // distance. Smooth ramp rather than a stepped table — same endpoints, one
    // engine call, and no per-chevron `call {}` scope per frame.
    private _iconPos = (_unit modelToWorldVisual (_unit selectionPosition "Head")) vectorAdd [0, 0, 1];
    private _iconW   = linearConversion [0, WEDGE_MAX_DIST, _dist, CHEVRON_W_NEAR, CHEVRON_W_FAR, true];

    private _col = [_dist, _colorArray, _x] call _fnc_drawColor;
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
