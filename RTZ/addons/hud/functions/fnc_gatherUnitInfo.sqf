#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER ONLY. Reads one infantry unit's state into a compact packet mirroring
 * the LAMBS Danger debug overlay: behaviour, unit state, current command,
 * current task/tactic, danger cause + range + timeout, current target +
 * visibility, known-enemy and group-memory counts, morale, suppression, health,
 * and status flags.
 *
 * AI fields are only meaningful where the unit is LOCAL, so they are read under
 * an `if (local _unit)` guard; for a non-local unit — owned by a Headless
 * Client, or currently remote-controlled by another curator's client — they
 * stay at their defaults and `_isLocal` is sent false, so the client shows an
 * honest "no live data" note instead of misleading zeros. Identity (netId,
 * leader, group, role, name, side, behaviour, health, MOUNTED/WOUNDED flags)
 * is valid on every machine and always filled in.
 *
 * `_detailed` gates the two genuinely expensive reads — `targetsQuery` (known
 * enemies, leaders only) and `checkVisibility` (target visibility). Both are
 * consumed ONLY by the info dialog's hover tooltip and the unit tag's threat
 * hover, so a curator running tags alone should not pay for them on every unit
 * on every tick. They come back at -1 when not gathered, which the render paths
 * already treat as "omit".
 *
 * Packet layout (index → field) — kept in lockstep with FUNC(buildSelectionRows)
 * and FUNC(buildTagEntry):
 *   0 netId  1 isLdr  2 grpId  3 role  4 sideNum  5 name
 *   6 behaviour  7 unitState  8 currentCommand  9 morale  10 suppression
 *   11 flags[]  12 downed  13 task  14 tactic
 *   15 dangerType  16 dangerDist(m)  17 dangerTimeout(s)
 *   18 targetType  19 targetVisibility  20 knownEnemies  21 groupMemory
 *   22 isLocal  23 healthPct  24 grpNetId  25 primaryAmmo  26 primaryAmmoCap
 *
 * grpNetId is the bucketing key client-side; grpId (2) is display-only —
 * two groups can share a groupId string (copy-pasted compositions).
 *
 * flags[] carries the FLAG_* wire tokens from script_component.hpp, never
 * display text: the client tests them and resolves each to a localized label
 * through GVAR(tagLabels) at render time.
 *
 * Arguments:
 * 0: Unit to read <OBJECT>
 * 1: Its netId, already resolved by the stream engine <STRING>
 * 2: Gather the dialog-only intel (targetsQuery / checkVisibility) <BOOL> (default: false)
 *
 * Return Value:
 * Packet <ARRAY>
 *
 * Example:
 * [_unit, netId _unit, true] call rtz_hud_fnc_gatherUnitInfo
 *
 * Public: No
 */

params ["_unit", "_netId", ["_detailed", false]];

private _grp     = group _unit;
private _isLdr   = _unit isEqualTo (leader _grp);
private _isLocal = local _unit;
private _sideNum = SIDE_NUM(side _unit);
// Cached per-class display name (mission-long cache in rtz_common) — avoids a config
// read on every unit on every gather tick. Element 0 is the display name.
private _role    = (_unit call EFUNC(common,classInfo)) select 0;

// Locality-bound fields, defaulted for the non-local case.
private _morale        = -1;
private _supp          = -1;
private _state         = "";
private _cmd           = "";
private _flags         = [];
private _downed        = false;
private _task          = "";
private _tactic        = "";
private _dangerType    = -1;
private _dangerDist    = -1;
private _dangerTimeout = -1;
private _tgtType       = "";
private _tgtVis        = -1;
private _known         = -1;
private _groupMem      = -1;
private _ammo          = -1;
private _ammoCap       = -1;

if (_isLocal) then {
    _morale = morale _unit;
    _supp   = getSuppression _unit;
    _state  = getUnitState _unit;
    _cmd    = currentCommand _unit;
    _downed = lifeState _unit isEqualTo "INCAPACITATED";

    // Rounds left in the current primary-weapon magazine and its capacity
    // (-1: no primary / no mag loaded / non-local) — consumed by the unit head
    // tags and the dialog tooltip. Capacity is a per-magazine-class config read,
    // cached mission-long by EFUNC(common,magazineCapacity) — the same cache
    // rtz_control and rtz_supply ask, rather than a fourth private copy.
    private _wpn = primaryWeapon _unit;
    if (_wpn != "") then {
        _ammo = _unit ammo _wpn;
        private _mag = primaryWeaponMagazine _unit param [0, ""];
        if (_mag != "") then {
            _ammoCap = [_mag] call EFUNC(common,magazineCapacity);
        };
    };

    // LAMBS danger snapshot: [dangerType, dangerPos, dangerTime, currentTarget].
    private _dc = _unit getVariable ["lambs_main_FSMDangerCauseData", [-1, [0, 0, 0], -1]];
    _dangerType = _dc param [0, -1];
    private _dPos = _dc param [1, [0, 0, 0]];
    if (_dPos isNotEqualTo [0, 0, 0]) then { _dangerDist = round (_unit distance _dPos) };
    private _dTime = _dc param [2, -1];
    if (_dTime > 0) then { _dangerTimeout = round ((_dTime - time) max 0) };

    // Current target — prefer the LAMBS-tracked target, fall back to the engine's.
    private _tgt = _dc param [3, objNull];
    if (!(_tgt isEqualType objNull) || { isNull _tgt }) then { _tgt = getAttackTarget _unit };
    if (!isNull _tgt && { _tgt isNotEqualTo _unit }) then {
        // Same mission-long per-class cache as _role above — this used to be a
        // raw config read per targeting unit per tick.
        _tgtType = (_tgt call EFUNC(common,classInfo)) select 0;
        // Only the dialog tooltip and the tag's threat hover show the number.
        if (_detailed) then {
            _tgtVis = [objNull, "VIEW", objNull] checkVisibility [eyePos _unit, eyePos _tgt];
        };
    };

    // Status tags (mirrors the flags drawn by the LAMBS debug overlay).
    if !(_unit checkAIFeature "PATH") then { _flags pushBack FLAG_PATH_OFF };
    if !(_unit checkAIFeature "MOVE") then { _flags pushBack FLAG_MOVE_OFF };
    if (_unit getVariable ["lambs_danger_forceMove", false]) then { _flags pushBack FLAG_FORCED };
    if (fleeing _unit)                    then { _flags pushBack FLAG_FLEEING };
    if (isHidden _unit)                   then { _flags pushBack FLAG_HIDDEN };
    if (insideBuilding _unit isEqualTo 1) then { _flags pushBack FLAG_INSIDE };
    if !(unitReady _unit)                 then { _flags pushBack FLAG_BUSY };

    // LAMBS enrichment — "" / -1 (omitted client-side) when LAMBS isn't loaded.
    _task   = _unit getVariable ["lambs_main_currentTask", ""];
    _tactic = _grp  getVariable ["lambs_main_currentTactic", ""];
    // targetsQuery allocates and scans the whole known-target list; dialog only.
    if (_isLdr && _detailed) then {
        _groupMem = count (_grp getVariable ["lambs_main_groupMemory", []]);
        _known = count ((_unit targetsQuery [objNull, sideUnknown, "", [], 0]) select {
            ((side _unit) isNotEqualTo (side (_x select 1))) || { side (_x select 1) isEqualTo civilian }
        });
    };
};

// Mounted state and health are global (objectParent / damage read on any machine).
if !(isNull objectParent _unit) then { _flags pushBack FLAG_MOUNTED };
private _hp = (round ((1 - damage _unit) * 100)) max 0;
if (_hp <= 65) then { _flags pushBack FLAG_WOUNDED };

[
    _netId, _isLdr, groupId _grp, _role, _sideNum, name _unit,
    behaviour _unit, _state, _cmd, _morale, _supp, _flags, _downed,
    _task, _tactic, _dangerType, _dangerDist, _dangerTimeout,
    _tgtType, _tgtVis, _known, _groupMem, _isLocal, _hp,
    netId _grp, _ammo, _ammoCap
]
