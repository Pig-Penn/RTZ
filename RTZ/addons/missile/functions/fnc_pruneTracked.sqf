#include "script_component.hpp"
/*
 * Author: Maxim
 * Ages GVAR(tracked) and promotes records whose projectile has resolved. Called at
 * the top of whichever draw pass is running — only one of the two ever runs on a
 * given frame, since rtz_core skips RENDER_WORLD renderers while the Zeus map
 * covers the 3D view — so this is one walk per frame over at most TRACK_CAP
 * records, and none at all in the normal case of an empty list.
 *
 * It lives outside the draw passes so the two can never disagree about when a
 * track dies.
 *
 * A MISSILE track ends one of three ways:
 *   - its projectile was seen and has since gone null: it detonated or was deleted;
 *   - its projectile was never seen on this machine and the short fallback window
 *     has run out;
 *   - MISSILE_TIMEOUT, the ceiling that stops a projectile which somehow never
 *     nulls from living for the rest of a multi-hour mission.
 *
 * A GRENADE track never enters the promotion path at all. Its marker is STATIC at
 * the aim point, so it carries objNull in REC_MISSILE and false in REC_SEEN for its
 * whole life: it takes the isNull branch below, is left alone there, and dies on the
 * expiry test at GRENADE_DURATION. That is the entire static-marker behaviour, and
 * no branch here has to know about it — which is what let the two-timeout branch
 * that used to live at the bottom of this function go away.
 *
 * Walked backwards so deleting an entry cannot shift one that has not been visited
 * yet.
 *
 * Arguments:
 * 0: Current time, CBA_missionTime <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [CBA_missionTime] call rtz_missile_fnc_pruneTracked
 *
 * Public: No
 */

params ["_now"];

private _tracked = GVAR(tracked);

for "_i" from (count _tracked) - 1 to 0 step -1 do {
    private _record = _tracked select _i;

    if (_now > (_record select REC_EXPIRY)) then {
        _tracked deleteAt _i;
        continue;
    };

    private _missile = _record select REC_MISSILE;

    if (isNull _missile) then {
        // Seen before and null now means the flight is over. Never seen means either
        // a missile whose projectile is not a network object on this machine — the
        // fallback marker rides the threatened unit until the expiry above catches
        // it — or a grenade, which is never anything else and rides its aim point.
        if (_record select REC_SEEN) then {
            _tracked deleteAt _i;
        };

        continue;
    };

    if !(_record select REC_SEEN) then {
        _record set [REC_SEEN, true];

        // MISSILE_TIMEOUT unconditionally: a grenade record's REC_MISSILE is objNull
        // for its whole life, so it always takes the branch above and this line is
        // unreachable for KIND_GRENADE.
        _record set [REC_EXPIRY, _now + MISSILE_TIMEOUT];
    };
};
