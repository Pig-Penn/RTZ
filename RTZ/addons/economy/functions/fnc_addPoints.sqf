#include "script_component.hpp"
/*
 * Author: Maxim
 * Credits (or charges) a curator in points, where POINTS_MAX equals a full
 * resource bar. The engine's own curator point scale is normalized to 0..1, so
 * every payout has to be converted first — this is the one place that
 * conversion lives, and every points-denominated credit should go through it.
 *
 * Gains are capped at a full bar: addCuratorPoints does not clamp, so without
 * this passive income would run away far past anything the bar can show and
 * the economy would stop constraining the curator entirely.
 *
 * Curator modules are server-local, so this must run on the server.
 *
 * Arguments:
 * 0: Curator module <OBJECT>
 * 1: Points to credit, negative to charge <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_curator, 15] call rtz_economy_fnc_addPoints
 *
 * Public: Yes
 */

params ["_curator", "_points"];

if (isNull _curator) exitWith {};

private _delta = _points / POINTS_MAX;

// Only gains are capped — a charge stays valid for a curator already over the bar
if (_delta > 0) then {
    _delta = _delta min ((1 - curatorPoints _curator) max 0);
};

if (_delta == 0) exitWith {};

_curator addCuratorPoints _delta;
