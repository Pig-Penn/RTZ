#include "script_component.hpp"
/*
 * Author: Maxim
 * Toast the ordering curator's player over QGVAR(message) (the client
 * receiver is registered in XEH_postInit). Nil-safe shorthand for the guard plus
 * CBA_fnc_targetEvent block the errands repeat at every failure point.
 *
 * Arguments:
 * 0: Curator's Player <OBJECT> - objNull raises no toast
 * 1: Message <STRING> - "" raises no toast
 *
 * Return Value:
 * None
 *
 * Example:
 * [_curator, LLSTRING(Aborted)] call rtz_assemble_fnc_notifyCurator
 *
 * Public: No
 */

params [["_curator", objNull], ["_text", ""]];

if (isNull _curator || {_text isEqualTo ""}) exitWith {};

[QGVAR(message), [_text], _curator] call CBA_fnc_targetEvent;
