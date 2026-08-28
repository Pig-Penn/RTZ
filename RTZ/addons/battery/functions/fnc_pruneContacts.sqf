#include "script_component.hpp"
/*
 * Author: Maxim
 * Drops expired contacts and recomputes GVAR(nextExpiry) — the earliest expiry left
 * in the store, which is what lets FUNC(drawMap) skip this walk on almost every
 * frame with a single float compare.
 *
 * That gate is the whole point of this being a separate function. A prune run per
 * frame is a two-field walk over the store on every frame the Zeus map is open, for
 * the length of a multi-hour operation, to free something that expires once every
 * five minutes. Caching the next deadline turns it into one comparison.
 *
 * Expired keys are collected and deleted AFTER the walk, never during it: deleting
 * from a HashMap while iterating over it is not safe.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_battery_fnc_pruneContacts
 *
 * Public: No
 */

private _now = CBA_missionTime;
private _lifetime = GVAR(contactLifetime);
private _cutoff = _now - _lifetime;

private _dead = [];
private _next = 1e11;

{
    private _last = _y # 3;

    if (_last < _cutoff) then {
        _dead pushBack _x;
    } else {
        private _expiry = _last + _lifetime;
        if (_expiry < _next) then { _next = _expiry };
    };
} forEach GVAR(contacts);

{
    GVAR(contacts) deleteAt _x;
} forEach _dead;

// 1e11 when the store is empty — a time no mission reaches, so the compare in
// FUNC(drawMap) simply never fires again until something is received.
GVAR(nextExpiry) = _next;
