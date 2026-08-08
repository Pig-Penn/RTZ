#include "script_component.hpp"
/*
 * Author: Maxim
 * Single "Draw Tags" ZEN context menu entry driving every live tag system
 * (FUNC(startTagSystem)) — the infantry head tags and the vehicle tags used to
 * register their own separate buttons; this condenses them into one. The press
 * goes to FUNC(toggleTags), which computes one target state for whichever
 * systems are present; the label/tint here mirror what those systems report.
 *
 * Loading: called from XEH_postInit after CBA_settingsInitialized, once at least
 * one tag system has been declared for this session. Client-only, registers one
 * ZEN context menu action — no scheduled ops.
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
        // "Hide" is offered while ANY live tag system is visible. Read through
        // the same ANY_TAGS_VISIBLE macro FUNC(toggleTags) acts on, so the label
        // and the press can never describe different things.
        if (ANY_TAGS_VISIBLE) then {
            _action set [ACTION_INDEX_DISPLAYNAME, LLSTRING(ActionHideTags)]; // Off
            _action set [ACTION_INDEX_ICONCOLOR, [1, 1, 1, 1]]; // White
        } else {
            _action set [ACTION_INDEX_DISPLAYNAME, LLSTRING(ActionDrawTags)]; // On
            _action set [ACTION_INDEX_ICONCOLOR, [0.50, 0.50, 0.50, 1]]; // Grey
        };
    }
] call zen_context_menu_fnc_createAction;

[_action, ["RTZ_Overlays"], 2] call zen_context_menu_fnc_addAction;
