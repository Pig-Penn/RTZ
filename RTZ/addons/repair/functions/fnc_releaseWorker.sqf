#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER: hands one engineer back from the repair job. The release itself has to
 * run where the engineer is local (switchMove, doFollow and the stance are all
 * local-effect commands) while the job that decides when to release him runs on
 * the server, so this is the bridge between the two — see FUNC(finishRepair) for
 * the other half.
 *
 * Called for every way a worker can leave the job EXCEPT being re-tasked by the
 * curator: a redirected engineer already belongs to his new order and must not be
 * released on top of it (FUNC(repairJob) drops him silently instead).
 *
 * Arguments:
 * 0: Unit <OBJECT> — objNull is a no-op
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit] call rtz_repair_fnc_releaseWorker
 *
 * Public: No
 */

params ["_unit"];

if (isNull _unit) exitWith {};

[QGVAR(finish), [_unit], _unit] call CBA_fnc_targetEvent;
