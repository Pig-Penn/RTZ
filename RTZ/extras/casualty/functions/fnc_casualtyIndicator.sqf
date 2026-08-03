#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT: registers the receivers that keep the local casualty snapshot in sync, the
 * curator toasts, and the Draw3D marker that shows friendly casualties while Zeus is
 * open. Mirrors the spotting system's client half but far simpler — the server streams
 * the whole (small) casualty list once per manager tick, so there is no per-unit add/
 * remove bookkeeping and JIP resolves within a tick.
 *
 * A red medical symbol marks a DOWN casualty; it turns blue once he is LOADED aboard a
 * medical vehicle. Only casualties friendly to the viewer are drawn.
 *
 * Loading: called by XEH_postInit (hasInterface) when the casualty system is on.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * [] call rtz_casualty_fnc_casualtyIndicator
 *
 * Public: No
 */

// Latest server snapshot: [[unit, side, state], ...]; plus a netId -> state lookup the
// context-action condition reads (FUNC(collectCasualties)). Initialised in preInit too,
// re-created here defensively.
GVAR(casualtyList)   = [];
GVAR(casualtyStates) = createHashMap;

[QGVAR(casualtySync), {
    params ["_list"];
    GVAR(casualtyList)   = _list;
    GVAR(casualtyStates) = createHashMap;
    {
        _x params ["_u", "", "_st"];
        GVAR(casualtyStates) set [netId _u, _st];
    } forEach _list;
}] call CBA_fnc_addEventHandler;

// Broadcast toast — shown only to curators friendly to the casualty's side. The
// payload carries the stringtable KEY (not resolved text), so it survives the
// network hop untranslated and is localized here on each recipient's machine.
[QGVAR(casualtyToast), {
    params ["_textKey", "_side"];
    if (isNull getAssignedCuratorLogic player) exitWith {};
    if ((side player getFriend _side) < 0.6) exitWith {};
    [_textKey] call zen_common_fnc_showMessage;
}] call CBA_fnc_addEventHandler;

// Targeted toast to the ordering curator (e.g. load failed) — already routed to us only.
[QGVAR(casualtyMsg), {
    _this call zen_common_fnc_showMessage;
}] call CBA_fnc_addEventHandler;

// 3D marker over each friendly casualty, only while the Zeus interface is open (these
// are curator-view icons). Position is sampled live so it tracks a body being dragged
// or a loaded casualty riding in a vehicle.
addMissionEventHandler ["Draw3D", {
    if (isNull (findDisplay 312)) exitWith {};
    if (GVAR(casualtyList) isEqualTo []) exitWith {};
    private _mySide = side player;
    {
        _x params ["_unit", "_cSide", "_state"];
        if (isNull _unit || {!alive _unit}) then { continue };
        if ((_mySide getFriend _cSide) < 0.6) then { continue };
        // Red while down and bleeding; blue once aboard a medical vehicle.
        private _col = [COLOR_CASUALTY_DOWN, COLOR_CASUALTY_LOADED] select (_state == "LOADED");
        private _pos = (_unit modelToWorldVisual (_unit selectionPosition "Head")) vectorAdd [0, 0, 1.2];
        drawIcon3D ["\a3\ui_f\data\map\markers\nato\n_med.paa", _col, _pos, 1.1, 1.1, 0, "", 0, 0.03, "RobotoCondensed", "center", false, 0, -0.03];
    } forEach GVAR(casualtyList);
}];
