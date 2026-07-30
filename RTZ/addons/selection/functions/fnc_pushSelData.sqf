#include "script_component.hpp"
/*
 * Author: Maxim
 * SERVER ONLY. Gathers packets for one curator's reported infantry selection and
 * pushes them to that curator's client over QGVAR(selData). Called from the
 * report event (instant dialog fill) and from the gather PFH — both in
 * FUNC(selectionGather).
 *
 * Diff-gated: the gather still runs every tick (unit state has to be read to know
 * it has not changed), but an identical result is not re-serialized onto the
 * network, so an idle selection costs zero traffic.
 *
 * Arguments:
 * 0: Curator <OBJECT>
 * 1: Reported unit netIds <ARRAY of STRING>
 * 2: Curator's info dialog is open <BOOL> (default: false)
 *
 * Return Value:
 * None
 *
 * Example:
 * [_player, _sel, true] call rtz_selection_fnc_pushSelData
 *
 * Public: No
 */

params ["_player", "_sel", ["_detailed", false]];

// Virtual Zeus (VirtualMan_F) is the game master, not a PvP officer — exempt
// from the own-side filter below (mirrors the client poll's _anySide filter).
private _anySide = _player isKindOf "VirtualMan_F";
private _cSide   = side _player;

private _packets = [];
{
    private _unit = objectFromNetId _x;
    if (isNull _unit || { !alive _unit }) then { continue };
    if (!_anySide && { side _unit != _cSide }) then { continue };
    _packets pushBack ([_unit, _detailed] call FUNC(gatherUnitInfo));
} forEach (_sel select [0, SEL_MAX_UNITS]);

// Diff-gate. objNull default so a missing entry never compares equal to any array.
private _pk = netId _player;
if (_packets isEqualTo (GVAR(selLastSent) getOrDefault [_pk, objNull])) exitWith {};
GVAR(selLastSent) set [_pk, _packets];

[QGVAR(selData), [_packets], _player] call CBA_fnc_targetEvent;
