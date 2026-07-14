#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER handler for QGVAR(applyArea) (registered in XEH_postInit). The BIS
 * curator logic is local to the server and add/removeCuratorEditingArea
 * require the curator to be local, so every engine call runs here — clients
 * dispatch via CBA_fnc_serverEvent (FUNC(setArea), FUNC(monitorAreas)).
 *
 * Alongside the engine calls it maintains GVAR(areasByCurator) — curatorNetId
 * -> HashMap(areaId -> officerNetId) — a registry of every RTZ-added area per
 * module. The registry is what makes "clear" possible: the engine has no
 * getter for a module's editing areas, and the per-CLIENT tracking map is
 * lost on disconnect, so without it a rejoined (or newly assigned) curator
 * would inherit orphaned areas that confine them with no way to remove them.
 * Area IDs are only unique per client, so the registry is always scoped by
 * curator — never keyed by areaId alone.
 *
 * It also keeps RTZ_officerZoneRadiusMap (officerNetId -> radius) in sync —
 * the cross-addon contract rtz_spotting reads to draw an enemy officer's zone
 * ring once that officer is individually spotted.
 *
 * Modes:
 *   "add"    args [areaId, pos, radius, officerNetId] — create an area and
 *            register it. Re-sent without the officerNetId to MOVE an area
 *            (follow mode): the engine has no move command, so it is a
 *            remove + re-add with the same ID, back-to-back — the area is
 *            never observably absent.
 *   "remove" args [areaId] — remove one area, unregister it, and drop its
 *            officer's published radius
 *   "clear"  args [] — remove EVERY registered area on the module. Fired by a
 *            client when its assigned curator changes: for the module it lost
 *            (normal cleanup) and the module it gained (orphan wipe after
 *            rejoin / reassignment).
 *
 * Arguments:
 * 0: Mode — "add", "remove" or "clear" <STRING>
 * 1: Curator logic module <OBJECT>
 * 2: Mode arguments (see above) <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * ["add", _curator, [1000, [0, 0, 0], 150, "2:5"]] call rtz_officer_fnc_applyArea
 *
 * Public: No
 */

params ["_mode", "_curator", ["_args", []]];

if (isNull _curator) exitWith {};

private _areas = GVAR(areasByCurator) getOrDefault [netId _curator, createHashMap, true];

switch (_mode) do {
    case "add": {
        _args params ["_areaId", "_pos", "_radius", ["_officerId", ""]];

        _curator removeCuratorEditingArea _areaId;
        _curator addCuratorEditingArea [_areaId, _pos, _radius];

        // A move carries no officerNetId — the registry already knows it
        if (_officerId isEqualTo "") then {
            _officerId = _areas getOrDefault [_areaId, ""];
        };
        _areas set [_areaId, _officerId];

        if (_officerId isNotEqualTo "") then {
            RTZ_officerZoneRadiusMap set [_officerId, _radius];
        };
    };
    case "remove": {
        _args params ["_areaId"];

        _curator removeCuratorEditingArea _areaId;

        private _officerId = _areas deleteAt _areaId;
        if (!isNil "_officerId" && {_officerId isNotEqualTo ""}) then {
            RTZ_officerZoneRadiusMap deleteAt _officerId;
        };
    };
    case "clear": {
        {
            _curator removeCuratorEditingArea _x;
            if (_y isNotEqualTo "") then {
                RTZ_officerZoneRadiusMap deleteAt _y;
            };
        } forEach _areas;

        GVAR(areasByCurator) deleteAt (netId _curator);
    };
};
