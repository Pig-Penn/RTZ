#include "script_component.hpp"
/*
 * Author: Maxim
 * Curator client half: turns one reported threat — of EITHER kind — into a
 * draw-ready record in GVAR(tracked). Receiver for QGVAR(track), which the server
 * targets at each entitled curator.
 *
 * One receiver, because once each report function has answered its own ownership
 * question there is nothing left that differs: the payload carries REC_KIND and the
 * record is built the same way. The two receivers this replaces had already drifted
 * apart on colour — the missile half sent a SIDE and resolved the palette here, the
 * grenade half resolved it on the SERVER and shipped four floats to every curator.
 * Sending the side is the smaller payload, the single code path, and the one that
 * lets a client-side palette edit apply.
 *
 * The two kinds differ only in what the record's clock means:
 *   - a MISSILE tracks its projectile, so the expiry starts at FALLBACK_DURATION and
 *     FUNC(pruneTracked) promotes it to MISSILE_TIMEOUT the first frame the
 *     projectile resolves on this machine;
 *   - a GRENADE tracks nothing. Its marker is STATIC at the aim point ZEN was given,
 *     so it carries objNull in both object slots, never becomes "seen", and simply
 *     rides GRENADE_DURATION out.
 *
 * Arguments:
 * 0: Projectile — objNull for a grenade <OBJECT>
 * 1: Target — objNull for a grenade <OBJECT>
 * 2: Attacker's side <SIDE>
 * 3: Kind, KIND_MISSILE or KIND_GRENADE <NUMBER>
 * 4: Fallback anchor ASL — the grenade's aim point; omitted for a missile, which
 *    falls back to its target instead <ARRAY> (default: [])
 *
 * Return Value:
 * None
 *
 * Example:
 * [_missile, _target, east, KIND_MISSILE] call rtz_missile_fnc_receiveTrack
 *
 * Public: No
 */

params ["_projectile", "_target", "_side", "_kind", ["_fallback", []]];

// KIND-AWARE, and it has to be. A missile with no target has nothing to draw and
// nothing to fall back to, so it is dropped. A grenade legitimately has none — its
// anchor is _fallback — so the bare `if (isNull _target) exitWith {}` that the
// missile-only receiver carried would have silently dropped EVERY grenade warning
// here the moment the two were folded together.
if (_kind == KIND_MISSILE && {isNull _target}) exitWith {};

// A shared, read-only reference into rtz_common's palette. It is ALREADY [r, g, b, 1]
// (EFUNC(common,sideColor)), so it is stored and later handed to the draw commands
// as-is — which is what lets both draw passes stop rebuilding an identical array per
// record per frame.
//
// Anything that ever wants a varying alpha must build a COPY (`_rgb + [_a]`).
// Writing into this array would repaint every marker of that side across the mod.
private _color = [_side] call EFUNC(common,sideColor);

// Branch rather than `[FALLBACK_DURATION, GRENADE_DURATION] select _kind`, which
// would build a throwaway array. Once per event rather than per frame, but the rule
// stays uniform across the component.
private _life = FALLBACK_DURATION;
if (_kind == KIND_GRENADE) then {_life = GRENADE_DURATION};

GVAR(tracked) pushBack [_projectile, _target, _color, CBA_missionTime + _life, false, _kind, _fallback];

// Records are appended in arrival order, so the oldest is always index 0. The oldest
// goes rather than the new one being refused: a warning the curator has already had
// several seconds to read is the cheaper thing to lose.
if (count GVAR(tracked) > TRACK_CAP) then {
    GVAR(tracked) deleteAt 0;
};
