#include "script_component.hpp"
/*
 * Author: Maxim
 * Updates the command-aura context action's label, icon and tint from the
 * first officer's public GVAR(auraActive) flag — the server broadcasts it in
 * FUNC(applyAura) precisely so this can run without a round-trip. An officer
 * carrying an editing area THIS client placed shows greyed instead: the two
 * zones are mutually exclusive (see FUNC(toggleAura)). Like the cooldown look
 * in FUNC(modifyAction) the grey is purely cosmetic — ZEN's condition is a
 * hard show/hide, so the entry stays clickable and a click is caught and
 * messaged instead. An area another curator placed is only known server-side,
 * so that case can look green yet be refused by FUNC(applyAura).
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
 * [_action, _objects] call rtz_officer_fnc_modifyAuraAction
 *
 * Public: No
 */

params ["_action", "_objects"];

private _officers = _objects call FUNC(getOfficers);
if (_officers isEqualTo []) exitWith {};

private _officer = _officers select 0;

if (GETVAR(_officer,GVAR(auraActive),false)) exitWith {
    _action set [ACTION_INDEX_DISPLAYNAME, LLSTRING(ActionAuraRemove)];
    _action set [ACTION_INDEX_ICON, ICON_REMOVE];
    _action set [ACTION_INDEX_ICONCOLOR, COLOR_REMOVE];
};

if (netId _officer in GVAR(areas)) exitWith {
    _action set [ACTION_INDEX_DISPLAYNAME, LLSTRING(ActionAuraAdd)];
    _action set [ACTION_INDEX_ICON, ICON_ADD];
    _action set [ACTION_INDEX_ICONCOLOR, COLOR_COOLDOWN];
};

_action set [ACTION_INDEX_DISPLAYNAME, LLSTRING(ActionAuraAdd)];
_action set [ACTION_INDEX_ICON, ICON_ADD];
_action set [ACTION_INDEX_ICONCOLOR, COLOR_ADD_AURA];
