#include "script_component.hpp"
/*
 * Author: Maxim
 * Turns the drawn session into orders. Runs on the curator's client, which is
 * where the paths were drawn and the only machine that has them.
 *
 * One TARGETED event per unit, not a broadcast. Wargame remoteExecs its executor
 * to everyone and has each machine test locality and discard, so a thirty-unit
 * plan costs every client in the session thirty payloads to throw away; here the
 * only machine that hears about a path is the one that will run it.
 *
 * Each path is resampled by FUNC(reducePath) before it goes out, at whichever
 * of the profile's two spacings the executor that will receive it can use — a
 * doMove chain wants legs the AI can navigate between, a scripted executor wants
 * every corner the curator drew. What crosses the wire is a few dozen legs
 * either way, not the several hundred points the line on screen was drawn from.
 *
 * A path whose ends meet commits as a PATROL and cycles instead of stopping.
 * Decided by FUNC(isPatrol) here rather than on the far side so the executor is
 * handed a decision rather than a heuristic — and so the two ends are compared
 * while both are still in the space they were drawn in. Both renderers ask the
 * same function while the path is being traced, which is what lets a curator see
 * a circuit close before committing it.
 *
 * Routability is re-checked immediately before ordering. A session can stay open
 * for minutes, and FUNC(planTick) prunes on a half-second stagger, so the last
 * word on whether a unit can still be ordered belongs here.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Paths ordered <NUMBER>
 *
 * Example:
 * private _n = call rtz_path_fnc_commitPaths
 *
 * Public: No
 */

private _ordered = 0;

// Which executor each kind will land on, read ONCE for the whole commit. Both
// settings are global, so this agrees with what FUNC(startFollow) will decide
// where the unit is local — and it has to, because the executor is what selects
// the resampling distance below. A path resampled for the AI's navigation and
// then walked literally is a path with its corners already gone.
private _scriptedFoot = GETGVAR(infantryExecutor,EXEC_SCRIPTED) == EXEC_SCRIPTED;
private _scriptedFlight = GETGVAR(scriptedFlight,true);

{
    _x params ["_unit", "_hull", "_points", "", "_kind"];

    // A path nobody drew anything on is not an order to stand still
    if (_points isEqualTo []) then {continue};
    if ([_hull] call FUNC(pathKind) == KIND_NONE) then {continue};

    private _scripted = switch (_kind) do {
        case KIND_INFANTRY: {_scriptedFoot};
        case KIND_AIR;
        case KIND_BOAT: {_scriptedFlight};
        default {false};
    };

    private _profile = GVAR(profiles) select _kind;
    private _spacing = _profile select ([PROF_COMMIT_SPACING, PROF_SCRIPTED_SPACING] select _scripted);

    ([_points, _spacing] call FUNC(reducePath)) params ["_legs", "_indices"];

    // Facing spans are stored against the DRAWN points, so resampling moves the
    // ground out from under them: a span starting at drawn point 180 has to
    // become a span starting at whichever leg first covers it. Remapped here,
    // where both index lists are in hand, rather than shipped raw and remapped
    // on every machine that receives one.
    private _facing = [];
    {
        _x params ["_at", "_azimuth"];

        // The first surviving leg at or past where the span began. -1 means the
        // span started inside the tail that resampling collapsed into the final
        // point, so there is no leg left for it to apply to.
        private _leg = _indices findIf {_x >= _at};
        if (_leg == -1) then {continue};

        // Two spans can land on one leg once the path between them is gone. The
        // later one is the more recent instruction and wins, rather than both
        // being kept and the first silently shadowing the second.
        if (_facing isNotEqualTo [] && {(_facing select -1 select 0) == _leg}) then {
            _facing set [(count _facing) - 1, [_leg, _azimuth]];
        } else {
            _facing pushBack [_leg, _azimuth];
        };
    } forEach (_x select PATH_FACING);

    // Closed and long enough to be a circuit rather than a scribble
    private _patrol = [_points] call FUNC(isPatrol);

    [QGVAR(follow), [_unit, _hull, _legs, _kind, _patrol, _facing], _unit] call CBA_fnc_targetEvent;

    _ordered = _ordered + 1;
} forEach GVAR(paths);

_ordered
