#include "script_component.hpp"
/*
 * Author: Maxim
 * Gate predicate of the servicing restriction: may the local curator service
 * the entities a given attribute row would write to? True when every live
 * entity in that row's target scope sits inside the curator's editing zones.
 *
 * The scope matters. ZEN's servicing statements ignore the row's own entity and
 * apply to the whole curator selection (SELECTED_OBJECTS, getSelectedUnits,
 * getSelectedVehicles, SELECTED_GROUPS), and each row uses a different one — so
 * the gate mirrors the row's set exactly. A squad standing in a zone can still
 * be healed while an out-of-zone truck is selected alongside it, because the
 * skill row never touches the truck. Gating the union instead would let one
 * unrelated selection member veto every row.
 *
 * If the local curator has no editing areas at all, the restriction never
 * applies — servicing stays free until at least one area exists. Areas are read
 * from the engine's own curatorEditingArea rather than RTZ's officer tracking
 * (EGVAR(officer,areas)) so an area added outside the officer context-menu
 * system is recognized too, e.g. a Curator Editing Area module placed in Eden
 * and synced to the curator module. curatorEditingAreaType is honoured as well:
 * a mission may flip the areas from "where the curator may edit" to "where they
 * may not", and RTZ agrees with the engine either way instead of assuming.
 *
 * Verdicts are cached per frame and per scope. A confirm evaluates every
 * changed row in one frame, so a window with all seven servicing rows touched
 * resolves each scope once instead of once per row — and each resolution walks
 * the areas array that was fetched once here, not once per entity.
 *
 * Arguments:
 * 0: Target scope <NUMBER> (one of the SCOPE_* macros)
 *
 * Return Value:
 * Servicing allowed <BOOLEAN>
 *
 * Example:
 * [SCOPE_VEHICLES] call rtz_restrict_fnc_canEdit
 *
 * Public: No
 */

params [["_scope", -1, [0]]];

if (_scope < 0 || {_scope >= SCOPE_COUNT}) exitWith {true};

if (!GVAR(enabled)) exitWith {true};

private _curator = getAssignedCuratorLogic player;
if (isNull _curator) exitWith {true};

private _areas = curatorEditingArea _curator;
if (_areas isEqualTo []) exitWith {true};

// Slot 0 holds the frame the cache was built on, slots 1..SCOPE_COUNT hold
// -1 (unresolved) / 0 (blocked) / 1 (allowed) per scope
private _cache = GVAR(cache);

if ((_cache select 0) != diag_frameNo) then {
    _cache = [diag_frameNo, -1, -1, -1, -1];
    GVAR(cache) = _cache;
};

private _cached = _cache select (_scope + 1);
if (_cached != -1) exitWith {_cached == 1};

private _targets = switch (_scope) do {
    case SCOPE_OBJECTS: {SELECTED_OBJECTS};
    case SCOPE_UNITS: {call zen_common_fnc_getSelectedUnits};
    case SCOPE_VEHICLES: {call zen_common_fnc_getSelectedVehicles};
    case SCOPE_GROUP_UNITS: {
        private _units = [];
        {_units append units _x} forEach SELECTED_GROUPS;
        _units
    };
    default {[]};
};

// true when the areas are the region the curator MAY edit in (the usual
// whitelist setup), false when they are the region they may NOT edit in.
// Compared against an explicit false rather than used raw: anything other than
// a boolean would come back unequal for every entity below and block servicing
// outright, so an unexpected value falls back to the whitelist reading.
private _editableInside = curatorEditingAreaType _curator isNotEqualTo false;

// Dead and deleted entities cannot be serviced anyway, so they never block the
// live ones they happen to be selected alongside
private _allowed = _targets findIf {
    !isNull _x
    && {alive _x}
    && {
        private _pos = getPosWorld _x;

        // _x here is an area — [id, centre, radius] — not the entity above
        private _isInside = _areas findIf {
            _pos distance2D (_x select 1) <= (_x select 2)
        } != -1;

        _isInside isNotEqualTo _editableInside
    }
} == -1;

_cache set [_scope + 1, [0, 1] select _allowed];

_allowed
