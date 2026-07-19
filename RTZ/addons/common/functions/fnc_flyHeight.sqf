#include "script_component.hpp"
/*
 * Author: Maxim
 * Keybind handler: raises or lowers the AI fly-in height of the Zeus-selected
 * aircraft, RTS-style, without opening a context-menu action first. Each
 * press nudges the height by GVAR(heliHeightStep) metres in the given
 * direction; only AI-piloted aircraft actually obey flyInHeight, so a
 * player-flown or empty helicopter is a harmless no-op.
 *
 * Applies to whole aircraft from the current selection (an individually
 * selected crew member is skipped; select the aircraft to order it).
 * flyInHeight is a local-effect command, so each helicopter gets a
 * QGVAR(adjustHeliHeight) event targeted at the aircraft itself — CBA
 * delivers it to whatever machine the vehicle is local to (server, headless
 * client, or a remote-controlling player), so no locality checks or server
 * round-trip are needed; handler registered on
 * every machine in XEH_postInit).
 *
 * Arguments:
 * 0: Direction: 1 to raise, -1 to lower <NUMBER>
 *
 * Return Value:
 * Press was handled (consumed) <BOOL>
 *
 * Example:
 * [1] call rtz_common_fnc_flyHeight
 *
 * Public: No
 */

params [["_dir", 0, [0]]];

// Non-null only while this machine's Zeus interface is open
if (isNull curatorCamera) exitWith { false };

// Typing in the Zeus search box (ZEN sets this flag): don't hijack the keystroke
if (GETMVAR(RscDisplayCurator_search,false)) exitWith { false };

// Whole helicopters from the current Zeus selection. A crewed-in man fails
// the objectParent test and is skipped.
private _aircraft = SELECTED_OBJECTS select {
    _x isKindOf "Helicopter"
    && {alive _x}
    && {isNull objectParent _x}
};
if (_aircraft isEqualTo []) exitWith {false};

private _delta = _dir * GETGVAR(heliHeightStep,5);

{
    [QGVAR(adjustHeliHeight), [_x, _delta], _x] call CBA_fnc_targetEvent;
} forEach _aircraft;

[LSTRING(MsgFlyHeight), ["", "+"] select (_delta > 0), _delta] call zen_common_fnc_showMessage;

true
