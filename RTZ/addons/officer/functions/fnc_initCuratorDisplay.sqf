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
 * The DisplayLoad handler in CfgEventHandlers.hpp is unconditional, so this
 * also runs with the aura system off — and GVAR(auraEnable) is false by
 * DEFAULT, i.e. the common case. Bailing on the setting keeps a per-frame Draw
 * handler off the map control of every mission that never enables auras (same
 * shape of guard rtz_spotting uses for its own officer zone ring).
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

// GETGVAR, not a bare read: DisplayLoad can beat CBA's setting registration
if !(GETGVAR(auraEnable,false)) exitWith {};
if (_display getVariable [QGVAR(auraDrawAttached), false]) exitWith {};
_display setVariable [QGVAR(auraDrawAttached), true];

(_display displayCtrl IDC_RSCDISPLAYCURATOR_MAINMAP) ctrlAddEventHandler ["Draw", {
    if (count GVAR(auraZones) == 0) exitWith {};
    params ["_map"];
    {
        _y params ["_officer", "_radius"];

        // Null means the mirror was filled by a JIP replay before the unit had
        // streamed in (see XEH_preInit). Re-resolve from the key the entry is
        // stored under and write it back, so this costs one lookup, not one
        // per frame. Still null = the officer is genuinely gone; the server
        // prunes the entry within AURA_INTERVAL.
        if (isNull _officer) then {
            _officer = objectFromNetId _x;
            if (isNull _officer) then {continue};
            _y set [0, _officer];
        };

        if (!alive _officer) then {continue};

        _map drawEllipse [getPosVisual _officer, _radius, _radius, 0, COLOR_AURA_RING, ""];
    } forEach GVAR(auraZones);
}];
