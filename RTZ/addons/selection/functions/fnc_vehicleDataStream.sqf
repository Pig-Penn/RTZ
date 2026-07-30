#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT ONLY. Receives the per-vehicle packets pushed by the server gather
 * (FUNC(vehicleGather)) and keeps GVAR(selVehicleData) (netId → packet) current.
 * GVAR(vehDataDirty) flags FUNC(vehicleOverlay) that a fresh push arrived and its
 * cards need a relayout.
 *
 * Split out from the two displays it feeds so either can run without the other:
 * both the bottom-right stat cards (FUNC(vehicleOverlay)) and the floating head
 * tags (FUNC(vehicleTags)) read this one map.
 *
 * Requirements: CBA_A3.
 * Loading: called from XEH_postInit after CBA_settingsInitialized whenever
 *   GVAR(enableVehicleOverlay) or GVAR(enableVehicleTags) is set — ordered
 *   before both so their own QGVAR(selVehicleData) handlers see this map already
 *   filled. Registers one CBA event handler, no scheduled ops.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_selection_fnc_vehicleDataStream
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

GVAR(selVehicleData) = createHashMap;
GVAR(vehDataDirty)   = true;

[QGVAR(selVehicleData), {
    params ["_packets"];
    private _m = createHashMap;
    { _m set [_x select 0, _x] } forEach _packets;
    GVAR(selVehicleData) = _m;
    GVAR(vehDataDirty)   = true;
}] call CBA_fnc_addEventHandler;
