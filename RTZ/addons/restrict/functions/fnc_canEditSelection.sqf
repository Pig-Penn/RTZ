#include "script_component.hpp"
/*
 * Author: Maxim
 * Gate predicate of the ZEN attribute gate (used by the statement wrappers in
 * FUNC(wrapAttributes) and by FUNC(lockControls)): may the local curator
 * change servicing attributes for this entity right now? True only when the
 * entity AND every live curator-selected object (plus all units of selected
 * groups) are inside an editing zone.
 *
 * The whole selection is checked, not just the entity, because ZEN attribute
 * statements apply to the entire selection (getSelectedUnits/Vehicles,
 * SELECTED_OBJECTS/GROUPS) — gating only the entity would let an out-of-zone
 * unit ride along in a bulk edit. Over-strict for unaffected bystanders in the
 * selection, but predictable: deselect what you don't mean to edit.
 *
 * Arguments:
 * 0: Entity being edited <OBJECT|GROUP> (passed as _this)
 *
 * Return Value:
 * Editing allowed <BOOLEAN>
 *
 * Example:
 * _unit call rtz_restrict_fnc_canEditSelection
 *
 * Public: No
 */

if (!GVAR(enabled)) exitWith {true};

private _objects = [];

if (_this isEqualType objNull) then {
    _objects pushBack _this;
};

if (_this isEqualType grpNull) then {
    _objects append units _this;
};

curatorSelected params [["_selObjects", [], [[]]], ["_selGroups", [], [[]]]];
_objects append _selObjects;
{_objects append units _x} forEach _selGroups;

_objects findIf {
    !isNull _x && {alive _x} && {!(_x call FUNC(isInsideZone))}
} == -1
