#include "script_component.hpp"
/*
 * Author: Maxim
 * Context-menu statement: resets every AI group in the selection back to a
 * clean slate via lambs_wp_fnc_taskReset. A selected/hovered man contributes
 * his group, a vehicle the groups of its crew (EFUNC(common,collectSquads));
 * groups with no AI members are skipped.
 *
 * LAMBS task functions must run where each group is local (not necessarily
 * the server — AI in a player-led group is local to that player), so the
 * whole selection goes into a single QGVAR(reset) event TARGETED AT THE
 * GROUPS: CBA delivers it once per owning machine and the handler filters to
 * its local groups (registered on every machine in XEH_postInit).
 *
 * The unit head-tag overlay (rtz_hud) shows the LAMBS task as one of its
 * fields; without help it would keep showing the pre-reset text until the next
 * ~0.3s gather tick lines up. That matters more here than elsewhere because the
 * reset is a HARD reset (see FUNC(resetApply)) — the units change group, so the
 * cached group id and tactic go stale too. So once the reset event is sent, this
 * also clears rtz_hud's subscription baseline, which makes its selection poll
 * re-report on the next tick and the server send the following gather in full
 * rather than diffing it away — the same "instant fill" path
 * EFUNC(hud,openSelectionInfo) uses on dialog open.
 *
 * Arguments:
 * 0: Selection objects <ARRAY>
 * 1: ZEN's selected groups <ARRAY>
 * 2: Hovered entity <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_objects, _groups, _hoveredEntity] call rtz_control_fnc_reset
 *
 * Public: No
 */

params ["_objects", "_groups", "_hoveredEntity"];

private _grps = +_groups;
{ _grps pushBackUnique _x } forEach ([_objects + [_hoveredEntity]] call EFUNC(common,collectSquads));
_grps = _grps select { units _x findIf { !isPlayer _x } != -1 };
if (_grps isEqualTo []) exitWith {};

[QGVAR(reset), [_grps], _grps] call CBA_fnc_targetEvent;

// Force an immediate head-tag refresh instead of waiting for the next stream
// tick: clearing rtz_hud's subscription baseline makes its selection poll
// re-report on its very next tick, and a fresh report resets the server's diff
// baseline so the next gather is sent in full rather than diffed away — which
// invalidates the tag cache as soon as it lands. Poking the baseline rather than
// firing the subscribe event directly keeps the payload's shape rtz_hud's own
// business. No-op if that addon isn't running (absent, or the display gated off).
if (GETEGVAR(hud,unitTagsVisible,false)) then {
    EGVAR(core,reported) = [];
};

[LLSTRING(MsgReset), count _grps] call EFUNC(common,showCountMessage);
