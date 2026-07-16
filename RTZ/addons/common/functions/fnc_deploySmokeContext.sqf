#include "script_component.hpp"
/*
 * rtz_common_fnc_deploySmokeContext
 *
 * Registers the "Deploy Countermeasures" action under the Real-Time Zeus submenu:
 * fires the smoke launcher / flare / chaff dispenser of every selected
 * vehicle that has one (FUNC(findCountermeasureWeapons)).
 *
 * The fire itself must run where each vehicle is local (the server for AI
 * armor, a player's machine for a player-crewed vehicle), so the whole
 * selection goes into a single QGVAR(deploySmoke) event TARGETED AT THE
 * VEHICLES: CBA delivers it once per owning machine and the handler filters
 * to its local vehicles (registered on every machine in XEH_postInit).
 *
 * Loading: called by XEH_postInit (hasInterface) when the deploy-smoke system is on.
 */

private _action = [
    "RTZ_DeploySmoke",
    "Countermeasures",
    "\x\zen\addons\modules\ui\smoke_pillar_ca.paa",
    {
        // ZEN passes [_position, _objects, _groups, _waypoints, _markers, _hoveredEntity, _args]
        params ["", "_objects", "", "", "", "_hoveredEntity"];
        private _vehs = ([_objects + [_hoveredEntity]] call FUNC(collectVehicles)) select {
            ([_x] call FUNC(findCountermeasureWeapons)) isNotEqualTo []
        };
        if (_vehs isEqualTo []) exitWith {};

        [QGVAR(deploySmoke), [_vehs], _vehs] call CBA_fnc_targetEvent;

        private _msg = "Smoke Screen";
        if (count _vehs > 1) then { _msg = format ["%1  x%2", _msg, count _vehs]; };
        [_msg] call zen_common_fnc_showMessage;
    },
    {
        params ["", "_objects", "", "", "", "_hoveredEntity"];
        ([_objects + [_hoveredEntity]] call FUNC(collectVehicles)) findIf {
            ([_x] call FUNC(findCountermeasureWeapons)) isNotEqualTo []
        } != -1
    }
] call zen_context_menu_fnc_createAction;

[_action, ["RTZ_RealTimeZeus"], 1] call zen_context_menu_fnc_addAction;
