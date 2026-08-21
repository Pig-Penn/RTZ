#include "script_component.hpp"
/*
 * Author: Maxim
 * Names the movement animation a puppet should be playing to walk in one
 * direction while facing another, and the steering offset that goes with it.
 * Every step a scripted infantry path takes is this animation — walking
 * straight ahead is simply the case where the two directions agree — so this is
 * also what decides whether a path is walked, run or sprinted.
 *
 * Returns "" when there is no such animation, and the caller falls back to an
 * ordinary move order for that leg. That fallback is the reason this can afford
 * to be strict: a name that does not resolve costs the curator the strafe, not
 * the path. Wargame has no fallback — an unresolved name is played anyway and
 * the unit stands still with MOVE disabled for the rest of its route.
 *
 * Built from the naming convention, not searched for. Arma's man movement states
 * are composed:
 *
 *     Amov + Perc|Pknl|Ppne + Mrun|Mtac|Meva|Mwlk + Sras|Slow + Wrfl|Wpst|Wlnr|Wnon
 *          + D + f|fr|r|br|b|bl|l|fl
 *
 * so the name is ASSEMBLED, and the handful of pace/holding combinations that
 * could plausibly carry it are tried in preference order until one exists. The
 * posture, the weapon and the direction are known exactly and are never guessed;
 * only the two axes that vary by animation set are searched, and the whole search
 * is at most eight isClass reads, once per key, ever.
 *
 * Wargame instead walks InterpolateFrom / InterpolateTo / ConnectTo /
 * connectFrom four levels deep out of whatever the unit happens to be playing,
 * arrayIntersects the result, runs it through a nine-stage filter cascade and
 * takes the most frequent survivor — per unit, every time stance, speed mode, leg
 * damage or ground slope changes. On a squad crossing broken ground that is the
 * same hundred-line search several times a second, for an answer with four
 * inputs.
 *
 * PACE is the one axis with two rules, because the two gestures mean different
 * things. Walking forward is ordinary movement and takes its pace from the
 * group's speed mode, exactly as the unit's own AI would — a squad set to
 * Limited walks its path and one set to Normal runs it. A tactical span is a
 * deliberate slow advance covering an arc, so it prefers the tactical family,
 * which is also the family that reliably carries all eight directional variants.
 * A unit that cannot run — legs hit, forced walk — is walked whatever the group
 * is set to, which is Wargame's rule and a correct one.
 *
 * The answer is memoised. The key is exactly the four things that select it, so
 * the whole key space is stance x weapon x pace x direction and a mission fills
 * the useful part of it within the first few paths — including the misses, which
 * are cached as "" so an animation set that lacks a variant is asked about once
 * rather than once per leg.
 *
 * Arguments:
 * 0: Man <OBJECT>
 * 1: Direction of travel, degrees <NUMBER>
 * 2: Direction to face, degrees, or FACING_NONE to face the way it is going <NUMBER>
 *
 * Return Value:
 * 0: Animation state name, or "" when none exists <STRING>
 * 1: Steering offset for that direction, degrees <NUMBER>
 *
 * Example:
 * ([_unit, _legDir, _facing] call rtz_path_fnc_moveAnimation) params ["_anim", "_offset"]
 *
 * Public: No
 */

params ["_unit", "_moveDir", "_faceDir"];

// No fixed facing: the man walks looking where he is going, which is sector 0
// and a zero offset. Short-circuited rather than left to the arithmetic below so
// the ordinary leg of an ordinary path — by far the commonest call there is —
// never derives a sector it already knows.
private _tactical = _faceDir != FACING_NONE;
private _sector = 0;

if (_tactical) then {
    // Which 45-degree sector the direction of travel falls in relative to the way
    // the unit is facing. The +22.5 centres each sector on its own heading, so
    // "straight ahead" spans 22.5 either side of dead ahead rather than starting
    // there.
    _sector = (floor ((((_moveDir - _faceDir + 360) % 360) + 22.5) / 45)) % 8;
};

(GVAR(animDirections) select _sector) params ["_suffix", "_offset"];

// The steering offset is the SECTOR plus the table's correction, never the
// correction on its own. The table only says how far a given strafe animation
// displaces the model off its own nose; turning that into "where the nose has to
// point for the strafe to travel down this leg" needs the sector the leg falls
// in as well. Wargame builds it the same way, in one line:
//
//     _facingDirMod = ((_index * 45) mod 360) + (jack_animationDirectionArr # _index # 1)
//
// Dropping the sector term leaves sector 0 — walking straight ahead — the only
// direction that aims correctly, because it is the only one whose term is zero.
// Every other sector walks its span facing between 45 and 180 degrees off, which
// is the whole of the tactical-move feature aiming at the wrong thing.
_offset = ((_sector * 45) + _offset) % 360;

// `stance` answers "UNDEFINED" for a unit in a transitional pose, which falls
// through to standing — the right guess, and the one with the fullest animation
// set behind it.
private _stance = stance _unit;

private _posture = switch (_stance) do {
    case "CROUCH": {"Pknl"};
    case "PRONE": {"Ppne"};
    default {"Perc"};
};

// Which of the three weapon slots is in hand, if any. An empty or unrecognised
// weapon is Wnon, which has its own (smaller) animation set — and if no
// directional variant exists there, the search below comes back empty and the
// leg degrades to an ordinary move.
private _current = currentWeapon _unit;
private _slot = WEAPON_IN_HAND(_unit,_current);
private _weapon = if (_slot == -1) then {
    "Wnon"
} else {
    ["Wrfl", "Wpst", "Wlnr"] select _slot
};

// Pace, as one of three preference orders rather than a single name — see the
// header. A man who cannot run is walked whatever his group is set to, and a
// prone man has no run in his set at all, so both collapse onto the slow order.
private _slow = _stance isEqualTo "PRONE"
    || {isForcedWalk _unit}
    || {(_unit getHit "legs") > 0.5}
    || {(speedMode (group _unit)) isEqualTo "LIMITED"};

private _paces = switch (true) do {
    case (_tactical): {["Mtac", "Meva", "Mwlk", "Mrun"]};
    case (_slow): {["Mwlk", "Mtac", "Meva", "Mrun"]};
    default {["Mrun", "Meva", "Mtac", "Mwlk"]};
};

// Everything that selects the animation, and nothing that does not — so two
// riflemen in the same stance at the same pace moving the same way share one
// entry. The pace goes in as the whole ORDER's first name, which is what
// actually varies: three orders, three key prefixes.
private _key = (_paces select 0) + _posture + _weapon + _suffix;

private _cached = GVAR(animCache) get _key;
if (!isNil "_cached") exitWith {[_cached, _offset]};

// A prone soldier's weapon is low by definition, so that holding is tried first
// for him and second for everyone else — rather than assumed either way, which
// is how a whole stance quietly loses the feature when one animation set spells
// it the other way round.
private _holdings = if (_stance isEqualTo "PRONE") then {["Slow", "Sras"]} else {["Sras", "Slow"]};

// The unit's own move set, not CfgMovesMaleSdr by name: a modded or non-standard
// man class points at a different one, and asking the config which it uses is the
// difference between "this animation does not exist" and "I looked in the wrong
// place".
private _moves = configFile >> (getText (configOf _unit >> "moves")) >> "States";

private _name = "";

{
    // Tested at the TOP of the body — a `break` at the bottom still pays for the
    // iteration it is meant to skip (Gotchas §2). And `break`, not `exitWith`:
    // inside a loop body `exitWith` is a `continue`, so the search would run on
    // and the LAST match would overwrite the best one instead of the first.
    if (_name isNotEqualTo "") then {break};

    private _pace = _x;
    {
        if (_name isNotEqualTo "") then {break};

        private _candidate = format ["Amov%1%2%3%4D%5", _posture, _pace, _x, _weapon, _suffix];
        if (isClass (_moves >> _candidate)) then {
            _name = _candidate;
        };
    } forEach _holdings;
} forEach _paces;

// Bounded, because a HashMap that only ever grows is a leak on a multi-hour
// operation (CLAUDE.md). Cleared rather than evicted one at a time: the key space
// is small enough that reaching the cap at all means something unexpected is
// generating keys, and starting over costs one config read per live combination.
if (count GVAR(animCache) >= ANIM_CACHE_MAX) then {
    GVAR(animCache) = createHashMap;
};

GVAR(animCache) set [_key, _name];

[_name, _offset]
