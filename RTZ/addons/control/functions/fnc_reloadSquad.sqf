#include "script_component.hpp"
/*
 * rtz_control_fnc_reloadSquad
 *
 * Context-menu statement: orders every unit in the selected group(s) to
 * reload its current weapon.
 *
 * The reload itself must run where each unit is local (units share their
 * group's locality — server, HC, or a player leading AI), so the whole
 * selection goes into a single QGVAR(reloadSquad) event TARGETED AT THE
 * GROUPS: CBA delivers it once per owning machine and the handler filters
 * to its local groups (registered on every machine in XEH_postInit).
 *
 * Parameters:
 *   0: Array  — selection objects
 *   1: Object — hovered entity
 */

params ["_objects", "_hoveredEntity"];
private _grps = [_objects + [_hoveredEntity]] call EFUNC(common,collectSquads);
if (_grps isEqualTo []) exitWith {};

[QGVAR(reloadSquad), [_grps], _grps] call CBA_fnc_targetEvent;

private _msg = LLSTRING(MsgReloading);
if (count _grps > 1) then { _msg = format ["%1  x%2", _msg, count _grps]; };
[_msg] call zen_common_fnc_showMessage;
