#include "script_component.hpp"
/*
 * Author: Maxim
 * Opens the modal aim session for one airstrike: the curator presses on the target,
 * drags in the direction he wants the aircraft to fly, and releases.
 *
 * Entirely client-local. Nothing is broadcast and nothing is authoritative until the
 * mouse comes up — the curator owns the selection and the cursor, so there is no
 * reason for the server to hear about a strike being aimed.
 *
 * zen_common_fnc_selectPosition is not used because it is click-only: a bearing needs
 * a gesture with a start and an end, and it is the bearing that decides which ridge
 * the aircraft comes over and which way the ordnance walks.
 *
 * Arguments:
 * 0: Context position ASL <ARRAY> (unused; ZEN's context signature)
 * 1: Selected objects <ARRAY>
 * 2: Weapon row as [vehicle, weapon, turretPath, type] <ARRAY>
 *
 * Return Value:
 * A session was opened <BOOL>
 *
 * Example:
 * [_position, _objects, _args] call rtz_airstrike_fnc_beginAiming
 *
 * Public: No
 */

params ["", "_objects", "_args"];

private _display = findDisplay IDD_RSCDISPLAYCURATOR;
if (isNull _display) exitWith {false};

// ZEN's own picker is on the same display and consumes the same presses. Its
// re-entry guard reads this flag but only ever sees ZEN's sessions, and nothing on
// ZEN's side keeps a curator out of an RTZ action while one is open —
// zen_context_menu's keybind checks isPlacementActive but not this — so the test
// has to be made here. It is also what makes clearing the flag in FUNC(endAiming)
// safe: no ZEN session can be running underneath this one.
if (GETMVAR(zen_common_selectPositionActive,false)) exitWith {false};

// Never two at once. A second session would install a second set of handlers on the
// same display and only one of them would ever be removed.
if (GVAR(aiming) isNotEqualTo []) then {
    call FUNC(endAiming);
};

// Index 5 is a FRAME guard, not a one-shot flag: the frame this session opened
// on, tested in FUNC(handleAimInput) as `diag_frameNo > (GVAR(aiming) select 5)`
// — a frame number latched at open and only ever compared, never cleared.
// This session is opened by CLICKING a context-menu entry, so without a guard the
// very click that picked the weapon can arrive at this display's MouseButtonDown
// and latch the aim point instantly. A one-shot "swallow the first press" boolean
// is NOT equivalent: ZEN dispatches the context-menu action from a control-level
// MouseButtonDown handler (ZEN/addons/context_menu/functions/fnc_createContextGroup.sqf),
// and whether the display-level handler installed below also receives that SAME
// click is engine-ordering-dependent. If it never does, a boolean flipped by "the
// first press seen" would instead swallow the curator's first genuine press. A
// frame guard has no such failure mode: it compares frame numbers rather than
// consuming exactly one event, so it is correct whichever way the ordering falls.
// rtz_path needs no such guard at all because it is opened by a keybind, and CBA
// keybinds cannot be bound to a mouse button.
GVAR(aiming) = [_objects, _args, [], -1, [], diag_frameNo, false, -1];

// Stand ZEN's pickers down for the gesture's lifetime, the way ZEN stands its own
// down. Read by zen_common_fnc_selectPosition for re-entry and by
// zen_context_menu's right-click handler, which will not open a menu over an
// active picker. Set after the endAiming call above, which clears it.
zen_common_selectPositionActive = true;

private _handlers = [_display] call FUNC(handleAimInput);
GVAR(aiming) set [4, _handlers];

[QGVAR(aim), LINKFUNC(drawAim), RENDER_WORLD, 60] call EFUNC(core,registerRenderer);

true
