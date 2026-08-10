#include "script_component.hpp"
/*
 * Author: Maxim
 * Gate predicate of the arsenal restriction: does one entity sit inside the
 * local curator's editing zones?
 *
 * The companion to FUNC(canEdit), which answers the same question about a whole
 * selection scope. Every arsenal surface acts on exactly one entity — the row's
 * own entity for the attributes button, the hovered entity for the context
 * menu, the attached unit for the Zeus module — so the scope machinery and its
 * per-scope cache do not apply here.
 *
 * Deliberately does not read GVAR(arsenal). The setting check belongs at each
 * call site, which leaves this reusable for any later per-entity restriction.
 *
 * Uncached. It runs a handful of times per context menu build or attribute
 * window open, never per frame, and a per-entity cache would be one more
 * long-lived map to bound for no measurable gain.
 *
 * As in FUNC(canEdit): a curator with no editing areas at all is never
 * restricted, and curatorEditingAreaType is honoured so a mission may flip the
 * areas to a blacklist and have RTZ agree with the engine.
 *
 * Arguments:
 * 0: Entity <OBJECT>
 *
 * Return Value:
 * Entity is editable <BOOLEAN>
 *
 * Example:
 * [_entity] call rtz_restrict_fnc_canEditEntity
 *
 * Public: No
 */

params [["_entity", objNull, [objNull]]];

if (isNull _entity) exitWith {true};

private _curator = getAssignedCuratorLogic player;
if (isNull _curator) exitWith {true};

private _areas = curatorEditingArea _curator;
if (_areas isEqualTo []) exitWith {true};

// Bound before the area walk, which rebinds _x to an area
private _pos = getPosWorld _entity;
private _editableInside = curatorEditingAreaType _curator isNotEqualTo false;

// Aliveness is not tested here. Every caller ANDs this with ZEN's own
// condition, and all of those already require an alive CAManBase.
IN_EDITABLE_AREA(_pos,_areas,_editableInside)
