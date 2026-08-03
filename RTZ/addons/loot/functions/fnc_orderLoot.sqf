#include "script_component.hpp"
/*
 * Author: Maxim
 * Context menu statement: orders every selected AI squad to sweep the lootables
 * around its leader and improve its loadout - fill gaps (missing primary or launcher,
 * backpack, night vision, ammunition) and swap up better gear where the slot is
 * already occupied, within what each unit's ROLE sanctions.
 *
 * The sweep must run where the units are local (the server, for the Zeus AI this
 * targets), so the whole selection is batched into a single QGVAR(loot) server event
 * (the receiver is registered in XEH_postInit).
 *
 * The toast counts GROUPS, which is what the curator selected and clicked on. How
 * many units inside them end up walking anywhere is decided on the server, after
 * FUNC(lootSquads) has worked out who would actually gain something, and is not known
 * here - reporting the click rather than guessing at its outcome is the same contract
 * every other RTZ order action reports under.
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

[LLSTRING(Looting), count _groups] call EFUNC(common,showCountMessage);
