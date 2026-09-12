#include "script_component.hpp"
/*
 * Author: Maxim
 * Memoized yes/no verdict about an ammo class, keyed by classname.
 *
 * Both detection halves ask CfgAmmo a different question — "is this a guided
 * missile" (FUNC(detectIncoming)) and "does this explode" (FUNC(detectGrenade)) —
 * and both ask it on a path that runs per shot, so neither may pay a configFile
 * read per event. The config answer for a class cannot change within a session, so
 * one lookup per class ever seen is the whole cost. The two shipped as verbatim
 * copies of each other; this is that code, once.
 *
 * The cache is passed IN rather than named here for two reasons: the two questions
 * must not share a key space, and a helper that picked the map for you would have to
 * branch on which caller it had.
 *
 * Arguments:
 * 0: Verdict cache <HASHMAP> — classname -> BOOL, cleared in place at the cap
 * 1: Ammo classname <STRING>
 * 2: Verdict block <CODE> — run on a cache MISS only, with the classname as `_this`;
 *    returns the verdict <BOOL>
 *
 * Return Value:
 * Verdict <BOOL>
 *
 * Example:
 * [GVAR(explosiveAmmo), _ammo, {
 *     (getNumber (configFile >> "CfgAmmo" >> _this >> "indirectHit")) > 0
 * }] call rtz_missile_fnc_ammoVerdict
 *
 * Public: No
 */

params ["_cache", "_ammo", "_block"];

// get + isNil, never getOrDefaultCall: that form hands the block [key, hashMap] as
// _this rather than the key, which is Gotchas §3's silently-poisoned-cache trap. A
// plain getOrDefault is no good either — the default would have to be the config
// read, and SQF evaluates it eagerly, so every hit would pay for the miss.
private _verdict = _cache get _ammo;

if (!isNil "_verdict") exitWith {_verdict};

if (count _cache > AMMO_CACHE_MAX) then {
    // Cleared IN PLACE, not by assigning a fresh createHashMap to _cache: this
    // function holds only a REFERENCE to the caller's global (Gotchas §3), so
    // rebinding the local would leave that global pointing at the full map and the
    // cap would never do anything again.
    //
    // `keys` hands back a fresh array, so deleting while walking it is safe.
    {_cache deleteAt _x} forEach keys _cache;
};

// `call` shares this scope (Gotchas §3), so the block must not declare _cache,
// _ammo, _verdict or _block. Both call sites read only _this.
_verdict = _ammo call _block;

_cache set [_ammo, _verdict];

_verdict
