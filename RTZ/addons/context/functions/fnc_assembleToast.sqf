#include "script_component.hpp"
/*
 * rtz_fnc_assembleToast
 *
 * SERVER: toast the ordering curator's player over QGVAR(assembleMsg) (client
 * receiver registered in XEH_postInit). Nil-safe shorthand for the guard +
 * CBA_fnc_targetEvent block the assemble/disassemble errands repeat at every
 * failure point.
 *
 * Parameters:
 *   0: Object — ordering curator's player (objNull → silently no toast)
 *   1: String — message text ("" → silently no toast)
 */

params [["_curator", objNull], ["_text", ""]];

if (isNull _curator || {_text isEqualTo ""}) exitWith {};

[QGVAR(assembleMsg), [_text], _curator] call CBA_fnc_targetEvent;
