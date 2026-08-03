#include "script_component.hpp"
/*
 * Author: Maxim
 * Updates the context menu action's label, icon and tint based on whether the
 * first officer in the given objects already has an editing area, or — if
 * not — is still on FUNC(isOnCooldown) from a recent removal. ZEN's context
 * menu has no true disabled-but-visible state (condition is a hard
 * show/hide), so the cooldown look is purely cosmetic: the entry stays
 * clickable, and a click while on cooldown is caught and messaged by
 * FUNC(toggleArea) instead of doing anything.
 *
 * Slots addressed through the ACTION_INDEX_* macros in main/script_macros.hpp,
 * as every other action modifier in the mod does.
 *
 * Arguments:
 * 0: Action <ARRAY>
 * 1: Objects <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_action, _objects] call rtz_officer_fnc_modifyAction
 *
 * Public: No
 */

params ["_action", "_objects"];

private _officers = _objects call FUNC(getOfficers);
if (_officers isEqualTo []) exitWith {};

private _officer = _officers select 0;

if (netId _officer in GVAR(areas)) exitWith {
    _action set [ACTION_INDEX_DISPLAYNAME, LLSTRING(ActionRemove)];
    _action set [ACTION_INDEX_ICON, ICON_REMOVE];
    _action set [ACTION_INDEX_ICONCOLOR, COLOR_REMOVE];
};

// Command aura active — an area cannot be added (see FUNC(setArea));
// cosmetic grey like the cooldown state below
if (GETVAR(_officer,GVAR(auraActive),false)) exitWith {
    _action set [ACTION_INDEX_DISPLAYNAME, LLSTRING(ActionAdd)];
    _action set [ACTION_INDEX_ICON, ICON_ADD];
    _action set [ACTION_INDEX_ICONCOLOR, COLOR_COOLDOWN];
};

private _cooldown = [_officer] call FUNC(isOnCooldown);

if (_cooldown > 0) then {
    _action set [ACTION_INDEX_DISPLAYNAME, format [LLSTRING(ActionCooldown), ceil _cooldown]];
    _action set [ACTION_INDEX_ICON, ICON_ADD];
    _action set [ACTION_INDEX_ICONCOLOR, COLOR_COOLDOWN];
} else {
    _action set [ACTION_INDEX_DISPLAYNAME, LLSTRING(ActionAdd)];
    _action set [ACTION_INDEX_ICON, ICON_ADD];
    _action set [ACTION_INDEX_ICONCOLOR, COLOR_ADD_ZONE];
};
