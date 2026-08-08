#include "script_component.hpp"
/*
 * Author: Maxim
 * Builds the shared "GRP · N units · Morale x% · TAC y · z down" descriptor for
 * one group's packets. Used twice: as the whole header when a single group is
 * selected (FUNC(selectionHeader)), and as the group separator row when more than
 * one is (FUNC(buildSelectionRows)).
 *
 * The display name comes from the members' groupId field (PKT_GRPID), never from
 * the bucket key — the key is a group NETID, chosen precisely because copy-pasted
 * compositions duplicate callsigns and two distinct groups must not merge under
 * one header. Rendering the key would put a netId on screen.
 *
 * Morale is averaged over the LOCAL members only. It is a locality-bound read and
 * arrives as -1 for a unit owned elsewhere (a headless client, or one being
 * remote-controlled), which would drag a real average down toward nothing; with
 * no local members at all the segment drops out rather than reporting a figure
 * nobody measured.
 *
 * Was three inline closures over the member list — an average, a tactic scan and
 * a down tally — each rebuilt and each walking the same array. One pass now.
 *
 * Arguments:
 * 0: One group's packets, leader first <ARRAY>
 *
 * Return Value:
 * Descriptor line <STRING>
 *
 * Example:
 * [_members] call rtz_hud_fnc_groupDescriptor
 *
 * Public: No
 */

params ["_members"];

private _sum   = 0;
private _local = 0;
private _down  = 0;
private _tac   = "";

{
    if (_x select PKT_ISLOCAL) then {
        _sum = _sum + linearConversion [-1, 1, _x select PKT_MORALE, 0, 100, true];
        _local = _local + 1;
    };
    if (_x select PKT_DOWNED) then { _down = _down + 1 };
    // First non-empty LAMBS tactic in the group ("" throughout without LAMBS).
    if (_tac == "" && { (_x select PKT_TACTIC) != "" }) then { _tac = _x select PKT_TACTIC };
} forEach _members;

// `1 max _local` guards the divide; the select then discards the result when
// there were no local members at all.
private _mor = [-1, round (_sum / (1 max _local))] select (_local > 0);

[
    toUpper ((_members select 0) select PKT_GRPID),
    [count _members] call FUNC(unitCount),
    [format [LLSTRING(LabelMorale), _mor], ""] select (_mor < 0),
    [format [LLSTRING(LabelTactic), _tac], ""] select (_tac == ""),
    [format [LLSTRING(LabelDownCount), _down], ""] select (_down == 0)
] call FUNC(joinRow)
