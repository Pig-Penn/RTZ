#include "script_component.hpp"
/*
 * rtz_control_fnc_lambsReset
 *
 * Context-menu statement: clears the LAMBS Danger FSM state of every AI group
 * in the selection via lambs_wp_fnc_taskReset. A selected/hovered man
 * contributes his group, a vehicle the groups of its crew
 * (EFUNC(common,collectSquads)); groups with no AI members are skipped.
 *
 * LAMBS task functions must run where each group is local (not necessarily
 * the server — AI in a player-led group is local to that player), so the
 * whole selection goes into a single QGVAR(lambsReset) event TARGETED AT THE
 * GROUPS: CBA delivers it once per owning machine and the handler filters to
 * its local groups (registered on every machine in XEH_postInit).
 *
 * The unit head-tag overlay (rtz_selection) shows the LAMBS task as one of its
 * fields; without help it would keep showing the pre-reset text until the next
 * ~0.3s gather tick lines up. So once the reset event is sent, this also
 * re-sends this client's current selection report — reusing the same
 * "instant fill" path rtz_fnc_openSelectionInfo uses on dialog open — so the
 * server pushes fresh data immediately and the tag cache invalidates right away.
 *
 * Parameters:
 *   0: Array  — selection objects
 *   1: Array  — ZEN's selected groups
 *   2: Object — hovered entity
 */

params ["_objects", "_groups", "_hoveredEntity"];

private _grps = +_groups;
{ _grps pushBackUnique _x } forEach ([_objects + [_hoveredEntity]] call EFUNC(common,collectSquads));
_grps = _grps select { units _x findIf { !isPlayer _x } != -1 };
if (_grps isEqualTo []) exitWith {};

[QGVAR(lambsReset), [_grps], _grps] call CBA_fnc_targetEvent;

// Force an immediate head-tag refresh instead of waiting for the next
// ~0.3s gather tick: re-send this client's current selection report so
// the server pushes fresh selData right away (same instant-fill path
// rtz_fnc_openSelectionInfo uses on dialog open), which invalidates
// rtz_selection's tag cache as soon as it arrives. No-op if the unit
// tag overlay isn't running (addon absent or feature toggled off).
if (GETEGVAR(selection,tagsVisible,false)) then {
    [QEGVAR(selection,selSelection), [player, GETEGVAR(selection,selCurrent,[])]] call CBA_fnc_serverEvent;
};

private _msg = LLSTRING(MsgReset);
if (count _grps > 1) then { _msg = format ["%1  x%2", _msg, count _grps]; };
[_msg] call zen_common_fnc_showMessage;
