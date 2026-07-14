#include "script_component.hpp"
/*
 * rtz_fnc_spottingClient
 *
 * Client half of the spotting system: per-player icon stores, the per-frame
 * Draw3D renderer, the CBA event receivers (spotDetected / spotLost /
 * spotAlert / blink), the Zeus map overlay attach fallback, and the JIP
 * resync request.
 *
 * No hasInterface guard here — per the ZEN guard convention this is only
 * reachable from FUNC(spottingSystem), which forks on hasInterface before
 * calling in.
 *
 * Called by: FUNC(spottingSystem) (client machines, once CBA settings init).
 */

// Per-player storage, split by marker kind so the per-frame draw passes and
// the Zeus map overlay iterate exactly the entries they render — no flag
// filtering per entry per frame. Sizes/positions are computed client-side
// each frame. Set by QGVAR(spotDetected); cleared by QGVAR(spotLost).
//   GVAR(spotGroups):   markerName → [unit, texture, colorArray, echelonTex, sideIdx, leaderNetId]
//   GVAR(spotChevrons): markerName → [unit, texture, colorArray, leaderNetId, displayName]
//   GVAR(officerZones): markerName → [unit, radius] — subset of spotChevrons entries
//     whose unit is an enemy officer carrying an active editing-area zone
//     (radius comes from rtz_officer's RTZ_officerZoneRadiusMap, piggybacked
//     on the wedge payload — see QGVAR(spotDetected) below). Drawn as a
//     hollow ring on the Zeus map by FUNC(initCuratorDisplay).
GVAR(spotGroups)   = createHashMap;
GVAR(spotChevrons) = createHashMap;
GVAR(officerZones) = createHashMap;

// Runtime visibility switch for the officer-zone ring overlay. Data keeps
// flowing either way — it rides free on the existing spot payload — this only
// gates the map draw. No UI toggles it yet; flip it from the debug console.
GVAR(officerZonesVisible) = true;

// markerName → time until which the icon flashes white (set by QGVAR(blink) when the
// spotted unit fires). Only wedge markers ever receive blinks.
GVAR(blinkUntil) = createHashMap;

// Guard for the per-unit hover name display. Initialized here so the Draw3D
// handler (which runs every frame) never sees nil and throws a type error.
// Fallback matches the registered CBA setting default (false); CBA overwrites
// it with the real synced value once settings initialize.
if (isNil QGVAR(chevronNames)) then { GVAR(chevronNames) = false };

// Diagnostic: confirm the client half actually ran on this machine (set
// RTZ_debug = true in the console to enable; default off, zero cost otherwise).
if (GETMVAR(RTZ_debug,false)) then {
    diag_log text format ["[RTZ] spotting CLIENT half started (clientOwner=%1, hasInterface=%2)", clientOwner, hasInterface];
};

// Draw 3D world icons above each spotted enemy every frame; positions are sampled
// live from the unit so icons track smoothly between the server's spot cycles.
addMissionEventHandler ["Draw3D", {
    // Only while the Zeus interface is open — these are curator-view icons, so they must
    // not bleed into first person / map when the curator display (312) is closed.
    if (isNull (findDisplay 312)) exitWith {};
    if (count GVAR(spotGroups) == 0 && { count GVAR(spotChevrons) == 0 }) exitWith {};
    private _camPos   = positionCameraToWorld [0,0,0];   // Zeus cursor camera, for fade
    private _viewDist = getObjectViewDistance select 0;
    // Absolute outer cap on chevrons — never shown beyond this regardless of hover.
    // Matches the top of the wedge size table. Tune 2500.
    private _WEDGE_MAX_DIST     = 2500;
    // Normal chevron display range; past this a group's chevrons hide and only its
    // group icon remains, UNLESS the mouse is hovering near that group icon (below).
    private _CHEVRON_MAX_DIST   = 500;
    // Hover tooltip: show a chevron's unit display name (Rifleman, Marksman, …) when
    // the curator's mouse is in its general vicinity AND the camera is close enough
    // to be looking at it up close, not just passing the cursor over a distant cluster.
    // Radii are in SafeZone screen-space units (worldToScreen format), compared
    // SQUARED so the per-icon test needs no sqrt.
    private _HOVER_MAX_DIST     = 50;              // metres, camera → unit
    private _HOVER_HIT_R2       = 0.05 * 0.05;     // loose "vicinity" test, tune in-game
    // Vicinity test for "hover near the group icon" — reveals that group's chevrons past _CHEVRON_MAX_DIST.
    private _GROUP_HOVER_R2     = 0.05 * 0.05;
    private _mousePos = getMousePosition;

    // Echelon amplifier vertical gap above the group icon, indexed by the payload's
    // side index (0 = BLUFOR rectangle, 1 = OPFOR diamond — peaks highest so needs
    // the most lift, 2 = independent/civilian square). World-space fraction scaled
    // by camera distance (constant screen gap at any zoom). Tune per side in-game.
    private _AMP_GAPS = [0.002, 0.006, 0.004];

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
    private _groupHoverByLeader = createHashMap;
    {
        // _x = markerName (HashMap key); _y = stored display data.
        _y params ["_unit", "_texture", "_colorArray", "_echelonTex", "_sideIdx", "_ldrId"];
        if (isNull _unit || !alive _unit) then { continue };
        // Anchor on the vehicle so a mounted leader is handled (vehicle = unit on foot).
        private _anchor = vehicle _unit;
        private _dist   = _camPos distance _anchor;

        // Native Zeus group-icon recipe: world-space height offset grows with camera
        // distance (5→20 m over 180→360 m, floored close in), holding a roughly constant
        // screen gap above the unit as you zoom. Aim pos from the VEHICLE, not the
        // crewman (else it skews out along the gun).
        private _zMod = linearConversion [180, 360, _dist, 5, 20, true];
        if (_dist >= 180) then { _zMod = _zMod * 0.88 };
        private _iconPos = (unitAimPositionVisual _anchor) vectorAdd [0, 0, _zMod];
        // Size amplifier lifted in world space (drawIcon3D offsetY is clamped); scaled
        // by _dist (not _zMod, which floors close up) for a constant screen gap. Each
        // side's frame peaks at a different height, so the gap comes from the per-side
        // table above via the payload's side index.
        private _ampPos = _iconPos vectorAdd [0, 0, _dist * (_AMP_GAPS select _sideIdx)];
        private _iconW  = 1.3;

        private _scr = worldToScreen _iconPos;
        if (_scr isNotEqualTo []) then {
            private _dx = (_scr#0) - (_mousePos#0);
            private _dy = (_scr#1) - (_mousePos#1);
            if ((_dx * _dx) + (_dy * _dy) <= _GROUP_HOVER_R2) then {
                _groupHoverByLeader set [_ldrId, true];
            };
        };

        private _col = [_dist, _colorArray, _x] call _fnc_drawColor;
        drawIcon3D [_texture, _col, _iconPos, _iconW, _iconW, 0, "", 0, 0.03, "RobotoCondensed", "center", false, 0, -0.035];
        if (_echelonTex != "") then {
            drawIcon3D [_echelonTex, _col, _ampPos, _iconW, _iconW, 0, "", 0, 0.03, "RobotoCondensed", "center", false, 0, -0.035];
        };
    } forEach GVAR(spotGroups);

    // ── Pass 2: individual chevrons.
    {
        _y params ["_unit", "_texture", "_colorArray", "_ldrId", "_name"];
        if (isNull _unit || !alive _unit) then { continue };
        private _anchor = vehicle _unit;
        private _dist   = _camPos distance _anchor;
        if (_dist > _WEDGE_MAX_DIST) then { continue };

        // Past the normal cutoff, only show this chevron if its group's icon is
        // currently hovered — lets the curator "peek" at squad composition from afar.
        // Leader netId is pre-resolved server-side, so no group traversal per frame.
        if (_dist > _CHEVRON_MAX_DIST && { !(_groupHoverByLeader getOrDefault [_ldrId, false]) }) then { continue };

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

        if (GVAR(chevronNames) && { _dist <= _HOVER_MAX_DIST }) then {
            private _scr = worldToScreen _iconPos;
            if (_scr isNotEqualTo []) then {
                private _dx = (_scr#0) - (_mousePos#0);
                private _dy = (_scr#1) - (_mousePos#1);
                if ((_dx * _dx) + (_dy * _dy) <= _HOVER_HIT_R2) then {
                    // Display name pre-resolved server-side — no configOf per frame.
                    drawIcon3D ["", _col, _iconPos vectorAdd [0, 0, 0.6], 0, 0, 0, _name, 1, 0.025, "RobotoCondensed", "center", false, 0, 0];
                };
            };
        };
    } forEach GVAR(spotChevrons);
}];

// Store/update icon data for a spotted enemy. Texture, colour, echelon amplifier,
// side index, group-leader netId and display name are all pre-resolved on the server.
[QGVAR(spotDetected), {
    params ["_markerName", "_unit", "_texture", "_colorArray", "_isGroupMarker", "_echelonTex", "_sideIdx", "_ldrId", "_name", ["_zoneRadius", 0]];
    if (_isGroupMarker) then {
        // Diagnostic: log the first receipt of each marker so we can confirm the
        // server's targeted event is actually reaching THIS client (RTZ_debug).
        if ((GETMVAR(RTZ_debug,false)) && {!(_markerName in GVAR(spotGroups))}) then {
            diag_log text format ["[RTZ] client received spotDetected: %1 (group=true)", _markerName];
        };
        GVAR(spotGroups) set [_markerName, [_unit, _texture, _colorArray, _echelonTex, _sideIdx, _ldrId]];
    } else {
        if ((GETMVAR(RTZ_debug,false)) && {!(_markerName in GVAR(spotChevrons))}) then {
            diag_log text format ["[RTZ] client received spotDetected: %1 (group=false)", _markerName];
        };
        GVAR(spotChevrons) set [_markerName, [_unit, _texture, _colorArray, _ldrId, _name]];
        // Officer zone ring: only wedge (individually-identified) entries ever
        // carry a non-zero radius (see the server's _chevronData build). A
        // radius dropping to 0 (area removed while still spotted) clears it
        // the same tick, since the sig embeds the radius and forces a resend.
        if (_zoneRadius > 0) then {
            GVAR(officerZones) set [_markerName, [_unit, _zoneRadius]];
        } else {
            GVAR(officerZones) deleteAt _markerName;
        };
    };
}] call CBA_fnc_addEventHandler;

// Remove 3D icon when the enemy is no longer spotted. Group and chevron
// marker names never collide ("s_"/"w_" key prefixes), so deleting from
// both maps is a safe single-hit.
[QGVAR(spotLost), {
    params ["_markerName"];
    GVAR(spotGroups)   deleteAt _markerName;
    GVAR(spotChevrons) deleteAt _markerName;
    GVAR(officerZones) deleteAt _markerName;
    GVAR(blinkUntil)   deleteAt _markerName;
}] call CBA_fnc_addEventHandler;

// Contact report spoken by the spotting unit — fired by the server with a CBA
// targeted event so it runs only on this curator's machine. sideChat is local:
// the line appears in this player's side channel as "<groupId>: <message>".
[QGVAR(spotAlert), {
    params ["_reporter", "_message"];
    if (isNull _reporter) exitWith {};
    _reporter sideChat _message;
}] call CBA_fnc_addEventHandler;

// Flash a wedge white for a moment — fired by the server when the spotted unit shoots.
[QGVAR(blink), {
    params ["_markerName"];
    GVAR(blinkUntil) set [_markerName, time + 0.15];
}] call CBA_fnc_addEventHandler;

// Zeus map overlay: normally attached by FUNC(initCuratorDisplay) via the XEH
// DisplayLoad event each time the curator display is created. If Zeus is somehow
// already open when this client half starts (late settings init), attach now.
private _curatorDisplay = findDisplay 312;
if (!isNull _curatorDisplay) then {
    [_curatorDisplay] call FUNC(initCuratorDisplay);
};

// Handlers are registered — ask the server to force-resend every active spot on
// its next tick. Covers JIP/rejoin where sig-gated sends happened before this
// machine could listen. (Harmless no-op at mission start: nothing is active yet.)
[QGVAR(spotResync), []] call CBA_fnc_serverEvent;
