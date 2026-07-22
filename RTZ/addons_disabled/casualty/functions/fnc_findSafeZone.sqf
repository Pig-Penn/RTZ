#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER helper: is a position a valid evacuation point for this casualty? Used by
 * FUNC(manageCasualties) to decide when a loaded casualty has been delivered.
 *
 * A position qualifies if ANY of (zero mission setup required for 1-2):
 *   1. within GVAR(deliverRadius) of a living, friendly HQ unit — reusing the shared
 *      HQ heuristic from EFUNC(common,classInfo) (its 3rd element = "is an HQ/officer
 *      class"). Side-based, shared by all friendly casualties.
 *   2. within a global map marker whose name begins "rtz_safezone" (radius = the larger
 *      of GVAR(deliverRadius) and the marker's own size) — a mission maker's explicit,
 *      shared field hospital dropped in the editor.
 *   3. within a curator's "Medical Zone" module (GVAR(medZones)) whose owner matches
 *      THIS casualty's owning curator — a private field hospital, usable only by its
 *      owner's own casualties (see FUNC(placeMedicalZone) / FUNC(medZoneApply)).
 *
 * Arguments:
 * 0: Position [x,y,z] (the medical vehicle's position) <ARRAY>
 * 1: The casualty's side — safe zone must be friendly to it <SIDE>
 * 2: The casualty's owning curator netId ("" if none) <STRING> (optional)
 *
 * Return Value:
 * True if the position is a valid evacuation point <BOOLEAN>
 *
 * Example:
 * [_pos, _side, _ownerId] call rtz_casualty_fnc_findSafeZone
 *
 * Public: No
 */

params ["_pos", "_side", ["_ownerId", ""]];
private _r = GETGVAR(deliverRadius,40);

// 1) Friendly HQ unit nearby.
private _hit = (allUnits select { alive _x && {(_side getFriend side _x) >= 0.6} }) findIf {
    (_x distance2D _pos < _r) && { ([_x] call EFUNC(common,classInfo)) select 2 }
};
if (_hit != -1) exitWith { true };

// 2) A designated (shared) safe-zone marker.
private _found = false;
{
    if ((_x select [0, 12]) == "rtz_safezone") then {
        private _mr = _r max ((markerSize _x) select 0);
        if ((getMarkerPos _x) distance2D _pos < _mr) exitWith { _found = true };
    };
} forEach allMapMarkers;
if (_found) exitWith { true };

// 3) One of this casualty's own curator's Medical Zone modules.
if (_ownerId == "") exitWith { false };
{
    _y params ["_zpos", "_zr", "_zowner"];
    if (_zowner == _ownerId && {_zpos distance2D _pos < _zr}) exitWith { _found = true };
} forEach (GETGVAR(medZones,createHashMap));
_found
