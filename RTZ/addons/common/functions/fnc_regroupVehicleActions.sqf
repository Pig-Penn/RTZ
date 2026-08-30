#include "script_component.hpp"
/*
 * Author: Maxim
 * Replaces ZEN's Vehicle Logistics folder with RTZ's own RTZ_Vehicle: moves the
 * entries ZEN put there across, folds the root-level Inventory entry in beside
 * them, and deletes ZEN's now-empty folder. Everything a curator does TO a
 * vehicle then sits behind one folder named "Vehicle" that RTZ owns.
 *
 * Runtime surgery on ZEN's compiled action tree rather than a config patch, for
 * the same reason FUNC(removeContextActions) is: zen_context_menu_fnc_compileActions
 * builds that tree from configFile once at preInit and every later reader works
 * off the missionNamespace array.
 *
 * The entries MOVE as intact nodes — action slots, children and priority — so
 * this function names no ZEN function anywhere. That is the whole point of
 * moving rather than re-declaring the folder's contents in RTZ's own
 * CfgContext.hpp: each entry ZEN ships there is implemented by a Public: No ZEN
 * function, and a re-declaration would couple RTZ to seven of them by literal
 * name. ZEN keeps ownership of what its entries DO; RTZ owns only where they sit.
 *
 * Purely client-side, and the second half of the same curator-facing feature as
 * FUNC(removeContextActions) — GVAR(enableCleanContextMenu) gates both. Order
 * between them is LOAD-BEARING and not merely tidy: removal strips Repair /
 * Rearm / Refuel by the path ["VehicleLogistics", ...], which this function
 * deletes. Run it second and those three would ride the move into RTZ_Vehicle
 * (rtz_supply's Resupply order replaces them) and their removal paths would
 * then miss and log.
 *
 * Inventory is NOT vehicle-only — ZEN shows it for any non-man entity with cargo
 * space, which is also every ammo crate and dropped backpack. So that entry is
 * SPLIT rather than moved: a vehicle-scoped copy joins the folder, and ZEN's root
 * entry is narrowed to everything else. Both halves defer to ZEN's own condition
 * for the rest of the test, so a crate still gets a root-level Inventory and no
 * object ever sees the entry twice.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call rtz_common_fnc_regroupVehicleActions
 *
 * Public: No
 */

// Runs at most once per client: a second pass would find its own rewritten
// condition in the root Inventory slot and stack another entity test on top of
// it, and ZEN's folder is no longer there to move.
if (GETGVAR(vehicleActionsRegrouped,false)) exitWith {};

private _actions = missionNamespace getVariable ["zen_context_menu_actions", []];

private _fnc_rootNode = {
    params ["_name"];
    private _index = _actions findIf {(_x select NODE_INDEX_ACTION select 0) isEqualTo _name};
    if (_index == -1) then {[]} else {_actions select _index};
};

private _vehicleNode = ["RTZ_Vehicle"] call _fnc_rootNode;
private _zenNode = ["VehicleLogistics"] call _fnc_rootNode;
private _inventoryNode = ["Inventory"] call _fnc_rootNode;

// A missing node means ZEN renamed or dropped the entry (or RTZ's own anchor
// failed to compile). Bail whole rather than half-applying: a half-filled folder
// beside the one it was meant to replace is a worse menu than the one ZEN ships,
// and RTZ_Vehicle left empty simply does not render.
if (_vehicleNode isEqualTo [] || {_zenNode isEqualTo []} || {_inventoryNode isEqualTo []}) exitWith {
    WARNING("ZEN VehicleLogistics or Inventory context entry missing, vehicle menu regrouping not installed.");
};

GVAR(vehicleActionsRegrouped) = true;

// ZEN's own condition, kept as the shared base both halves of the Inventory split
// delegate to. Read BEFORE either slot is overwritten, and parked in a GVAR
// because SQF code literals capture nothing — a closure over a private would be
// nil by the time the menu calls it.
GVAR(zenInventoryCondition) = _inventoryNode select NODE_INDEX_ACTION select ACTION_INDEX_CONDITION;

private _children = _vehicleNode select NODE_INDEX_CHILDREN;

// Whatever survived the removal pass, carried over untouched.
_children append (_zenNode select NODE_INDEX_CHILDREN);

// Conditions are invoked as ACTION_PARAMS call _condition, so `_this select 5` is
// the hovered entity (zen_context_menu/script_component.hpp). Lazy `&&` keeps the
// isKindOf off any argument ZEN's own test has already rejected — that test is
// what guarantees an object is there to type-check at all.
private _vehicleInventory = +_inventoryNode;
(_vehicleInventory select NODE_INDEX_ACTION) set [ACTION_INDEX_CONDITION, {
    (_this call GVAR(zenInventoryCondition)) && {(_this select 5) isKindOf "AllVehicles"}
}];

// Above the entries moved in, which all sit at ZEN's config default of 0. Sorted
// descending on the priority slot, exactly as compileActions leaves every child
// list.
_vehicleInventory set [NODE_INDEX_PRIORITY, 1];
_children pushBack _vehicleInventory;
[_children, NODE_INDEX_PRIORITY, false] call CBA_fnc_sortNestedArray;

// ZEN's root entry now covers only the containers that are not vehicles.
(_inventoryNode select NODE_INDEX_ACTION) set [ACTION_INDEX_CONDITION, {
    (_this call GVAR(zenInventoryCondition)) && {!((_this select 5) isKindOf "AllVehicles")}
}];

// ZEN's folder last, once nothing is left in it that RTZ still wants.
["VehicleLogistics"] call zen_context_menu_fnc_removeAction;
