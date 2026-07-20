#include "script_component.hpp"
/*
 * rtz_fnc_tagsContext
 *
 * Single "Draw Tags" ZEN context menu entry driving both the infantry head
 * tags (rtz_fnc_unitTags) and the vehicle tags (rtz_fnc_vehicleTags) — the
 * two systems used to register their own separate buttons; this condenses
 * them into one. Each system is independently CBA-setting gated, so only
 * one, both, or neither of GVAR(fnc_toggleTags) / GVAR(fnc_toggleVehTags)
 * may exist at runtime; the combined toggle drives whichever are present,
 * and the label/tint reflect whichever active system reports visible.
 *
 * Loading: called from XEH_postInit after CBA_settingsInitialized, once at
 * least one of FUNC(unitTags) / FUNC(vehicleTags) has run for this session.
 * Client-only, registers one ZEN context menu action — no scheduled ops.
 */

if (!hasInterface) exitWith {};

GVAR(fnc_toggleAllTags) = {
    // Both systems get ONE computed target state instead of each flipping its
    // own: if the two ever disagree (e.g. a master setting flipped one off
    // mid-mission), independent toggles would swap them forever — this
    // converges them on the first press. Target: hide if ANY tags are visible.
    private _newVis = !(GETGVAR(tagsVisible,false) || { GETGVAR(vtagsVisible,false) });
    if (!isNil QGVAR(tagsVisible))  then { GVAR(tagsVisible)  = _newVis };
    if (!isNil QGVAR(vtagsVisible)) then { GVAR(vtagsVisible) = _newVis };
    [[LLSTRING(MsgTagsHidden), LLSTRING(MsgTagsShown)] select _newVis] call zen_common_fnc_showMessage;
};

// ── ZEN context menu toggle (label/tint mirror the current state) ───────────
private _action = [
    "RTZ_ToggleTags",
    LLSTRING(ActionDrawTags),
    ["\a3\ui_f\data\igui\cfg\simpletasks\types\documents_ca.paa", [1, 1, 1, 1]],
    { [] call GVAR(fnc_toggleAllTags) },
    { true },
    [],
    {},
    {
        params ["_action"];
        // "Hide" is offered while ANY active tag system is visible — matches
        // the toggle above, which hides everything first.
        private _visible = GETGVAR(tagsVisible,false) || { GETGVAR(vtagsVisible,false) };
        if (_visible) then {
            _action set [1, LLSTRING(ActionHideTags)]; // Off
            _action set [3, [1, 1, 1, 1]]; // White
        } else {
            _action set [1, LLSTRING(ActionDrawTags)]; // On
            _action set [3, [0.50, 0.50, 0.50, 1]]; // Grey
        };
    }
] call zen_context_menu_fnc_createAction;

[_action, ["RTZ_Overlays"], 2] call zen_context_menu_fnc_addAction;
