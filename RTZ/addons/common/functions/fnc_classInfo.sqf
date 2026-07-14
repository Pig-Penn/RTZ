#include "script_component.hpp"
/*
 * Author: Maxim
 * Per-class config info, cached for the whole mission: display name plus the
 * NCO ("leader" in the display name) and HQ ("officer"/"hq" in the display
 * name) substring tests. These are invariant per class, so each class pays the
 * config lookup exactly once per machine; shared by the spotting system and
 * the remote-control indicator.
 *
 * The cache GVAR(classInfoCache) is created in XEH_preInit so it exists on
 * every machine before any caller runs.
 *
 * Arguments:
 * 0: Unit to classify <OBJECT>
 *
 * Return Value:
 * [displayName <STRING>, isLeaderName <BOOL>, isHQName <BOOL>]
 *
 * Example:
 * [_unit] call rtz_common_fnc_classInfo
 *
 * Public: No
 */

params ["_unit"];

private _class = typeOf _unit;
private _info = GVAR(classInfoCache) get _class;
if (isNil "_info") then {
    private _dn = getText (configOf _unit >> "displayName");
    private _lc = toLower _dn;
    _info = [_dn, (_lc find "leader") >= 0, ((_lc find "officer") >= 0) || { (_lc find "hq") >= 0 }];
    GVAR(classInfoCache) set [_class, _info];
};
_info
