#include "script_component.hpp"
/*
 * Author: Maxim
 * Locks the engineer into the repair animation and steps the vehicle damage
 * down to zero over the repair duration setting. The work is abandoned if the
 * unit or vehicle dies, the order is superseded, or the unit is knocked away
 * from the vehicle. Must be executed where the unit is local.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Vehicle <OBJECT>
 * 2: Order Sequence <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit, _vehicle, 1] call rtz_repair_fnc_startRepair
 *
 * Public: No
 */

params ["_unit", "_vehicle", "_order"];

// Face the vehicle and hold position in the working animation
_unit setDir (_unit getDir _vehicle);
doStop _unit;
_unit playMove REPAIR_ANIMATION;

[{
    params ["_args", "_handle"];
    _args params ["_unit", "_vehicle", "_order", "_startDamage", "_startTime"];

    private _aborted = !alive _unit || {!alive _vehicle}
        || {_unit getVariable [QGVAR(order), 0] != _order}
        || {_unit distance _vehicle > REPAIR_ABORT_DISTANCE};

    private _progress = ((CBA_missionTime - _startTime) / (GVAR(repairDuration) max 1)) min 1;

    if (!_aborted) then {
        _vehicle setDamage (_startDamage * (1 - _progress));
    };

    if (_aborted || {_progress >= 1}) then {
        [_handle] call CBA_fnc_removePerFrameHandler;

        if (!_aborted) then {
            _vehicle setDamage 0;
        };

        // Break out of the animation and return the unit to its group
        if (alive _unit && {_unit getVariable [QGVAR(order), 0] == _order}) then {
            _unit switchMove "";
            _unit doFollow leader _unit;
        };
    };
}, REPAIR_INTERVAL, [_unit, _vehicle, _order, damage _vehicle, CBA_missionTime]] call CBA_fnc_addPerFrameHandler;
