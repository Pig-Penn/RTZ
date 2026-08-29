#include "script_component.hpp"
/*
 * Author: Maxim
 * Removes a fire mission target that never became a fire mission — the pick timed
 * out waiting for registration, the dialog refused to open, or the curator closed it
 * without confirming.
 *
 * Routed through a CBA target event rather than a bare deleteVehicle because the
 * target does not reliably stay local to the curator who created it: ZEN's
 * zen_modules_fnc_initModule moves every module logic into one of BI's function-module
 * groups from the SERVER, a frame after creation. deleteVehicle has a global effect
 * but only works from the machine owning the object (see EFUNC(delete,orderDelete),
 * which routes the same way for the same reason), so a bare call here would silently
 * do nothing and leave exactly the orphaned target this function exists to prevent.
 *
 * Arguments:
 * 0: Target logic <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_target] call rtz_battery_fnc_discardTarget
 *
 * Public: No
 */

params ["_target"];

if (isNull _target) exitWith {};

[QGVAR(discardTarget), [_target], _target] call CBA_fnc_targetEvent;
