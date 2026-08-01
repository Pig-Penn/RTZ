#include "script_component.hpp"
/*
 * Author: Maxim
 * Returns the unique alive officers among the given objects, expanding
 * vehicles to their crews (see FUNC(isOfficer) for the heuristic). The
 * selection expansion itself is EFUNC(common,collectUnits) — the shared
 * primitive that also drops the non-object entries a ZEN modifier can pass in
 * (a hovered group or waypoint) — so only the officer filter lives here.
 *
 * Memoised for ONE frame in GVAR(officerCache). Both context actions in
 * CfgContext.hpp call this from their condition AND their modifierFunction, so
 * ZEN's fnc_getActiveActions runs it four times over the same selection while
 * building a single menu. One frame is the whole window: the result depends on
 * unit liveness and crew composition, which must not be cached across frames.
 *
 * Arguments:
 * N: Objects <OBJECT>
 *
 * Return Value:
 * Officers <ARRAY>
 *
 * Example:
 * [_object] call rtz_officer_fnc_getOfficers
 *
 * Public: No
 */

GVAR(officerCache) params ["_frame", "_objects", "_officers"];

if (_frame isEqualTo diag_frameNo && {_objects isEqualTo _this}) exitWith {_officers};

_officers = ([_this] call EFUNC(common,collectUnits)) select {
    alive _x && {[_x] call FUNC(isOfficer)}
};

GVAR(officerCache) = [diag_frameNo, +_this, _officers];

_officers
