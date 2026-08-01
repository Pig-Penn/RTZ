#include "script_component.hpp"
/*
 * Author: Maxim
 * Handler body for QGVAR(finish) (registered in XEH_postInit). Breaks the engineer
 * out of the working animation and hands him back to his group. Must be executed
 * where the engineer is local.
 *
 * The rejoin is EFUNC(common,clearErrand), the mirror of the setup
 * EFUNC(common,approach) performed for the walk: it drops the LAMBS force-move
 * flag, restores the stance and puts the unit back in formation. The old code did
 * a bare `doFollow leader _unit` here, which is a NO-OP when the engineer is his
 * group's own leader — it left him standing where the earlier doStop had frozen
 * him, still flagged and still crouched.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit] call rtz_repair_fnc_finishRepair
 *
 * Public: No
 */

params ["_unit"];

if (isNull _unit) exitWith {};

// A corpse keeps its ragdoll — switchMove on a dead unit snaps it upright
if (alive _unit) then {
    _unit switchMove "";
};

[_unit] call EFUNC(common,clearErrand);
