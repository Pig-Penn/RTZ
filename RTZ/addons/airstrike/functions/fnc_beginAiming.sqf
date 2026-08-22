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

// Never two at once. A second session would install a second set of handlers on the
// same display and only one of them would ever be removed.
if (GVAR(aiming) isNotEqualTo []) then {
    call FUNC(endAiming);
};

// _armed is the "ignore the frame we started on" guard. This session is opened by
// CLICKING a context-menu entry, so without it the very click that picked the weapon
// arrives at MouseButtonDown and latches the aim point instantly. rtz_path needs no
// such guard because it is opened by a keybind, and CBA keybinds cannot be bound to a
// mouse button; EFUNC(common,placementPreview) needs exactly this one.
GVAR(aiming) = [_objects, _args, [], -1, [], false];

private _handlers = [_display] call FUNC(handleAimInput);
GVAR(aiming) set [4, _handlers];

[QGVAR(aim), LINKFUNC(drawAim), RENDER_WORLD, 60] call EFUNC(core,registerRenderer);

true
