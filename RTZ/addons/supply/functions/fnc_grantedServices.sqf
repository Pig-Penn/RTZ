#include "script_component.hpp"
/*
 * Author: Maxim
 * Which of a supply vehicle's services are actually available to it against one
 * target — its own capabilities minus the slots another live truck currently
 * holds. The whole of the per-service claim model reads through here.
 *
 * A claim slot is free when nobody holds it, the holder is THIS supply vehicle (a
 * repeat order supersedes its own job rather than being blocked by it), the holder
 * is dead, or the claim has simply run out. Identical rules to the single exclusive
 * claim this replaced — applied three times, once per service, instead of once for
 * the whole vehicle.
 *
 * That is what lets a repair truck and a fuel truck service one damaged, empty tank
 * together, which the exclusive claim made impossible: the two contended for a
 * single lock despite carrying nothing in common, and the loser was dropped from
 * the order entirely.
 *
 * Called from BOTH sides — FUNC(serviceProviders) on the curator's client to decide
 * what the cursor offers, and FUNC(serviceVehicles) on the server to decide what is
 * actually taken. The client's answer is advisory (it is a network hop stale by the
 * time it lands); the server's is authoritative.
 *
 * Arguments:
 * 0: Target <OBJECT>
 * 1: Supply Vehicle <OBJECT>
 * 2: Supply Capabilities <ARRAY> — [canRepair, canRefuel, canRearm]
 *
 * Return Value:
 * Granted Services <ARRAY> — [canRepair, canRefuel, canRearm], a subset of the input
 *
 * Example:
 * [_tank, _truck, [true, false, true]] call rtz_supply_fnc_grantedServices
 *
 * Public: No
 */

params ["_target", "_supply", "_capabilities"];

private _claim = _target getVariable [QGVAR(claim), []];

// Nothing claimed on this target at all: the common case, and it needs no walk.
if (_claim isEqualTo []) exitWith { _capabilities };

private _now = CBA_missionTime;
private _granted = [false, false, false];

{
    // Tested at the TOP with `continue`, which is what it means here — this skips
    // one service, not the loop (docs/Knowledge Base/Gotchas.md §2).
    if (!_x) then { continue };

    (_claim param [_forEachIndex, []]) params [["_by", objNull], ["_expires", 0]];

    if (isNull _by || {_by isEqualTo _supply} || {!alive _by} || {_now >= _expires}) then {
        _granted set [_forEachIndex, true];
    };
} forEach _capabilities;

_granted
