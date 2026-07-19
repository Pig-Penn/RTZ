#include "script_component.hpp"
/*
 * Author: Maxim
 * Checks whether an object lies inside any of the LOCAL curator's editing
 * zones. Zones are the officer editing areas tracked per-client by rtz_officer
 * in EGVAR(officer,areas) (officerNetId -> [areaId, pos, radius]); areas never
 * move once planted, so the stored position is authoritative. With no zones
 * planted the answer is always false — no zone, no servicing.
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

private _pos = getPosWorld _this;

(values EGVAR(officer,areas)) findIf {
    _x params ["", "_areaPos", "_radius"];
    _pos distance2D _areaPos <= _radius
} != -1
