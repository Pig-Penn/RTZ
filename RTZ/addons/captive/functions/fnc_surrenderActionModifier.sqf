#include "script_component.hpp"
/*
 * Author: Maxim
 * CfgContext modifierFunction for the surrender toggle (see CfgContext.hpp).
 * Mutates the action's displayName and iconColor to reflect whether the first
 * eligible unit in the selection is currently surrendered:
 *   fighting            -> purple "Surrender"
 *   surrendered, locked -> grey  "Stand Down — Xs" (inside the lock window)
 *   surrendered, free   -> green "Stand Down"
 *
 * The icon itself never changes — ICON_SURRENDER as declared in CfgContext.hpp
 * serves both directions — so only the tint is set here.
 *
 * "First eligible" has to agree with FUNC(surrenderToggle), which derives the
 * whole selection's target state from the same unit — the label would otherwise
 * promise one thing and the click do another.
 *
 * Captured prisoners never reach here: CAN_SURRENDER excludes them, so a
 * prisoner-only selection removes the action entirely rather than offering a
 * stand-down that FUNC(surrenderApply) would refuse.
 *
 * Arguments:
 * 0: Action <ARRAY>
 * 1: Objects from a ZEN action's selection + hovered entity <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_action, _objects] call rtz_captive_fnc_surrenderActionModifier
 *
 * Public: No
 */

params ["_action", "_objects"];

// findIf against the shared macro rather than FUNC(collectSurrenderUnits): only
// the first eligible unit decides the label, and ZEN runs this on every context
// menu open, immediately followed by the condition doing its own scan. Building
// and allocating the full list twice per menu open to read element 0 was the
// most expensive thing this component did in normal play.
private _index = _objects findIf {_x isEqualType objNull && {CAN_SURRENDER(_x)}};
if (_index < 0) exitWith {};

private _unit = _objects select _index;

if !(_unit getVariable [QGVAR(surrendered), false]) exitWith {
    _action set [ACTION_INDEX_DISPLAYNAME, LLSTRING(ActionSurrender)];
    _action set [ACTION_INDEX_ICONCOLOR, COLOR_SURRENDER];
};

private _remaining = ceil (GVAR(standDownLockTime)
    - (CBA_missionTime - (_unit getVariable [QGVAR(surrenderTime), CBA_missionTime])));

if (_remaining > 0) then {
    _action set [ACTION_INDEX_DISPLAYNAME, format [LLSTRING(ActionStandDownLocked), _remaining]];
    _action set [ACTION_INDEX_ICONCOLOR, COLOR_LOCKED];
} else {
    _action set [ACTION_INDEX_DISPLAYNAME, LLSTRING(ActionStandDown)];
    _action set [ACTION_INDEX_ICONCOLOR, COLOR_STANDDOWN];
};
