#include "script_component.hpp"
/*
 * Author: Maxim
 * The curators who can already edit an object. The single source of truth for
 * "who owns this", shared by FUNC(grantCurators) and rtz_captive's prisoner
 * transfer, which each hand-rolled the same allCurators filter.
 *
 * Curator modules are server-local, so this only returns anything meaningful on
 * the server — callers that can run elsewhere hop there first (see
 * FUNC(grantCurators)).
 *
 * Arguments:
 * 0: Object <OBJECT>
 * 1: Fall Back To All Curators <BOOL> - when no curator owns the object, return
 *    every live curator rather than [] (default: false)
 *
 * Return Value:
 * Owning Curators <ARRAY of OBJECT>
 *
 * Example:
 * [_unit] call rtz_common_fnc_curatorsOf
 *
 * Public: No
 */

params ["_object", ["_fallbackAll", false]];

// One pass in the normal case. curatorEditableObjects materialises a curator's
// entire editable set, so it is the expensive half of this — the isNull test
// is deliberately first so a dead module never triggers one. The live-curator
// list is only rebuilt on the fallback path, which is the rare one.
private _owners = allCurators select {!isNull _x && {_object in curatorEditableObjects _x}};

if (_fallbackAll && {_owners isEqualTo []}) exitWith {
    allCurators select {!isNull _x}
};

_owners
