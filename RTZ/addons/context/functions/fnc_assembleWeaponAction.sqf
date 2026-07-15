#include "script_component.hpp"
/*
 * rtz_fnc_assembleWeaponAction
 *
 * Context-menu statement: for every selected squad carrying a disassembled static
 * weapon, sends its gunner + assistant to walk to the picked cursor spot and raise
 * the weapon with the real engine assemble animation. The walk / createVehicle /
 * assemble action must run where the AI is local (the server, in Zeus PvP), so
 * each set is dispatched there via QGVAR(assembleWeaponApply) (registered in
 * XEH_postInit).
 *
 * Multiple selected squads fan out around the cursor so their weapons don't build
 * on the same point. The ordering curator's player rides along for failure toasts.
 *
 * Parameters:
 *   0: Array — selection objects (curatorSelected + hovered entity)
 *   1: Array — picked world position (ZEN's cursor _position)
 */

params ["_objects", "_position"];
private _sets = [_objects] call FUNC(collectAssembleSets);
if (_sets isEqualTo []) exitWith {};

// Ghost-model placement preview (the first set's weapon). The curator drags the
// translucent static to a spot and rotates it to set its facing; ESC cancels with
// no order sent. On confirm every selected squad's crew walks to the chosen spot
// (fanned so statics don't stack) and raises its weapon on that heading.
[
    (_sets select 0) select 1,
    {
        params ["_confirmed", "_pos", "_dir", "_sets"];
        if (!_confirmed) exitWith {};

        {
            _x params ["_gunner", "_staticClass", "_assistant"];
            // Fan teams out around the cursor (first builds on it) so statics don't stack.
            private _target = _pos;
            if (_forEachIndex > 0) then {
                _target = _pos getPos [3 * _forEachIndex, 60 * _forEachIndex];
            };
            [QGVAR(assembleWeaponApply), [_gunner, _staticClass, _assistant, _target, _dir, player]] call CBA_fnc_serverEvent;
        } forEach _sets;

        private _msg = "Assembling";
        if (count _sets > 1) then { _msg = format ["%1  x%2", _msg, count _sets]; };
        [_msg] call zen_common_fnc_showMessage;
    },
    _sets,
    "\a3\ui_f\data\igui\cfg\actions\repair_ca.paa",
    [0.20, 1.00, 0.20, 1],
    true
] call EFUNC(common,placementPreview);
