#include "script_component.hpp"
/*
 * Author: Maxim
 * Commits the drawn trench: hands the two endpoints and the selection's engineers
 * to the server. Runs on the ordering curator's client.
 *
 * The engineers are resolved HERE rather than on the server because the selection
 * is the curator's own — the server has no view of what he had highlighted.
 *
 * Arguments:
 * 0: Start position ASL <ARRAY>
 * 1: End position ASL <ARRAY>
 * 2: Selected objects <ARRAY>
 * 3: Ignore safety checks <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_start, _end, _objects, false] call rtz_dig_fnc_orderDig
 *
 * Public: No
 */

params ["_start", "_end", "_objects", ["_force", false]];

if (!GVAR(enabled)) exitWith {};

private _engineers = [_objects, ["engineer"]] call EFUNC(common,collectSpecialists);

if (_engineers isEqualTo []) exitWith {};

// player is the ordering curator (this runs on their client) — threaded through so
// the server can toast them if the line is refused or the diggers never arrive.
[QGVAR(start), [_start, _end, _force, _engineers, player]] call CBA_fnc_serverEvent;

[LLSTRING(MsgDigging), count _engineers] call EFUNC(common,showCountMessage);
