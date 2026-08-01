#include "script_component.hpp"
/*
 * Author: Maxim
 * Reads ZEN's attribute registry once on this client (RTZ postInit, after ZEN
 * filled it at preInit) and records which rows are servicing rows, keyed by the
 * source of their statement and valued with the target scope that statement
 * writes to. FUNC(gateDisplay) looks rows up in that map when a window opens.
 *
 * The registry is only READ. Earlier versions rewrote every gated statement in
 * place with compile+format over str of ZEN's own source; that mutation was
 * permanent for the session, survived the setting being switched off, handed
 * every other mod reading the registry an RTZ wrapper instead of ZEN's code,
 * and silently broke whenever ZEN renamed a local. Enforcement now lives in the
 * per-window hook instead, which needs nothing from the registry but identity.
 *
 * Statement source is the key because label text is not unique: the Object and
 * Group displays both carry a row labelled "Skill", and they write to different
 * scopes (the selected units vs every unit of the selected groups).
 *
 * The one row that cannot be hooked per window is the vehicle Damage button —
 * it opens a zen_dialog display rather than an attribute display, so it is
 * gated at its condition and simply does not appear out of zone. The Health
 * slider still reports overall damage.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_restrict_fnc_initGate
 *
 * Public: No
 */

private _displays = missionNamespace getVariable ZEN_DISPLAY_REGISTRY;

// Always left defined — FUNC(gateDisplay) reads it on every attribute window,
// and an empty map is the correct "nothing is gated" answer
GVAR(gatedRows) = createHashMap;

if (isNil "_displays") exitWith {
    WARNING("ZEN attribute display registry missing, servicing restriction not installed.");
};

// _labels: array of registered display names to match, or true for every row of
// the display. Names are localized by ZEN at registration, so they are matched
// against localize of the same keys.
private _fnc_register = {
    params ["_type", "_scope", "_labels"];

    private _data = _displays getVariable _type;

    if (isNil "_data") exitWith {
        WARNING_1("ZEN attribute display '%1' is not registered, its rows stay ungated.",_type);
    };

    {
        if (_labels isEqualTo true || {(_x select 0) in _labels}) then {
            GVAR(gatedRows) set [str (_x select 4), _scope];
        };
    } forEach (_data select 2);
};

private _skillLabel = localize "STR_3DEN_Object_Attribute_Skill_displayName";

{
    _x call _fnc_register;
} forEach [
    ["Object", SCOPE_UNITS, [_skillLabel]],
    ["Object", SCOPE_OBJECTS, [localize "STR_3DEN_Object_Attribute_Health_displayName"]],
    ["Object", SCOPE_VEHICLES, [
        localize "STR_3DEN_Object_Attribute_Fuel_displayName",
        localize "STR_3DEN_Object_Attribute_Ammo_displayName",
        localize "STR_ZEN_Attributes_AmmoCargo",
        localize "STR_ZEN_Attributes_FuelCargo",
        localize "STR_ZEN_Attributes_RepairCargo"
    ]],
    ["Group", SCOPE_GROUP_UNITS, [_skillLabel]],
    ["Skills", SCOPE_UNITS, true]
];

private _objectData = _displays getVariable "Object";
if (isNil "_objectData") exitWith {};

// Buttons are [name, tooltip, statement, condition, closeDisplay]; ZEN checks
// the condition both when creating the button and when it is clicked, so
// gating there covers a zone lost while the window was open. The original
// condition is stashed in a variable rather than inlined into the wrapper so
// the wrapper can stay a plain code literal — no compile of ZEN's own source.
private _damageLabel = localize "STR_A3_NormalDamage1";

{
    if ((_x select 0) isEqualTo _damageLabel && {isNil {GVAR(damageCondition)}}) then {
        GVAR(damageCondition) = _x select 3;

        _x set [3, {
            (_this call GVAR(damageCondition)) && {[SCOPE_VEHICLES] call FUNC(canEdit)}
        }];
    };
} forEach (_objectData select 3);
