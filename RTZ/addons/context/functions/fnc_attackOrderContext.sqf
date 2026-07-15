#include "script_component.hpp"
/*
 * rtz_fnc_attackOrderContext
 *
 * Registers the "Attack Target" action in the Real-Time Zeus context menu
 * (category RTZ_RealTimeZeus): orders every AI group in the selection to
 * destroy the hovered unit or vehicle. The entry only shows when the cursor
 * hovers a live object and the selection resolves to at least one AI group
 * other than the target's own (FUNC(collectSquads)).
 *
 * The order itself (reveal + DESTROY waypoint) must run where each group is
 * local (not necessarily the server — AI in a player-led group is local to
 * that player), so the whole selection goes into a single QGVAR(attackOrder)
 * event TARGETED AT THE GROUPS: CBA delivers it once per owning machine and
 * the handler filters to its local groups (registered on every machine in
 * XEH_postInit).
 *
 * Loading: called by XEH_postInit (hasInterface) when the attack-order system is on.
 */

private _action = [
    "RTZ_AttackOrder",
    "Attack",
    "\a3\3den\Data\CfgWaypoints\destroy_ca.paa",
    {
        // ZEN passes [_position, _objects, _groups, _waypoints, _markers, _hoveredEntity, _args]
        params ["", "_objects", "", "", "", "_hoveredEntity"];

        // A hovered crewman means "attack his vehicle" (matches LAMBS tacticsAttack).
        private _target = vehicle _hoveredEntity;
        private _grps = ([_objects] call FUNC(collectSquads)) select {
            _x != group _target && { units _x findIf { !isPlayer _x } != -1 }
        };
        if (_grps isEqualTo []) exitWith {};

        [QGVAR(attackOrder), [_grps, _target], _grps] call CBA_fnc_targetEvent;

        private _msg = format ["Attack %1", ([_target] call EFUNC(common,classInfo)) select 0];
        if (count _grps > 1) then { _msg = format ["%1  x%2", _msg, count _grps]; };
        [_msg] call zen_common_fnc_showMessage;
    },
    {
        params ["", "_objects", "", "", "", "_hoveredEntity"];
        if !(_hoveredEntity isEqualType objNull) exitWith { false };
        if (isNull _hoveredEntity || { !alive _hoveredEntity }) exitWith { false };
        private _tGrp = group vehicle _hoveredEntity;
        ([_objects] call FUNC(collectSquads)) findIf {
            _x != _tGrp && { units _x findIf { !isPlayer _x } != -1 }
        } != -1
    }
] call zen_context_menu_fnc_createAction;

[_action, ["RTZ_RealTimeZeus"], 1] call zen_context_menu_fnc_addAction;
