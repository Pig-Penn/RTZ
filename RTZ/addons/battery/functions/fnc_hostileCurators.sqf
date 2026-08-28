#include "script_component.hpp"
/*
 * Author: Maxim
 * The player objects of every manned curator hostile to a given side — the
 * CBA_fnc_targetEvent destinations for one contact. Server-side: curator modules
 * are server-local, so this returns nothing meaningful anywhere else.
 *
 * Split out because it has two callers with opposite needs. FUNC(dispatchContact)
 * runs it on a COLD contact to answer "is anyone watching?" before it writes a
 * track — a track nobody can see is state that only has to be pruned later — and
 * FUNC(sendContact) runs it again at flush time, because a curator can connect,
 * leave or change side between a track's first round and its last.
 *
 * isPlayer, NOT isNull. A playable Zeus slot whose player has left keeps returning
 * a non-null, server-local, non-player body from getAssignedCuratorUnit; its
 * `owner` is 2, so a contact routed there goes to the SERVER — a silent no-op on a
 * dedicated server, but on a listen server the host has the receiver registered and
 * would draw a departed curator's contacts as its own. isPlayer objNull is false,
 * so this subsumes the null check. Same trap, same fix, as
 * EFUNC(spotting,collectSides) (Gotchas §5).
 *
 * Arguments:
 * 0: Side that fired <SIDE>
 *
 * Return Value:
 * Curator player objects hostile to that side <ARRAY of OBJECT>
 *
 * Example:
 * [east] call rtz_battery_fnc_hostileCurators
 *
 * Public: No
 */

params ["_firerSide"];

private _watchers = [];

{
    private _player = getAssignedCuratorUnit _x;
    if (!isPlayer _player) then { continue };
    // getFriend is a relation between two sides, not a property of either, and the
    // mod's hostility line is 0.5 everywhere (EFUNC(attack,findTarget),
    // EFUNC(captive,captureTick), EFUNC(spotting,spotCheck)).
    if ((side _player) getFriend _firerSide >= HOSTILE_THRESHOLD) then { continue };

    // Two curators on the same side both watch, and each gets its own packet —
    // they are separate clients with separate stores.
    _watchers pushBackUnique _player;
} forEach allCurators;

_watchers
