#include "script_component.hpp"
/*
 * Author: Maxim
 * Context menu statement: opens a ghost model placement preview of the first
 * selected squad's weapon, then orders every selected squad carrying a disassembled
 * static weapon to walk its gunner and assistant to the picked spot and raise the
 * weapon there. The curator drags the translucent static to a spot and rotates it to
 * set its facing, Escape cancels with no order sent.
 *
 * The walk, createVehicle and assemble action must run where the gunner is local -
 * the server for Zeus AI, but a headless client or a player's machine for offloaded
 * or player-led groups - so each set is dispatched to his owner over QGVAR(assemble)
 * (the receiver is registered on every machine in XEH_postInit). Multiple squads fan
 * out around the cursor so their weapons don't build on the same point. The ordering
 * curator's player rides along so the errand can toast failures back.
 *
 * Arguments:
 * 0: Selected Objects <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_objects] call rtz_assemble_fnc_orderAssemble
 *
 * Public: No
 */

params ["_objects"];

private _sets = [_objects] call FUNC(collectAssembleSets);
if (_sets isEqualTo []) exitWith {};

[
    (_sets select 0) select 1,
    {
        params ["_confirmed", "_position", "_direction", "_sets"];

        if (!_confirmed) exitWith {};

        {
            _x params ["_gunner", "_staticClass", "_assistant"];

            // Fan the squads out around the cursor, the first builds on it
            private _target = _position;

            if (_forEachIndex > 0) then {
                _target = _position getPos [FAN_DISTANCE * _forEachIndex, FAN_BEARING * _forEachIndex];
            };

            // Targeted at the gunner: CBA delivers to whichever machine owns him
            [QGVAR(assemble), [_gunner, _staticClass, _assistant, _target, _direction, player], _gunner] call CBA_fnc_targetEvent;
        } forEach _sets;

        private _message = LLSTRING(Assembling);

        if (count _sets > 1) then {
            _message = format ["%1  x%2", _message, count _sets];
        };

        [_message] call zen_common_fnc_showMessage;
    },
    _sets,
    ICON_PREVIEW,
    COLOR_PREVIEW,
    true
] call EFUNC(common,placementPreview);
