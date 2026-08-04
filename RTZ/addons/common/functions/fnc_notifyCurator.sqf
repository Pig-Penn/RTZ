#include "script_component.hpp"
/*
 * Author: Maxim
 * Shows a ZEN message on ONE curator's screen, from anywhere.
 *
 * The single channel for "tell the curator who ordered this what happened". Four
 * components had grown their own — EGVAR(common,approachMsg), EGVAR(assemble,message),
 * EGVAR(captive,captureMsg) and EGVAR(officer,auraMsg) — each a one-line
 * hasInterface-gated receiver over zen_common_fnc_showMessage, addressed at one
 * player with CBA_fnc_targetEvent. Four copies of one contract had already drifted
 * into two different calling conventions (officer unwrapped `_this select 0`, the
 * other three did not), which is how the fifth would have got it wrong.
 *
 * Needed because the machine that KNOWS is rarely the machine that DISPLAYS: errands
 * resolve where the unit is local — the server, or a headless client, or whichever
 * player leads the AI group — and none of those can draw on the curator's screen.
 *
 * A STRING is passed to showMessage as a format ARGUMENT rather than as the format
 * string, so a translation containing a literal "%" is not re-scanned as a
 * placeholder and mangled. Callers that genuinely want format arguments pass the
 * whole array instead, exactly as showMessage takes it.
 *
 * Arguments:
 * 0: Curator's player <OBJECT>
 * 1: Message <STRING>, or showMessage arguments <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_curator, LLSTRING(Aborted)] call rtz_common_fnc_notifyCurator
 * [_player, [LSTRING(MsgCaptured), _name, _share]] call rtz_common_fnc_notifyCurator
 *
 * Public: No
 */

params [["_curator", objNull], ["_message", ""]];

if (isNull _curator) exitWith {};

// Nothing to say. Tested before the wrap, not inside it: an exitWith written in
// the `then` block below would leave only that block, not this function (§2).
// isEqualTo never errors on a type mismatch, so this is safe for the array form.
if (_message isEqualTo "" || {_message isEqualTo []}) exitWith {};

private _args = if (_message isEqualType "") then {["%1", _message]} else {_message};

[QGVAR(msg), _args, _curator] call CBA_fnc_targetEvent;
