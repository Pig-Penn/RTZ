#include "script_component.hpp"
/*
 * Author: Maxim
 * Gives one entity the colour its path is drawn in, and remembers it.
 *
 * A path colour is a property of the SUBJECT, not of its position in this
 * session's list. A curator plans the same company four or five times over an
 * operation, and a colour that means "the lead section" for as long as the
 * mission lasts is worth having; one that means "whichever handle happened to be
 * seeded third this time" is not. Wargame stores its colour on the unit for
 * exactly this reason and it is the right instinct.
 *
 * What is wrong with Wargame's is the picker — `[random 1.1, random 1.1,
 * random 1.1, 1]` retried until it finds one not already taken, up to six
 * hundred times, which regularly lands on near-black, on white, or on two
 * greens a curator cannot tell apart at 400 m. The palette here is twelve
 * colours chosen to read against grass, sand, snow and tarmac, and the pick is
 * the LEAST-USED entry rather than the next index: a session of thirteen paths
 * gives the thirteenth a colour that is not next to any of its neighbours,
 * instead of restarting the whole order at the top.
 *
 * Ties are broken by palette order, so the first twelve paths of an empty
 * session come out in the palette's own sequence — which is the order it was
 * arranged in for contrast between adjacent entries.
 *
 * Arguments:
 * 0: Entity whose path is being coloured <OBJECT>
 * 1: Colours already claimed in this session <ARRAY>
 *
 * Return Value:
 * Colour as [r, g, b, a] <ARRAY>
 *
 * Example:
 * private _color = [_hull, _claimed] call rtz_path_fnc_colorFor
 *
 * Public: No
 */

params ["_hull", "_claimed"];

private _palette = GVAR(palette);

// What this entity wore last time, if anything, and if nothing else in this
// session has already taken it. A clash is resolved in favour of whoever asked
// first, and the loser is simply re-coloured and remembers the new one.
private _kept = _hull getVariable [QGVAR(color), []];

if (_kept isNotEqualTo []
    && {(_claimed findIf {_x isEqualTo _kept}) == -1}
    && {(_palette findIf {_x isEqualTo _kept}) != -1}
) exitWith {
    _claimed pushBack _kept;
    _kept
};

// Least used, ties going to the earlier palette entry. One pass over twelve
// entries and one over what is claimed — against Wargame's up-to-600 spins of a
// random generator that has no idea what it has already produced.
private _best = _palette select 0;
private _bestCount = 1e10;

{
    private _color = _x;
    private _count = {_x isEqualTo _color} count _claimed;

    if (_count < _bestCount) then {
        _best = _color;
        _bestCount = _count;
    };
} forEach _palette;

_claimed pushBack _best;
_hull setVariable [QGVAR(color), _best];

_best
