#include "script_component.hpp"
/*
 * Author: Maxim
 * Releases a path's executor resources. Arrival actions are separate from
 * cleanup: an aborted flight must not descend to an unvisited landing point.
 * Re-tasking releases the previous speed cap and puppet before taking control
 * again, without ordering the unit home or applying the old flight's altitude.
 *
 * Arguments:
 * 0: Path record <ARRAY>
 * 1: Successfully reached the end <BOOL> (default: false)
 * 2: Replacing this path immediately <BOOL> (default: false)
 *
 * Return Value:
 * None
 *
 * Example:
 * [_record, true] call rtz_path_fnc_endFollow
 *
 * Public: No
 */

params ["_record", ["_completed", false], ["_retask", false]];
_record params ["_unit", "_hull", "_points", "", "_kind", "_patrol"];
private _hadTarget = !isNull (_record select FOLLOW_TARGET);

// Event handlers belong to this machine even after the unit has moved away.
// setPuppet removes them here, but only changes AI/animation while still local.
[_record, ""] call FUNC(setPuppet);

if ((_kind == KIND_AIR || {_kind == KIND_BOAT}) && {!isNull _hull} && {local _hull}) then {
    if ((_record select FOLLOW_FLIGHT) isEqualTo []) then {
        // This cap was applied at start, even if the deferred launch never ran.
        _hull limitSpeed SPEED_UNLIMITED;
    } else {
        if (_kind == KIND_AIR && {!_retask} && {_record select FOLLOW_LAUNCHED}
            && {alive _hull} && {alive _unit} && {local _unit}
            && {!isPlayer _unit} && {driver _hull isEqualTo _unit}) then {
            (_record select FOLLOW_FLIGHT) params ["_isHeli"];
            // Cancellation holds the CURRENT height. Only actual arrival may
            // adopt the final point's height, land or stop a hovering helicopter.
            private _alt = ((getPos _hull) select 2) max 0;
            if (_completed) then {
                _alt = ((ASLToAGL (_points select -1)) select 2) max 0;
            };
            _hull flyInHeight _alt;

            if (_completed && {_isHeli} && {!_patrol}) then {
                if (_alt <= FLIGHT_LAND_ALT) then {
                    _hull land "LAND";
                } else {
                    _hull setVelocity [0, 0, 0];
                };
            };
        };
    };
};

if (isNull _unit || {!alive _unit} || {!local _unit} || {isPlayer _unit}) exitWith {};
// A path can end during combatPause, when no puppet is active to clear aiming.
if (_hadTarget) then {
    _unit doWatch objNull;
    _unit doTarget objNull;
};
if (!_retask) then {_unit doFollow (leader _unit)};
