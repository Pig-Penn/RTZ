#include "script_component.hpp"
/*
 * Author: Maxim
 * Fires the engine's own service actions on every target this machine owns.
 *
 * This is the whole apply path of the component. Everything else — the context
 * action, the claims, the job, the overlay — exists to decide when these three
 * lines run and to show that they did. The engine performs the repair, the refuel
 * and the rearm, and consumes the source's getRepairCargo / getFuelCargo /
 * getAmmoCargo doing it, which is where the depletion model comes from: this
 * component never writes a supply level.
 *
 * It replaced a hand-rolled simulation — a per-tick setDamage/setFuel ramp plus
 * one setVehicleAmmo 1 at the end — which could not deplete a truck at all, and
 * had to re-derive the whole notion of a full magazine from config just to know
 * when it was finished.
 *
 * LOCALITY. `action` and `actionNow` take a LOCAL argument. FUNC(serviceVehicles)
 * sends QGVAR(service) with the whole target ARRAY as the CBA target, so it is
 * delivered once per owning machine and this filters to what that machine holds —
 * the same shape rtz_smoke's deploy order uses, and one packet instead of one per
 * target. Calling these from the server against a vehicle it does not own is a
 * silent no-op with no error and no log line, which is exactly how the old setFuel
 * bug survived for the life of the component (docs/Knowledge Base/Gotchas.md,
 * "Argument-local vs argument-global").
 *
 * actionNow rather than action: `action` plays the full animation, and these are
 * issued against AI in the field — often a crewed hull with no animation to play —
 * where a queued animated action can simply be dropped. actionNow performs it
 * immediately and is the form both LAMBS and VCOM reach for when scripting a
 * unit's rearm.
 *
 * TWO PROPERTIES OF actionNow THIS COMPONENT IS BUILT ON, both verified in game
 * and neither obvious from the scroll-menu behaviour they look like:
 *
 *  — NO DISTANCE LIMIT. The scroll action a player uses has a supply radius; this
 *    scripted form does not, and will service a target at any range. Nothing here
 *    therefore has to be moved to the truck first, and GVAR(serviceRadius) is
 *    purely RTZ's own policy about what one order picks up — not a constraint the
 *    engine would enforce for us.
 *  — THE WHOLE VEHICLE IS FILLED. One Rearm covers every turret, not just the one
 *    whose occupant acts, so there is no per-turret loop and no reason to resolve a
 *    crewman as the actor. The hull is the caller.
 *
 * Fired ONCE per order, never per tick and never retried. The engine performs the
 * service or declines it — it declines silently once the source's store is spent —
 * and re-sending cannot change either answer. FUNC(serviceTick) watches the work
 * fail to happen instead, which is how a dry truck is detected.
 *
 * Arguments:
 * 0: Supply Vehicle <OBJECT>
 * 1: Targets <ARRAY of OBJECT>
 * 2: Supply Capabilities <ARRAY> — [canRepair, canRefuel, canRearm]
 *
 * Return Value:
 * None
 *
 * Example:
 * [_truck, [_tank], [true, true, true]] call rtz_supply_fnc_applyService
 *
 * Public: No
 */

params ["_supply", "_targets", "_capabilities"];

if (isNull _supply) exitWith {};

_capabilities params ["_canRepair", "_canRefuel", "_canRearm"];

{
    if (isNull _x || {!alive _x} || {!local _x}) then { continue };

    if (_canRepair) then {
        _x actionNow ["Repair", _supply];
    };

    if (_canRefuel) then {
        _x actionNow ["Refuel", _supply];
    };

    if (_canRearm) then {
        _x actionNow ["Rearm", _supply];
    };
} forEach _targets;
