#include "script_component.hpp"
/*
 * Author: Maxim
 * Checks whether an object lies inside any of the LOCAL curator's editing
 * zones. Read straight from the engine via curatorEditingArea rather than
 * RTZ's own officer-area tracking (EGVAR(officer,areas)), so this also
 * accounts for editing areas added outside the officer context-menu system
 * (e.g. a Curator Editing Area module placed in Eden and synced to the
 * curator module). With no zones active the answer is always false —
 * callers should treat that case as "restriction not active" rather than
 * calling this per-object (see FUNC(canEditSelection)'s short-circuit).
 *
 * Purely geometric: callers decide whether the restriction setting applies
 * (see FUNC(canEditSelection)).
 *
 * Arguments:
 * 0: Object <OBJECT> (passed as _this, not wrapped in an array)
 *
 * Return Value:
 * Inside at least one editing zone <BOOLEAN>
 *
 * Example:
 * _unit call rtz_restrict_fnc_isInsideZone
 *
 * Public: No
 */

private _curator = getAssignedCuratorLogic player;
if (isNull _curator) exitWith {false};

private _pos = getPosWorld _this;

(curatorEditingArea _curator) findIf {
    _x params ["", "_areaPos", "_radius"];
    _pos distance2D _areaPos <= _radius
} != -1
