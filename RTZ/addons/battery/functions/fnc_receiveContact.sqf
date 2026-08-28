#include "script_component.hpp"
/*
 * Author: Maxim
 * Curator client: folds one contact packet into the store. Receiver for
 * QGVAR(contact), which the server targets at each hostile curator.
 *
 * The origin circle and the incoming ring arrive in the same packet and share a
 * track, so they are ONE record rather than two identically-keyed maps — one
 * lookup, one walk, one prune, one cap, instead of two of each. A record whose
 * incoming half has expired simply fails a float compare in FUNC(drawMap) and draws
 * nothing.
 *
 * The static half of the label is built HERE and not in the renderer. It changes
 * only when the round count does, which is at most once per SEND_INTERVAL, whereas
 * the renderer runs every frame the Zeus map is open — and a `format` per contact
 * per frame on a mission running for hours is exactly the per-entity-per-tick string
 * allocation CLAUDE.md rules out. What is left for the frame path is the age, which
 * FUNC(contactLabel) rebuilds only when the displayed second changes.
 *
 * The store keeps filling while the overlay is hidden: only the Draw handler is
 * detached (FUNC(startDisplay)), so switching the overlay back on shows the live
 * picture rather than starting again from the next shot.
 *
 * Arguments:
 * 0: Track id — opaque, server-issued; NOT the gun's netId <NUMBER>
 * 1: Offset circle centre <ARRAY>
 * 2: Offset circle radius <NUMBER>
 * 3: Time of the track's first round <NUMBER>
 * 4: Time of its most recent round <NUMBER>
 * 5: Rounds counted <NUMBER>
 * 6: Gun display name <STRING>
 * 7: Incoming circle centre, [] when unknown <ARRAY>
 * 8: Incoming circle radius <NUMBER>
 * 9: Estimated splash time <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [3, _centre, 250, 900, 940, 7, "Mk6 Mortar", _inc, 150, 962] call rtz_battery_fnc_receiveContact
 *
 * Public: No
 */

params ["_trackId", "_centre", "_radius", "_firstTime", "_lastTime", "_rounds",
        "_name", "_incCentre", "_incRadius", "_splashTime"];

// Record:
//  0 centre | 1 radius | 2 firstTime | 3 lastTime | 4 rounds | 5 prefix
//  6 cachedText | 7 cachedAgeSec | 8 incCentre | 9 incRadius | 10 splashTime
//
// cachedAgeSec starts at -1, a value floor() of a non-negative age can never
// produce, so the first draw always builds a label rather than showing an empty
// string for up to a second.
GVAR(contacts) set [_trackId, [
    _centre, _radius, _firstTime, _lastTime, _rounds,
    format [LLSTRING(ContactPrefix), _name, _rounds],
    "", -1,
    _incCentre, _incRadius, _splashTime
]];

// Lowered only, never raised. A refreshed record's real expiry moves LATER, so a
// cached value that is now too early is harmless: the prune it triggers finds
// nothing to drop and recomputes the true minimum. Raising it here from one
// record's expiry would be the dangerous direction — it could sail past another
// record's and leave that one drawn forever.
private _expiry = _lastTime + GVAR(contactLifetime);
if (_expiry < GVAR(nextExpiry)) then {
    GVAR(nextExpiry) = _expiry;
};

// Same cap treatment as the server registry: entered only while over the line, and
// the oldest goes rather than the newest being refused.
if (count GVAR(contacts) <= CONTACT_CAP) exitWith {};

private _oldestKey = -1;
private _oldest = 1e11;
{
    private _t = _y # 3;
    if (_t < _oldest) then {
        _oldest = _t;
        _oldestKey = _x;
    };
} forEach GVAR(contacts);

if (_oldestKey < 0) exitWith {};

GVAR(contacts) deleteAt _oldestKey;
