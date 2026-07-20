#include "script_component.hpp"
/*
 * Author: Maxim
 * Per-frame Draw3D renderer for the spotting system: draws the group icons
 * (pass 1) and individual chevrons (pass 2) above spotted enemies in the Zeus
 * cursor view. Positions are sampled live from the unit each frame so icons
 * track smoothly between the server's spot cycles; texture, colour, echelon
 * amplifier, side index and display name are all pre-resolved server-side.
 *
 * Registered as a mission Draw3D event handler by FUNC(spottingClient).
 * Distance/size tunables (WEDGE_MAX_DIST, CHEVRON_MAX_DIST, HOVER_MAX_DIST,
 * HOVER_HIT_R2, GROUP_HOVER_R2, AMP_GAPS_WORLD, GROUP_ZMOD_*) are #defined in
 * script_component.hpp.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * addMissionEventHandler ["Draw3D", {call rtz_spotting_fnc_draw3D}]
 *
 * Public: No
 */

// Only while the Zeus interface is open — these are curator-view icons, so they must
// not bleed into first person / map when the curator display (312) is closed.
if (isNull (findDisplay 312)) exitWith {};
if (count GVAR(spotGroups) == 0 && { count GVAR(spotChevrons) == 0 }) exitWith {};
private _camPos   = positionCameraToWorld [0,0,0];   // Zeus cursor camera, for fade
private _viewDist = getObjectViewDistance select 0;
// HOVER_HIT_R2 / GROUP_HOVER_R2 are SafeZone screen-space radii (worldToScreen
// format), compared SQUARED so the per-icon test needs no sqrt.
private _mousePos = getMousePosition;

// Echelon amplifier vertical gap above the group icon, indexed by the payload's
// side index (0 = BLUFOR rectangle, 1 = OPFOR diamond — peaks highest so needs
// the most lift, 2 = independent/civilian square). World-space fraction scaled
// by camera distance (constant screen gap at any zoom).
private _AMP_GAPS = AMP_GAPS_WORLD;

// Hoisted once per frame: does the RC-indicator display map exist at all?
private _hasRC = !isNil QGVAR(rcDisplay);

// Distance fade × stored base alpha; flash white while the unit is firing.
private _fnc_drawColor = {
    params ["_dist", "_colorArray", "_blinkKey"];
    private _alpha = (((_viewDist - _dist) / _viewDist) max 0) * (_colorArray#3);
    if (time <= (GVAR(blinkUntil) getOrDefault [_blinkKey, 0]))
        then { [1, 1, 1, _alpha] }
        else { [_colorArray#0, _colorArray#1, _colorArray#2, _alpha] }
};

// ── Pass 1: group icons. Also records which group leaders the mouse is
// currently near, so pass 2 can reveal that group's chevrons past the cutoff.
// The hover test only feeds pass 2 — with no chevrons stored, skip the
// per-icon worldToScreen entirely.
private _anyChevrons        = GVAR(chevronsEnabled) && { count GVAR(spotChevrons) > 0 };
private _groupHoverByLeader = createHashMap;
{
    // _x = markerName (HashMap key); _y = stored display data.
    _y params ["_unit", "_texture", "_colorArray", "_echelonTex", "_sideIdx", "_ldrId"];
    if (!alive _unit) then { continue };   // alive objNull is false — covers deleted units too
    // Anchor on the vehicle so a mounted leader is handled (vehicle = unit on foot).
    private _anchor = vehicle _unit;
    private _dist   = _camPos distance _anchor;

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
} forEach GVAR(spotGroups);

// ── Pass 2: individual chevrons. Skipped entirely while GVAR(chevronsEnabled)
// is off (context-menu toggle, FUNC(toggleChevrons)) — group icons above are
// unaffected.
if (GVAR(chevronsEnabled)) then {
    {
        _y params ["_unit", "_texture", "_colorArray", "_ldrId", "_name"];
        if (!alive _unit) then { continue };
        private _anchor = vehicle _unit;
        private _dist   = _camPos distance _anchor;
        if (_dist > WEDGE_MAX_DIST) then { continue };

        // Past the normal cutoff, only show this chevron if its group's icon is
        // currently hovered — lets the curator "peek" at squad composition from afar.
        // Leader netId is pre-resolved server-side, so no group traversal per frame.
        if (_dist > CHEVRON_MAX_DIST && { !(_groupHoverByLeader getOrDefault [_ldrId, false]) }) then { continue };

        // Suppress chevron when the RC indicator is already showing for this unit.
        if (_hasRC && { (netId _unit) in GVAR(rcDisplay) }) then { continue };

        // Native EG-spectator chevron (ACE recipe): head + 1 m, size scaled by distance.
        private _iconPos = (_unit modelToWorldVisual (_unit selectionPosition "Head")) vectorAdd [0, 0, 1];
        private _iconW = call {
            if (_dist <= 500)  exitWith { 4 };
            if (_dist <= 1000) exitWith { 3.5 };
            if (_dist <= 1500) exitWith { 3 };
            if (_dist <= 2000) exitWith { 2.5 };
            if (_dist <= 2500) exitWith { 2 };
            1.5
        };

        private _col = [_dist, _colorArray, _x] call _fnc_drawColor;
        drawIcon3D [_texture, _col, _iconPos, _iconW, _iconW, 0, "", 0, 0.03, "RobotoCondensed", "center", false, 0, 0];

        if (GVAR(chevronNames) && { _dist <= HOVER_MAX_DIST }) then {
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
    } forEach GVAR(spotChevrons);
};
