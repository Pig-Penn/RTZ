#include "script_component.hpp"
/*
 * Author: Maxim
 * Opens the modal drawing session for one trench: the curator presses at one end of
 * the line, drags to the other, and releases.
 *
 * Entirely client-local. Nothing is broadcast and nothing is authoritative until the
 * mouse comes up — the curator owns the selection and the cursor, so there is no
 * reason for the server to hear about a trench being drawn.
 *
 * zen_common_fnc_selectPosition is not used because it is click-only: a trench needs
 * a gesture with a start and an end. Ported from rtz_airstrike's aim session, which
 * solves the same problem and carries the reasoning for both guards below.
 *
 * Arguments:
 * 0: Context position ASL <ARRAY> (unused; ZEN's context signature)
 * 1: Selected objects <ARRAY>
 *
 * Return Value:
 * A session was opened <BOOL>
 *
 * Example:
 * [_position, _objects] call rtz_dig_fnc_beginAiming
 *
 * Public: No
 */

params ["", "_objects"];

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

// AIM_FRAME is a FRAME guard, not a one-shot flag: this session is opened by
// CLICKING a context-menu entry, and whether that same click also reaches the
// display handler installed below is engine-ordering dependent. A boolean that
// swallowed "the first press seen" would eat the curator's first genuine press on
// the runs where it does not. See rtz_airstrike's FUNC(beginAiming) for the full
// argument, and EFUNC(common,placementPreview) for the same recipe.
GVAR(aiming) = [_objects, [], [], [], [], diag_frameNo, 0];

// Stand ZEN's pickers down for the gesture's lifetime, the way ZEN stands its own
// down. Set after the endAiming call above, which clears it.
zen_common_selectPositionActive = true;

private _handlers = [_display] call FUNC(handleAimInput);
GVAR(aiming) set [AIM_HANDLERS, _handlers];

[QGVAR(aim), LINKFUNC(drawAim), RENDER_WORLD, 60] call EFUNC(core,registerRenderer);

true
