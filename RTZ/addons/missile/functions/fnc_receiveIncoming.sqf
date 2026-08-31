#include "script_component.hpp"
/*
 * Author: Maxim
 * Curator client half: turns a reported launch into a draw-ready track record.
 *
 * The one thing the draw passes would otherwise redo per record per frame — the
 * side colour — is baked here, once. The marker carries no text: it is an icon on
 * a projectile with a line to the unit it is chasing, and a word next to it added
 * nothing a curator could not already see.
 *
 * The expiry starts at FALLBACK_DURATION rather than MISSILE_TIMEOUT: until the
 * projectile has actually been seen on this machine the record is only worth the
 * short "something is incoming at this unit" fallback marker. FUNC(pruneTracked)
 * promotes it the first frame the projectile resolves.
 *
 * Arguments:
 * 0: Projectile <OBJECT>
 * 1: Target <OBJECT>
 * 2: Shooter's side <SIDE>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_missile, _target, east] call rtz_missile_fnc_receiveIncoming
 *
 * Public: No
 */

params ["_missile", "_target", "_side"];

if (isNull _target) exitWith {};

// A shared, read-only reference into rtz_common's palette — the draw passes build
// their own [r, g, b, a] rather than writing into it.
private _color = [_side] call EFUNC(common,sideColor);

GVAR(tracked) pushBack [_missile, _target, _color, CBA_missionTime + FALLBACK_DURATION, false];

// Records are appended in arrival order, so the oldest is always index 0. The
// oldest goes rather than the new one being refused: a warning the curator has
// already had several seconds to read is the cheaper thing to lose.
if (count GVAR(tracked) > TRACK_CAP) then {
    GVAR(tracked) deleteAt 0;
};
