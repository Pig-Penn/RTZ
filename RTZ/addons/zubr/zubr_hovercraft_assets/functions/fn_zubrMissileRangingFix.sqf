#include "\x\rtz\addons\zubr\script_component.hpp"
/*
 * Author: Chair (CUP Vehicles), unscheduled by Maxim
 * Workaround fix for the Ogon's manual ranging through weapon firemodes: the
 * rocket is zeroed to fall at 4000 m, so the three shorter firemodes scale its
 * velocity down once the booster has burnt out.
 *
 * Reached from the `fired` event handler in CfgVehicles.hpp, which is why it keeps
 * CUP's name and its CfgFunctions registration (see CfgFunctions.hpp).
 *
 * UNSCHEDULED. CUP `spawn`s this for a bare `sleep 1.1`. A spawned scope gets
 * roughly 3 ms a frame across every scheduled script and is resumed whenever the
 * scheduler gets back to it, so under load the "1.1 seconds" the whole fix is
 * calibrated against is whatever the scheduler decides — and a salvo spawns one
 * such script per rocket. CBA_fnc_waitAndExecute keeps the delay and drops the
 * scope (docs/Knowledge Base/Gotchas.md §1).
 *
 * The projectile is RE-VALIDATED AFTER the wait, not only before it. CUP tests
 * `local _missile` on the way in and then suspends for over a second, which is
 * ample time for the rocket to hit something and be deleted; `velocity objNull` is
 * [0,0,0] and `setVelocity` on a null object is a no-op, so the original degrades
 * quietly rather than erroring — but it is still the wrong side of the wait. So is
 * the locality test: setVelocity is argument-local, and what matters is who owns
 * the projectile when the write happens.
 *
 * The fire_4000 case is also settled BEFORE the wait now. It is the default
 * zeroing and needs no adjustment at all, so there is nothing to schedule — CUP
 * suspended for 1.1 s and read the velocity back before discovering that.
 *
 * Arguments:
 * 0: Vehicle <OBJECT>
 * 1: Firemode <STRING>
 * 2: Projectile <OBJECT>
 * 3: Projectile type that should be adjusted <STRING>
 *
 * Return Value:
 * Whether an adjustment was scheduled <BOOL> — not whether one was applied, which
 * is not known until the wait elapses
 *
 * Example:
 * [_vehicle, _firemode, _missile, "MissileBase"] call rtz_zubr_fnc_zubrMissileRangingFix
 *
 * Public: No
 */

params ["_vehicle", "_firemode", "_missile", "_type"];

if !(local _missile) exitWith {false};
if !(_missile isKindOf _type) exitWith {false};

// Zeroed according to missile thrust. fire_4000 is the round's own default
// trajectory and takes no factor, so it never reaches the wait below.
private _factor = switch (toLower _firemode) do {
    case "fire_3000": {0.78};
    case "fire_2000": {0.57};
    case "fire_1000": {0.33};
    default {0};
};

if (_factor == 0) exitWith {false};

// Small pause to wait for the rocket booster to run out
[{
    params ["_missile", "_factor"];

    // The world moved on: over a second is long enough for the rocket to have
    // detonated, been deleted, or changed hands.
    if (isNull _missile || {!local _missile}) exitWith {};

    _missile setVelocity ((velocity _missile) vectorMultiply _factor);
}, [_missile, _factor], MISSILE_RANGING_DELAY] call CBA_fnc_waitAndExecute;

true
