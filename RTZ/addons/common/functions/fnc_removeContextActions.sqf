#include "script_component.hpp"
/*
 * Author: Maxim
 * Removes ZEN's own cluttered entries (and the LAMBS Danger FSM groups) from
 * this curator's Zeus context menu, leaving room for the RTZ actions. Purely
 * client-side: zen_context_menu_fnc_removeAction only affects the local menu.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call rtz_common_fnc_removeContextActions
 *
 * Public: No
 */

// ZEN built-in actions
["Formation"]    call zen_context_menu_fnc_removeAction;
["Behaviour"]    call zen_context_menu_fnc_removeAction;
["CombatMode"]   call zen_context_menu_fnc_removeAction;
["SpeedMode"]    call zen_context_menu_fnc_removeAction;
["Stance"]       call zen_context_menu_fnc_removeAction;
["HealUnits"]    call zen_context_menu_fnc_removeAction;
["TeleportZeus"] call zen_context_menu_fnc_removeAction;
["VehicleAppearance"] call zen_context_menu_fnc_removeAction;

["VehicleLogistics", "Repair"] call zen_context_menu_fnc_removeAction;
["VehicleLogistics", "Rearm"]  call zen_context_menu_fnc_removeAction;
["VehicleLogistics", "Refuel"] call zen_context_menu_fnc_removeAction;

// LAMBS Danger FSM context groups
["lambs_danger"]    call zen_context_menu_fnc_removeAction;
["lambs_wp"]        call zen_context_menu_fnc_removeAction;
["lambs_wp_Search"] call zen_context_menu_fnc_removeAction;
