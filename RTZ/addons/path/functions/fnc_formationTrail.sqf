#include "script_component.hpp"
/*
 * Author: Maxim
 * Draws the rest of the selection's paths behind the one being traced, so a
 * column is one gesture instead of six. Wargame's best idea, and its most
 * tangled code.
 *
 * A trailing path IS the leader's path, ending a fixed distance short of it —
 * so followers walk the line the curator actually drew, in order, spaced out
 * along it. Nothing is offset sideways: units that are meant to move in a
 * formation already do so through their group, and a hand-built lateral stagger
 * fights the AI's own formation keeping rather than adding to it.
 *
 * Only paths that have nothing of their own on them are recruited, and a path
 * stops trailing the moment its own handle is grabbed (FUNC(handleInput)). A
 * path somebody has drawn by hand is never overwritten.
 *
 * Kinds are not mixed. A helicopter trailing a rifleman's path by twelve metres
 * is not a formation, it is a crash.
 *
 * Arguments:
 * 0: Path being traced <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_path] call rtz_path_fnc_formationTrail
 *
 * Public: No
 */

params ["_leader"];

_leader params ["_leadUnit", "", "_leadPoints", "", "_leadKind"];

private _total = count _leadPoints;
if (_total == 0) exitWith {};

private _profile = GVAR(profiles) select _leadKind;

// The gap is authored in metres and applied in points, which is the unit the
// leader's path is actually made of
private _gap = (round ((_profile select PROF_FORMATION_GAP) / (_profile select PROF_SPACING))) max 1;

private _rank = 0;

{
    private _path = _x;

    if ((_path select PATH_UNIT) isEqualTo _leadUnit) then {continue};
    if ((_path select PATH_KIND) != _leadKind) then {continue};

    private _points = _path select PATH_POINTS;

    // Eligible if it is already trailing this leader, or if it is untouched.
    // Anything else belongs to the curator.
    private _trailing = (_path select PATH_LEADER) isEqualTo _leadUnit;
    if (!_trailing && {_points isNotEqualTo []}) then {continue};

    _rank = _rank + 1;

    // How much of the leader's path this follower has earned so far
    private _take = _total - (_rank * _gap);
    if (_take <= 0) then {continue};

    private _have = count _points;
    if (_have >= _take) then {continue};

    for "_i" from _have to (_take - 1) do {
        _points pushBack (_leadPoints select _i);
    };

    _path set [PATH_LEADER, _leadUnit];

    private _last = _points select -1;
    private _prior = if (count _points > 1) then {_points select -2} else {getPosASL (_path select PATH_HULL)};

    _path set [PATH_DIR, _prior getDir _last];
    _path set [PATH_HEAD, _last];

    if (_leadKind == KIND_AIR) then {
        _path set [PATH_ALT, format ["%1 m", round ((ASLToAGL _last) select 2)]];
    };
} forEach GVAR(paths);
