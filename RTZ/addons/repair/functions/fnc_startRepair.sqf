#include "script_component.hpp"
/*
 * Author: Maxim
 * Arrival hook of the repair errand: locks the engineer into the working pose and
 * signs him on to the vehicle's repair job. Must be executed where the engineer is
 * local — doStop, setDir and playMove are all local-effect commands.
 *
 * The damage itself is NOT applied here. It is applied by one server side job per
 * VEHICLE (FUNC(repairJob)), which every arriving engineer joins, so a second
 * engineer makes the work go faster instead of starting a rival loop that fights
 * the first one's damage snapshot.
 *
 * The engineer's errand token rides along with him: the job uses it to tell a
 * worker who wandered off from one the curator deliberately re-tasked, so a
 * redirected engineer is dropped silently instead of being released back into
 * formation on top of his new order.
 *
 * The LAMBS force-move flag EFUNC(common,approach) set for the walk is deliberately
 * left in place — it is what stops the danger FSM pulling the engineer out of the
 * animation. EFUNC(common,clearErrand) drops it when the work ends.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Vehicle <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit, _vehicle] call rtz_repair_fnc_startRepair
 *
 * Public: No
 */

params ["_unit", "_vehicle"];

// Face the vehicle and hold position in the working animation
_unit setDir (_unit getDir _vehicle);
doStop _unit;
_unit playMove REPAIR_ANIMATION;

[QGVAR(join), [_unit, _vehicle, [_unit] call EFUNC(common,errandToken)]] call CBA_fnc_serverEvent;
