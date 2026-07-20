#include "script_component.hpp"
/*
 * Author: Maxim
 * Runs every time the Zeus curator display (RscDisplayCurator, IDD 312) is created
 * (Extended_DisplayLoad_EventHandlers in CfgEventHandlers.hpp) — the display and
 * its controls are destroyed and recreated each time Zeus opens, so the map
 * overlay must be re-attached per instance (same pattern rtz_spotting uses for
 * the officer editing-area zone ring).
 *
 * Draws a hollow ring on the curator map (control 50) around every officer with
 * an active command aura, radius from GVAR(auraZones) — a client-side mirror
 * kept in sync by QGVAR(auraZone) broadcasts (see FUNC(applyAura) and
 * FUNC(monitorAuras)). Visible to every curator regardless of side.
 *
 * Also called directly by XEH_postInit if the display already exists when the
 * (settings-deferred) aura system starts; the per-display guard makes the two
 * paths safe to overlap.
 *
 * Arguments:
 * 0: The freshly created curator display <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [findDisplay 312] call rtz_officer_fnc_initCuratorDisplay
 *
 * Public: No
 */

params ["_display"];

if (_display getVariable [QGVAR(auraDrawAttached), false]) exitWith {};
_display setVariable [QGVAR(auraDrawAttached), true];

(_display displayCtrl 50) ctrlAddEventHandler ["Draw", {
    if (count GVAR(auraZones) == 0) exitWith {};
    params ["_map"];
    {
        _y params ["_officer", "_radius"];
        if (isNull _officer || {!alive _officer}) then {continue};
        _map drawEllipse [getPosVisual _officer, _radius, _radius, 0, COLOR_AURA_RING, ""];
    } forEach GVAR(auraZones);
}];
