#include "script_component.hpp"
/*
 * Author: Maxim
 * Opens the gear / inventory of a single Zeus-selected unit (or vehicle) so the
 * curator can arrange its loadout and loot anything around it. Once the gear
 * display is open on a unit, its Ground / Container tabs list everything within
 * reach of that unit — nearby crates, vehicle cargo, and dead bodies — so the
 * curator can move items in and out freely.
 *
 * For a man: the nearest container / vehicle / body ~1 m in front of the unit is
 * pre-selected (5 m radius) so the right-hand panel opens straight onto lootable
 * gear. With nothing nearby it opens the unit's own inventory — the curator can
 * still switch to the Ground tab.
 *
 * For a vehicle: the gear is opened through a crew member, since the acting
 * entity for the "Gear" action must be a man.
 *
 * Locality: runs on the curator's client. `action ["Gear", ...]` opens the
 * dialog locally; the engine's networked inventory sync carries the item
 * transfers even when the unit / container is remote — the same path that lets
 * you loot a server-side body from a client.
 *
 * Requires the player to be an assigned curator with the Zeus display open
 * (guarded by the caller / keybind).
 *
 * Arguments:
 * 0: Unit or vehicle whose inventory to open — omitted resolves to the first
 *    selected man / vehicle from curatorSelected <OBJECT> (default: objNull)
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit] call rtz_common_fnc_openUnitInventory
 *
 * Public: No
 */

params [["_unit", objNull, [objNull]]];

// No explicit unit → take the first selected man or vehicle from the curator.
if (isNull _unit) then {
    private _objs = SELECTED_OBJECTS;
    private _i = _objs findIf { _x isKindOf "CAManBase" || { _x isKindOf "AllVehicles" } };
    if (_i > -1) then { _unit = _objs select _i };
};

if (isNull _unit) exitWith {
    [LLSTRING(MsgNoUnitSelected)] call zen_common_fnc_showMessage;
};

// ── Vehicle: open its cargo through a crew member ───────────────────────────────
if !(_unit isKindOf "CAManBase") exitWith {
    private _veh  = _unit;
    private _crew = crew _veh;
    if (_crew isEqualTo []) exitWith {
        [LLSTRING(MsgNoCrew)] call zen_common_fnc_showMessage;
    };
    (_crew select 0) actionNow ["Gear", _veh];
};

// ── Man: pre-select the nearest lootable container / body in front, then open ────
// nearestObjects returns nearest-first. Include CAManBase so corpses are lootable,
// but skip _unit itself and any living man (a living unit isn't a lootable target).
// objNull fallback → plain inventory: the engine auto-fills the Ground panel with
// real nearby items instead of echoing the unit's own worn gear.
private _checkPos = _unit getPos [1, getDir _unit];
private _nearby   = nearestObjects [_checkPos, ["ThingX", "AllVehicles", "CAManBase"], 5];
private _ti       = _nearby findIf { _x isNotEqualTo _unit && {!(_x isKindOf "CAManBase") || {!alive _x}} };
private _target   = [objNull, _nearby select _ti] select (_ti > -1);

_unit action ["Gear", _target];
