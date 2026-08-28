#include "script_component.hpp"
/*
 * Author: Maxim
 * Whether the ground at this point is soft enough to dig. Memoized per surface
 * class in GVAR(surfaces).
 *
 * Ported from ace_common_fnc_canDig: the verdict comes from the surface's own
 * `dust` figure in CfgSurfaces, which is the same field the engine uses to decide
 * how much a footfall kicks up — so tarmac, rock and concrete refuse and dirt,
 * sand and grass accept, without this component carrying a list of surface names
 * that would be wrong on the first modded terrain.
 *
 * The cache is keyed on the surface CLASS, of which a terrain has a few dozen, so
 * it is bounded by the map rather than by how long the mission runs. That matters
 * here: FUNC(planTrench) calls this three times per cell and re-plans while the
 * curator drags, and `surfaceType` plus a configFile walk is not something to do
 * per point per frame.
 *
 * Arguments:
 * 0: Position 2D or ASL <ARRAY>
 *
 * Return Value:
 * Diggable <BOOL>
 *
 * Example:
 * [[1000, 2000]] call rtz_dig_fnc_surfaceDiggable
 *
 * Public: No
 */

params ["_pos"];

// surfaceType reports "#GdtStratisThistles"; the leading # is not part of the class
private _class = (surfaceType _pos) select [1];
private _cached = GVAR(surfaces) get _class;

if (!isNil "_cached") exitWith {_cached};

private _diggable = getNumber (configFile >> "CfgSurfaces" >> _class >> "dust") >= 0.1;

GVAR(surfaces) set [_class, _diggable];

_diggable
