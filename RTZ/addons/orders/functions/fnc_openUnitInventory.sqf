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
 * Locality: runs on the curator's client. The engine's networked inventory sync
 * carries the item TRANSFERS even when the unit / container is remote — the same
 * path that lets you loot a server-side body from a client — but that does not
 * extend to OPENING the dialog. `action` / `actionNow` are argument- and
 * effect-local, so the acting entity must be local to this machine; issued
 * against Zeus AI owned by the server or a headless client they do nothing at
 * all, silently. This worked in SP and on a listen server (where the curator is
 * the host, so the AI is local) and nowhere else. Both branches below therefore
 * act as the unit only when it is local, and otherwise fall back to the
 * curator's own body as the actor.
 *
 * Requires the player to be an assigned curator with the Zeus display open
 * (guarded by the caller / keybind).
 *
 * Arguments:
 * 0: Unit or vehicle whose inventory to open — omitted resolves to the first
 *    selected man / vehicle from curatorSelected <OBJECT> (default: objNull)
 *
 * Return Value:
 * Press was handled (consumed) <BOOL>
 *
 * Example:
 * [_unit] call rtz_orders_fnc_openUnitInventory
 *
 * Public: No
 */

params [["_unit", objNull, [objNull]]];

// Zeus open, and not typing in the search box — the same preamble every other
// RTZ keybind handler carries. Previously inlined in the keybind body and
// missing the search-box test, so typing an "i" into ZEN's search field opened
// the gear dialog and swallowed the keystroke.
CHECK_CURATOR_INPUT;

// No explicit unit → take the first selected man or vehicle from the curator.
if (isNull _unit) then {
    private _objs = SELECTED_OBJECTS;
    private _i = _objs findIf { _x isKindOf "CAManBase" || { _x isKindOf "AllVehicles" } };
    if (_i > -1) then { _unit = _objs select _i };
};

if (isNull _unit) exitWith {
    [LLSTRING(MsgNoUnitSelected)] call zen_common_fnc_showMessage;
    true
};

// ── Vehicle: open its cargo through a crew member ───────────────────────────────
if !(_unit isKindOf "CAManBase") exitWith {
    private _veh  = _unit;
    private _crew = crew _veh;
    if (_crew isEqualTo []) exitWith {
        [LLSTRING(MsgNoCrew)] call zen_common_fnc_showMessage;
        true
    };
    // Acting AS the crewman needs him local (see the locality note in the header).
    // A vehicle is a plain container, so the fallback loses nothing: the curator
    // gets the same cargo, reached from his own body instead.
    private _actor = _crew select 0;
    if (local _actor) then {
        _actor actionNow ["Gear", _veh];
    } else {
        player action ["Gear", _veh];
    };

    // The crewman is the man doing the rummaging on either branch — the fallback
    // reaches the same cargo through the curator's own body, but it is still his
    // vehicle's gear being sorted.
    [_actor] call FUNC(keepGearAnimation);
    true
};

// ── Man: pre-select the nearest lootable container / body in front, then open ────
// nearestObjects returns nearest-first. Include CAManBase so corpses are lootable,
// but skip _unit itself and any living man (a living unit isn't a lootable target).
// objNull fallback → plain inventory: the engine auto-fills the Ground panel with
// real nearby items instead of echoing the unit's own worn gear.
private _checkPos = _unit getPos [1, getDir _unit];
private _nearby   = nearestObjects [_checkPos, ["ThingX", "AllVehicles", "CAManBase"], 5];
private _ti       = _nearby findIf { _x isNotEqualTo _unit && {!(_x isKindOf "CAManBase") || {!alive _x}} };
// if/else, NOT `[objNull, _nearby select _ti] select (_ti > -1)`: array literal
// elements are evaluated eagerly, so the miss case (_ti == -1 — nothing lootable
// in front of the unit, the common case) still ran `_nearby select -1` on the way
// to discarding it.
private _target   = if (_ti > -1) then { _nearby select _ti } else { objNull };

// Acting AS the unit gives the richest dialog — its own inventory on the left and
// everything within ITS reach on the right — but `action` is argument- and
// effect-local, so it needs the unit local. Where it is not, fall back to the
// curator's own body as the actor with the unit as the container (the ACE3
// "open inventory" recipe): the loadout is still fully editable, but the panels
// are the curator's gear and the unit's rather than the unit's and its surroundings.
if (local _unit) then {
    _unit action ["Gear", _target];
} else {
    player action ["Gear", _unit];
};

// The action plays the gear animation once and the unit's AI then takes the
// motion state back a second or two later, so the pose has to be kept up by hand
// for as long as the display is open. This is also what puts the animation on a
// REMOTE unit at all: the fallback branch above acts as the curator's own body,
// which leaves the unit standing there doing nothing.
[_unit] call FUNC(keepGearAnimation);

true
