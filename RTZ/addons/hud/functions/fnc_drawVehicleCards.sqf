#include "script_component.hpp"
/*
 * Author: Maxim
 * RENDER_UI renderer for the bottom-right vehicle stat cards. Called once per
 * frame by EFUNC(core,frameLoop) with the curator display — or displayNull when Zeus is
 * closed or this player is not a curator, which is what drives the teardown
 * below.
 *
 * Runs even while the Zeus MAP is open: these are controls on the curator
 * display, which the map does not cover, unlike the 3D link lines
 * (FUNC(drawVehicleLinks)) that the world pass drops in that state.
 *
 * Also publishes GVAR(vehicleRenderList) — the packet/alive/side-filtered set for
 * this frame — which the link renderer reuses instead of re-filtering.
 *
 * Arguments:
 * 0: Curator display, or displayNull <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * _display call rtz_hud_fnc_drawVehicleCards
 *
 * Public: No
 */

params ["_disp"];

// Zeus closed or curator lost — the controls died with the display; just drop our
// references. Once only: while Zeus stays closed this must not keep rewriting
// uiNamespace every frame.
if (isNull _disp) exitWith {
    GVAR(vehicleRenderList) = [];
    if ((GETUVAR(GVAR(veh_pool),[])) isNotEqualTo []) then {
        uiNamespace setVariable [QGVAR(veh_pool),    []];
        uiNamespace setVariable [QGVAR(veh_disp),    displayNull];
        uiNamespace setVariable [QGVAR(veh_lastIds), []];
    };
};

// Display instance changed (Zeus reopened) — flush the stale pool.
if ((GETUVAR(GVAR(veh_disp),displayNull)) isNotEqualTo _disp) then {
    uiNamespace setVariable [QGVAR(veh_pool),    []];
    uiNamespace setVariable [QGVAR(veh_disp),    _disp];
    uiNamespace setVariable [QGVAR(veh_lastIds), []];
    GVAR(vehicleDataDirty) = true;
};

private _pool = GETUVAR(GVAR(veh_pool),[]);

// Nothing selected. Cards are hidden once on the transition; idle frames after
// that skip the pool sweep entirely.
if (EGVAR(core,selVehicles) isEqualTo []) exitWith {
    GVAR(vehicleRenderList) = [];
    if ((GETUVAR(GVAR(veh_lastIds),[])) isNotEqualTo []) then {
        { (_x select 0) ctrlShow false } forEach _pool;
        uiNamespace setVariable [QGVAR(veh_lastIds), []];
    };
};

private _ids = EGVAR(core,selVehicles) select [0, SEL_MAX_VEHICLES];
// A virtual Zeus (VirtualMan_F) is the game master, not a PvP officer — exempt
// from the own-side render filter (mirrors the selection poll and the server
// gather).
private _anySide = player isKindOf "VirtualMan_F";
private _curSide = side player;

// Renderable set this frame: packet arrived, vehicle alive, side OK. Published
// for the link renderer, which runs later in the same frame.
private _data = GVAR(vehicleData);
private _list = [];
{
    private _pkt = _data getOrDefault [_x, []];
    if (_pkt isEqualTo []) then { continue };
    private _veh = objectFromNetId _x;
    if (isNull _veh || {!alive _veh}) then { continue };
    if (!_anySide && {!(VEH_SIDE_OK(_veh,_curSide))}) then { continue };
    _list pushBack [_pkt, _veh];
} forEach _ids;
GVAR(vehicleRenderList) = _list;

// ---- cards: relayout only when data or the selected id set changed ----
if (!GVAR(vehicleDataDirty)
    && {_ids isEqualTo (GETUVAR(GVAR(veh_lastIds),[]))}) exitWith {};
GVAR(vehicleDataDirty) = false;
uiNamespace setVariable [QGVAR(veh_lastIds), _ids];

// ---- stack the cards upward from the bottom-right corner ----
private _rightX  = safeZoneX + safeZoneW - 0.021;
private _yCursor = safeZoneY + safeZoneH - 0.13;   // above the Zeus bottom bar
private _yLimit  = safeZoneY + 0.28;               // below the Zeus top bar
private _used    = 0;
private _full    = false;   // exitWith in a forEach block only skips the
                            // iteration, so out-of-room is a sticky flag

{
    if (_full) then { continue };
    _x params ["_pkt"];
    if (_used >= count _pool) then {
        _pool pushBack ([_disp] call FUNC(vehicleCardCreate));
    };
    private _bundle = _pool select _used;
    private _h = [_bundle, _pkt] call FUNC(vehicleCardLayout);
    // Out of screen room — stop. This card was laid out but never shown, and
    // _used was not advanced, so the trailing loop below hides it along with the
    // rest of the unused pool.
    if (_yCursor - _h < _yLimit) then { _full = true; continue };
    _yCursor = _yCursor - _h;
    private _grp = _bundle select 0;
    _grp ctrlSetPosition [_rightX - CARD_W, _yCursor, CARD_W, _h];
    _grp ctrlCommit 0;
    _grp ctrlShow true;
    _yCursor = _yCursor - CARD_GAP;
    _used = _used + 1;
} forEach _list;

for "_i" from _used to (count _pool) - 1 do {
    ((_pool select _i) select 0) ctrlShow false;
};
uiNamespace setVariable [QGVAR(veh_pool), _pool];
