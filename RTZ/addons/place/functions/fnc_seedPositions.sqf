#include "script_component.hpp"
/*
 * Author: Maxim
 * Where each unit's ghost starts: the selection's own formation shape, laid down
 * around the point the curator is aiming at. The opening state of a session, and
 * on its own the whole of the "tap, tap" fast path.
 *
 * THE HEIGHT RULE IS THE INDOOR FIX. Each unit's x/y is the cursor's x/y plus
 * that unit's offset from the selection centre — the formation-preserving
 * arithmetic the one-shot teleport already did. What changed is how the height
 * at that offset is chosen:
 *
 *   old: the HIGHEST mostly-flat surface in the column
 *   new: the surface in the column NEAREST the height the cursor itself hit
 *
 * "Highest" is why the teleport could never place indoors. A curator with the
 * camera inside a room, cursor squarely on the floor, still got every unit lifted
 * onto the roof, because each unit's own offset column was re-traced from 200 m up
 * and the roof is what that finds first. Aiming better could not help: the
 * re-trace discarded the aim.
 *
 *   Camera / aim        | cursor z | column at an offset            | old   | new
 *   inside a room       |      4.2 | roof 12.4 / f2 8.1 / f1 4.0 / g 0.0 | 12.4 | 4.0
 *   outside, at a roof  |     12.4 | same                            | 12.4 | 12.4
 *   open ground         |      0.0 | ground 0.0                      |  0.0 | 0.0
 *
 * So pointing at a roof still puts the squad on the roof, and pointing at open
 * ground still puts it on the ground — the two cases that already worked are
 * untouched. Only the case that was unreachable changes.
 *
 * Anything already airborne keeps its own altitude instead of being stacked onto
 * a surface, matching the teleport this replaces: a helicopter in the selection
 * should not be set down by a repositioning order.
 *
 * Runs once, at session open. The column trace is several ray casts per unit,
 * which is why it is paid here and never on the frame loop.
 *
 * Arguments:
 * 0: Units to seed <ARRAY>
 *
 * Return Value:
 * [[unit <OBJECT>, position (ASL) <ARRAY>], ...], empty if the cursor
 * gave nothing usable <ARRAY>
 *
 * Example:
 * private _seeds = [_units] call rtz_place_fnc_seedPositions
 *
 * Public: No
 */

params ["_units"];

if (_units isEqualTo []) exitWith {[]};

// What the curator is pointing at. Nothing is ignored: no ghost exists yet, so
// both ignore slots are free and there is nothing of ours for the ray to hit.
([] call EFUNC(common,cursorSurface)) params ["_cursorASL"];
_cursorASL params ["_cursorX", "_cursorY", "_cursorZ"];

// Selection centre — per-unit offsets from it are what preserve the formation
// shape instead of stacking everyone onto one spot.
private _centre = [0, 0, 0];
{_centre = _centre vectorAdd getPosASL _x} forEach _units;
_centre = _centre vectorMultiply (1 / count _units);

private _seeds = [];

{
    // ALIAS, and load-bearing: the inner forEach over the surface stack below
    // rebinds _x in this same scope, so the unit has to be held under a name of
    // its own or the pushBack at the bottom stores a position instead of a unit.
    // rtz_orders' selection merge carries the same note for the same reason.
    private _unit = _x;

    private _unitASL = getPosASL _unit;
    private _targetX = _cursorX + ((_unitASL select 0) - (_centre select 0));
    private _targetY = _cursorY + ((_unitASL select 1) - (_centre select 1));

    // ~0 AGL means a ground unit. Anything already flying keeps its altitude:
    // it is offset horizontally with the rest of the formation and left at the
    // height it was at, exactly as the teleport did.
    private _curAGL = (getPos _unit) select 2;
    if (_curAGL >= 2) then {
        _seeds pushBack [_unit, AGLToASL [_targetX, _targetY, _curAGL]];
        continue;
    };

    // Every floor in the column at this unit's own target x/y — the offsets each
    // land on a different footprint than the cursor's own hit, so each needs its
    // own trace. The unit itself is ignored so a unit standing on its own target
    // does not present a surface to its own trace.
    private _stack = [_targetX, _targetY, _unit] call EFUNC(common,surfaceStack);

    // The floor closest to the height the curator is aiming at.
    // EFUNC(common,surfaceStack) never returns an empty stack, so the `select 0`
    // below is always safe and this loop always has something to beat.
    private _best = _stack select 0;
    private _bestGap = abs ((_best select 2) - _cursorZ);
    {
        private _gap = abs ((_x select 2) - _cursorZ);
        if (_gap < _bestGap) then {
            _best = _x;
            _bestGap = _gap;
        };
    } forEach _stack;

    _seeds pushBack [_unit, _best];
} forEach _units;

_seeds
