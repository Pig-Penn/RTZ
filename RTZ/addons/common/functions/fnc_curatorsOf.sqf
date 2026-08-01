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

private _live = allCurators select {!isNull _x};
private _owners = _live select {_object in curatorEditableObjects _x};

if (_fallbackAll && {_owners isEqualTo []}) exitWith {_live};

_owners
