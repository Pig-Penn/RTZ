#include "script_component.hpp"
/*
 * rtz_fnc_reloadSquadContext
 *
 * Registers the root-level "Reload" action in the Zeus context menu: orders
 * every unit in the selected group(s) to reload its current weapon. The
 * entry only shows when the selection or hovered entity resolves to at
 * least one group (FUNC(collectSquads)).
 *
 * The reload itself must run where each unit is local (units share their
 * group's locality — server, HC, or a player leading AI), so the whole
 * selection goes into a single QGVAR(reloadSquad) event TARGETED AT THE
 * GROUPS: CBA delivers it once per owning machine and the handler filters
 * to its local groups (registered on every machine in XEH_postInit).
 *
 * Loading: called by XEH_postInit (hasInterface) when the reload-squad system is on.
 */

private _action = [
    "RTZ_ReloadSquad",
    "Reload",
    "\A3\ui_f\data\igui\cfg\simpletasks\types\rearm_ca.paa",
    {
        // ZEN passes [_position, _objects, _groups, _waypoints, _markers, _hoveredEntity, _args]
        params ["", "_objects", "", "", "", "_hoveredEntity"];
        private _grps = [_objects + [_hoveredEntity]] call FUNC(collectSquads);
        if (_grps isEqualTo []) exitWith {};

        [QGVAR(reloadSquad), [_grps], _grps] call CBA_fnc_targetEvent;

        private _msg = "Reloading";
        if (count _grps > 1) then { _msg = format ["%1  x%2", _msg, count _grps]; };
        [_msg] call zen_common_fnc_showMessage;
    },
    {
        params ["", "_objects", "", "", "", "_hoveredEntity"];
        ([_objects + [_hoveredEntity]] call FUNC(collectSquads)) isNotEqualTo []
    }
] call zen_context_menu_fnc_createAction;

[_action, [], 1] call zen_context_menu_fnc_addAction;
