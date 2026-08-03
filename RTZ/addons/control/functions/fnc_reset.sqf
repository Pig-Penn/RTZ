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

// Force an immediate refresh of everything watching this selection, instead of
// waiting for the next poll and stream tick: a fresh subscription resets the
// server's diff baseline, so the next gather is sent in full rather than diffed
// away, and whatever it lands in is invalidated as soon as it arrives. A reset
// changes AI state the packets describe (waypoints cleared, LAMBS task dropped)
// without changing the selection, so nothing else would prompt a re-send.
//
// Unconditional, and through the engine's own API. This used to poke
// EGVAR(core,reported) — the poll's private diff baseline — directly, and only
// when GETEGVAR(hud,unitTagsVisible) said rtz_hud's head tags were up. Two things
// wrong with that: this component does not depend on rtz_hud (it is not in
// requiredAddons) and has no business knowing that component owns tags, let alone
// which of its display flags is the interesting one; and the guard was wrong
// anyway, since the vehicle cards, the dialog and the AI-state overlays all read
// the same feed and all wanted the refresh. The comment also still described the
// baseline as rtz_hud's, which stopped being true when the engine moved to
// rtz_core. One call, no cross-component reach, no stale ownership claim.
// `[] call`, not a bare `call`: a bare one forwards THIS function's _this, which
// here is [_objects, _groups, _hoveredEntity], and the first element would land on
// reportNow's detail-override parameter.
[] call EFUNC(core,reportNow);

[LLSTRING(MsgReset), count _grps] call EFUNC(common,showCountMessage);
