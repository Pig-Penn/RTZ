#include "script_component.hpp"
/*
 * Author: Maxim
 * Single "Draw Tags" ZEN context menu entry driving both the infantry head
 * tags (FUNC(unitTags)) and the vehicle tags (FUNC(vehicleTags)) — the
 * two systems used to register their own separate buttons; this condenses
 * them into one. The press goes to FUNC(toggleTags), which computes one
 * target state for whichever systems are present; the label/tint here mirror
 * whatever any active system currently reports.
 *
 * Loading: called from XEH_postInit after CBA_settingsInitialized, once at
 * least one of FUNC(unitTags) / FUNC(vehicleTags) has run for this session.
 * Client-only, registers one ZEN context menu action — no scheduled ops.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_hud_fnc_tagsContext
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

// ── ZEN context menu toggle (label/tint mirror the current state) ───────────
private _action = [
    "RTZ_ToggleTags",
    LLSTRING(ActionDrawTags),
    ["\a3\ui_f\data\igui\cfg\simpletasks\types\documents_ca.paa", [1, 1, 1, 1]],
    { call FUNC(toggleTags) },
    { true },
    [],
    {},
    {
        params ["_action"];
        // "Hide" is offered while ANY active tag system is visible — matches
        // FUNC(toggleTags), which hides everything first.
        private _visible = GETGVAR(unitTagsVisible,false) || {GETGVAR(vehicleTagsVisible,false)};
        if (_visible) then {
            _action set [ACTION_INDEX_DISPLAYNAME, LLSTRING(ActionHideTags)]; // Off
            _action set [ACTION_INDEX_ICONCOLOR, [1, 1, 1, 1]]; // White
        } else {
            _action set [ACTION_INDEX_DISPLAYNAME, LLSTRING(ActionDrawTags)]; // On
            _action set [ACTION_INDEX_ICONCOLOR, [0.50, 0.50, 0.50, 1]]; // Grey
        };
    }
] call zen_context_menu_fnc_createAction;

[_action, ["RTZ_Overlays"], 2] call zen_context_menu_fnc_addAction;
