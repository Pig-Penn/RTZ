#include "script_component.hpp"
/*
 * Author: Maxim
 * Context menu statement: orders every selected AI squad to sweep the lootables
 * around its leader and improve its loadout - fill gaps (missing primary/launcher,
 * backpack, ammo) and swap up better gear (higher-rank weapon, higher chest armor
 * vest, armored headgear) even where the slot isn't empty.
 *
 * The sweep must run where the units are local (the server, for the Zeus AI this
 * targets), so the whole selection is batched into a single QGVAR(loot) server event
 * (the receiver is registered in XEH_postInit).
 *
 * Arguments:
 * 0: Selected Objects <ARRAY>
 * 1: Hovered Entity <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_objects, _hoveredEntity] call rtz_loot_fnc_orderLoot
 *
 * Public: No
 */

params ["_objects", "_hoveredEntity"];

private _groups = [_objects, _hoveredEntity] call FUNC(collectLootGroups);
if (_groups isEqualTo []) exitWith {};

[QGVAR(loot), [_groups]] call CBA_fnc_serverEvent;

private _message = LLSTRING(Looting);

if (count _groups > 1) then {
    _message = format ["%1  x%2", _message, count _groups];
};

[_message] call zen_common_fnc_showMessage;
