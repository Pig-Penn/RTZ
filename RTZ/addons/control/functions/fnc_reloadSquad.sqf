#include "script_component.hpp"
/*
 * Author: Maxim
 * Context-menu statement: orders every unit in the selected group(s) to
 * reload its current weapon.
 *
 * The reload itself must run where each unit is local (units share their
 * group's locality — server, HC, or a player leading AI), so the whole
 * selection goes into a single QGVAR(reloadSquad) event TARGETED AT THE
 * GROUPS: CBA delivers it once per owning machine and the handler filters
 * to its local groups (registered on every machine in XEH_postInit).
 *
 * Arguments:
 * 0: Selection objects <ARRAY>
 * 1: Hovered entity <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_objects, _hoveredEntity] call rtz_control_fnc_reloadSquad
 *
 * Public: No
 */

params ["_objects", "_hoveredEntity"];

private _grps = [_objects + [_hoveredEntity]] call EFUNC(common,collectSquads);
if (_grps isEqualTo []) exitWith {};

[QGVAR(reloadSquad), [_grps], _grps] call CBA_fnc_targetEvent;

[LLSTRING(MsgReloading), count _grps] call EFUNC(common,showCountMessage);
