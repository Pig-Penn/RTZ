#include "script_component.hpp"
/*
 * Author: Maxim
 * Splices the editing-zone gate into ZEN's attribute registry on this client.
 * ZEN stores every attribute row ([name, tooltip, control, valueInfo,
 * statement, default, condition, priority]) and display button ([name,
 * tooltip, statement, condition, closeDisplay]) in the zen_attributes_displays
 * namespace, filled at ZEN preInit — so rewriting the stored code here (RTZ
 * postInit) is safely ordered and survives every window open.
 *
 * Rows are gated at the STATEMENT, not the condition: the sliders stay visible
 * because they double as unit info (current health/fuel/ammo/skill), but a
 * confirm while out of zone applies nothing and shows FUNC(showBlocked)'s
 * toast. ZEN runs the stored statement from zen_attributes_fnc_confirm, so
 * this holds even when the unit leaves the zone after the window opened.
 * FUNC(lockControls) additionally greys the gated rows out at open time — the
 * labels recorded in GVAR(gatedLabels) (displayType -> row labels, true = all
 * rows) are its lookup table.
 *
 * The one exception is the vehicle Damage button (zen_damage hitpoint editor):
 * it opens its own display whose apply path cannot be statement-wrapped, so
 * its CONDITION is wrapped instead and the button hides while out of zone.
 * The Health slider still shows overall damage.
 *
 * Gated: Object skill/health/fuel/ammo + ammo/fuel/repair cargo rows, the
 * Group skill row, and every row of the Skills display. Rows are matched by
 * their registered display name — localized at registration by ZEN, so matched
 * against localize of the same keys.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_restrict_fnc_wrapAttributes
 *
 * Public: No
 */

private _displays = missionNamespace getVariable "zen_attributes_displays";

if (isNil "_displays") exitWith {
    WARNING("ZEN attribute display registry missing, attribute gate not installed.");
};

// displayType -> gated row labels (true = every row), read by FUNC(lockControls)
GVAR(gatedLabels) = createHashMap;

// _labels: array of display names to match, or true to wrap every entry.
// Original statements read _entity/_value from ZEN's confirm scope; nested
// call keeps them visible inside the wrapped code.
private _fnc_wrapStatements = {
    params ["_rows", "_labels"];

    {
        if (_labels isEqualTo true || {(_x select 0) in _labels}) then {
            private _orig = _x select 4;
            _x set [
                4,
                compile format [
                    "if (_entity call %1) then {call %2} else {call %3}",
                    QFUNC(canEditSelection), str _orig, QFUNC(showBlocked)
                ]
            ];
        };
    } forEach _rows;
};

// Condition wrap hides the entry entirely — only for entries whose editor
// cannot be statement-gated
private _fnc_wrapConditions = {
    params ["_entries", "_labels", "_conditionIndex"];

    {
        if ((_x select 0) in _labels) then {
            private _orig = _x select _conditionIndex;
            _x set [
                _conditionIndex,
                compile format ["(call %1) && {_entity call %2}", str _orig, QFUNC(canEditSelection)]
            ];
        };
    } forEach _entries;
};

private _skillLabel = localize "STR_3DEN_Object_Attribute_Skill_displayName";

{
    _x params ["_type", "_rowLabels"];

    private _data = _displays getVariable _type;
    if (isNil "_data") then {continue};

    [_data select 2, _rowLabels] call _fnc_wrapStatements;
    GVAR(gatedLabels) set [_type, _rowLabels];
} forEach [
    ["Object", [
        _skillLabel,
        localize "STR_3DEN_Object_Attribute_Health_displayName",
        localize "STR_3DEN_Object_Attribute_Fuel_displayName",
        localize "STR_3DEN_Object_Attribute_Ammo_displayName",
        localize "STR_ZEN_Attributes_AmmoCargo",
        localize "STR_ZEN_Attributes_FuelCargo",
        localize "STR_ZEN_Attributes_RepairCargo"
    ]],
    ["Group", [_skillLabel]],
    ["Skills", true]
];

private _objectData = _displays getVariable "Object";
if (!isNil "_objectData") then {
    [_objectData select 3, [localize "STR_A3_NormalDamage1"], 3] call _fnc_wrapConditions;
};
