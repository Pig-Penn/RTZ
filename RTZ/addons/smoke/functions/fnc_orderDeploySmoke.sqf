#include "script_component.hpp"
/*
 * Author: Maxim
 * Context menu statement: fires the smoke launcher / flare / chaff dispenser of
 * every selected vehicle that has one (FUNC(findCountermeasureWeapons)).
 *
 * The fire itself must run where each vehicle is local (the server for AI armor,
 * a player's machine for a player-crewed vehicle), so the whole selection goes
 * into a single QGVAR(deploySmoke) event targeted at the vehicles: CBA delivers
 * it once per owning machine and the handler filters to its local vehicles
 * (FUNC(deploySmokeApply), registered on every machine in XEH_postInit).
 *
 * Arguments:
 * 0: Selected Objects <ARRAY>
 * 1: Hovered Entity <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_objects, _hoveredEntity] call rtz_smoke_fnc_orderDeploySmoke
 *
 * Public: No
 */

params ["_objects", "_hoveredEntity"];

private _vehicles = ([_objects + [_hoveredEntity]] call EFUNC(common,collectVehicles)) select {
    ([_x] call FUNC(findCountermeasureWeapons)) isNotEqualTo []
};

if (_vehicles isEqualTo []) exitWith {};

[QGVAR(deploySmoke), [_vehicles], _vehicles] call CBA_fnc_targetEvent;

[LLSTRING(ActionDeploySmoke), count _vehicles] call EFUNC(common,showCountMessage);
