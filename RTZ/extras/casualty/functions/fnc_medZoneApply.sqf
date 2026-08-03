#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER handler for QGVAR(zoneApply) (registered in XEH_postInit). Maintains the
 * authoritative, owner-scoped medical-zone registry that FUNC(findSafeZone) reads.
 *
 * GVAR(medZones): HashMap  id -> [pos2D, radius, ownerCuratorNetId]
 *
 * Arguments:
 * 0: "add" or "remove" <STRING>
 * 1: Zone id — same string as the owner's local marker name <STRING>
 * for "add":
 * 2: Zone position [x,y] <ARRAY>
 * 3: Zone radius (m) <NUMBER>
 * 4: Owner curator logic netId <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * ["add", _id, _pos2D, _radius, _ownerId] call rtz_casualty_fnc_medZoneApply
 *
 * Public: No
 */

params ["_action", "_id"];
if (!isServer) exitWith {};

switch (_action) do {
    case "add": {
        _this params ["", "", "_zpos", "_zradius", "_owner"];
        GVAR(medZones) set [_id, [_zpos, _zradius, _owner]];
    };
    case "remove": {
        GVAR(medZones) deleteAt _id;
    };
};
