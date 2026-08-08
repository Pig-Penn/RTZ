#include "script_component.hpp"
/*
 * Author: Maxim
 * Builds the summary line the selection info dialog renders above its list.
 *
 * Four shapes, in order of specificity: nothing selected; nothing resolved yet;
 * one group, fully resolved, described in full (FUNC(groupDescriptor)); anything
 * else summarised as a count of groups and units with the selection-wide casualty
 * tallies.
 *
 * The single-group case deliberately requires _pending to be EMPTY. A unit whose
 * packet has not arrived may still turn out to belong to a second group once it
 * does, and a group descriptor scoped to only the resolved members would then be
 * describing the wrong thing; falling through to the summary is correct meanwhile
 * because it counts the total, pending included.
 *
 * Arguments:
 * 0: Group netIds in selection order <ARRAY>
 * 1: Group netId -> its packets <HASHMAP>
 * 2: Total selected units, pending included <NUMBER>
 * 3: netIds whose packet has not arrived yet <ARRAY>
 *
 * Return Value:
 * Header line <STRING>
 *
 * Example:
 * [_groupOrder, _groupMembers, _totalUnits, _pending] call rtz_hud_fnc_selectionHeader
 *
 * Public: No
 */

params ["_groupOrder", "_groupMembers", "_totalUnits", "_pending"];

private _numGroups = count _groupOrder;

private _header = switch (true) do {
    case (_totalUnits == 0): { LLSTRING(MsgNoUnitsSelected) };

    case (_numGroups == 0): {
        [LLSTRING(HeaderAwaitingData), [_totalUnits] call FUNC(unitCount)] call FUNC(joinRow)
    };

    case (_numGroups == 1 && { _pending isEqualTo [] }): {
        // Group descriptor only (name · N units · morale · tactic · down) — raw
        // AI state / combat mode is deliberately not surfaced.
        [_groupMembers get (_groupOrder select 0)] call FUNC(groupDescriptor)
    };

    default {
        // Selection-wide casualty tallies, counted HERE rather than up front: this
        // is the only branch that renders them, and the other three discarded a
        // full walk of every group's members on every rebuild — four times a
        // second for as long as the dialog is open.
        private _downTotal = 0;
        private _fleeTotal = 0;
        {
            // HashMap forEach: _y is the member list. The inner loop rebinds _x,
            // which is fine — nothing after it reads the key.
            {
                if (_x select PKT_DOWNED) then { _downTotal = _downTotal + 1 };
                if (FLAG_FLEEING in (_x select PKT_FLAGS)) then { _fleeTotal = _fleeTotal + 1 };
            } forEach _y;
        } forEach _groupMembers;

        [
            format [[LLSTRING(HeaderGroups), LLSTRING(HeaderGroup)] select (_numGroups == 1), _numGroups],
            format [LLSTRING(HeaderUnitsSelected), [_totalUnits] call FUNC(unitCount)],
            [format [LLSTRING(LabelDownCount), _downTotal], ""] select (_downTotal == 0),
            [format [LLSTRING(LabelFleeingCount), _fleeTotal], ""] select (_fleeTotal == 0)
        ] call FUNC(joinRow)
    };
};

// Selections beyond SEL_MAX_UNITS are silently dropped by the client poll
// (EFUNC(core,selectionPoll)) before they ever reach EGVAR(core,selUnits) — note
// it here so the curator has some indication their selection was cut down,
// instead of extra units just never appearing anywhere.
private _overflow = GETEGVAR(core,selOverflow,0);
if (_overflow > 0) then {
    _header = _header + " — " + format [LELSTRING(core,MsgSelectionTruncated), _overflow, SEL_MAX_UNITS];
};

_header
