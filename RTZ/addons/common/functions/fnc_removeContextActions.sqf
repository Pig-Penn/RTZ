#include "script_component.hpp"
/*
 * Author: Maxim
 * Removes ZEN's own cluttered entries (and the LAMBS Danger FSM groups) from
 * this curator's Zeus context menu, leaving room for the RTZ actions. Purely
 * client-side: zen_context_menu_fnc_removeAction only affects the local menu.
 *
 * Runs at most once per client. ZEN's removeAction logs an RPT error for a
 * path that is no longer in the tree, so a second pass would be pure error
 * spam with nothing left to remove. The removal is also one-way: ZEN offers
 * no re-add for its own built-ins, so a curator who turns
 * GVAR(enableCleanContextMenu) back off gets the entries back on the next
 * mission start rather than immediately (see XEH_postInit).
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

if (GETGVAR(contextMenuCleaned,false)) exitWith {};
GVAR(contextMenuCleaned) = true;

// removeAction takes a path array; a single-element path may be given as the
// bare string, which is why the one-name entries are still wrapped here.
{
    _x call zen_context_menu_fnc_removeAction;
} forEach [
    // ZEN built-in actions
    ["Formation"],
    ["Behaviour"],
    ["CombatMode"],
    ["SpeedMode"],
    ["Stance"],
    // Not declutter but a REPLACEMENT: rtz_battery re-adds an equivalent entry at
    // ZEN's own priority 70, targeted with the cursor and opening ZEN's Fire Mission
    // dialog rather than firing a fixed four rounds. A curator who turns this setting
    // off therefore gets both entries, which is the honest outcome — the setting is
    // per-client and one-way, so the alternative would be a second removal site
    // outside its control.
    ["FireArtillery"],
    ["HealUnits"],
    ["TeleportZeus"],
    ["VehicleAppearance"],
    ["VehicleLogistics", "Repair"],
    ["VehicleLogistics", "Rearm"],
    ["VehicleLogistics", "Refuel"],

    // LAMBS Danger FSM context groups
    ["lambs_danger"],
    ["lambs_wp"],
    ["lambs_wp_Search"]
];
