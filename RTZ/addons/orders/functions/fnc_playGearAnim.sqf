#include "script_component.hpp"
/*
 * Author: Maxim
 * Plays one beat of the gear animation on a man. Runs where the man is local —
 * playActionNow is argument-local. Called both to start a session and from the
 * AnimDone handler that keeps it going, so every rule about WHEN the animation
 * may play lives here and nowhere else.
 *
 * The beat is short by design and carries no state of its own: continuity comes
 * from AnimDone landing the next beat the instant this one ends, not from any one
 * play lasting. Anything that delays or skips a beat therefore shows up directly
 * as a visible gap — which is why the only test below is a spin guard.
 *
 * playActionNow rather than a named animation state: the engine picks the gear
 * animation matching the man's current stance and weapon, so this stays correct
 * for a kneeling man, a pistol carrier or an unarmed one. Hard-coding a state
 * (ZEN's ambient-animation module does, because it is choosing a specific pose)
 * would break all three.
 *
 * Arguments:
 * 0: Man to animate <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit] call rtz_orders_fnc_playGearAnim
 *
 * Public: No
 */

params ["_actor"];

// Never animate a corpse — playActionNow snaps a dead man out of his ragdoll and
// stands him back up (the same trap EFUNC(repair,finishRepair) guards).
if (!alive _actor) exitWith {};

// NO test on whether the man is moving. One lived here and it was the whole bug:
// AnimDone fires as the gear animation ENDS, and by that instant a man under a
// move order has already resumed walking — so a speed test reads him as moving
// and skips the very replay that was supposed to be seamless. The animation then
// only restarted on the chance moments his speed dipped, which is exactly the
// "plays, stops, moves for a second, plays again" cycle. The animation is meant
// to interrupt his stride; that is what makes it continuous. He is free to move
// between beats, and the next beat lands the moment this one ends.
//
// A floor on the gap, purely so a rejected animation cannot spin this handler as
// fast as the engine raises AnimDone. Kept well below the eye's threshold: it is
// a safety valve, not a pacing control, and anything large enough to notice would
// reintroduce the gap this function exists to close.
private _last = _actor getVariable [QGVAR(gearAnimLast), -1];
if (CBA_missionTime - _last < GEAR_ANIM_MIN_GAP) exitWith {};

_actor setVariable [QGVAR(gearAnimLast), CBA_missionTime];
_actor playActionNow "Gear";
