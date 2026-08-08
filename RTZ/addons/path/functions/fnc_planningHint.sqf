#include "script_component.hpp"
/*
 * Author: Maxim
 * Puts up what the modifiers do for the session that has just opened, and takes
 * it down again a few seconds later.
 *
 * Path planning is modal and its modifiers are invisible — nothing on screen
 * says that Shift magnetises a vehicle path to the road, that Alt sets an
 * altitude, or that Ctrl-click cuts. A mode whose controls can only be found in
 * the keybind list is a mode most curators use one tenth of.
 *
 * Built from the kinds actually in the session. Wargame prints all six lines
 * every time, so a curator who selected three riflemen is told how to fly and
 * how to follow a road; here a rifle squad gets the three lines that apply to a
 * rifle squad.
 *
 * The expiry rides a GENERATION COUNTER rather than simply firing after
 * HINT_TIME. A second session opened inside that window would otherwise have its
 * hint wiped by the first one's timer — the same trap Wargame guards against
 * with jac_isPathDrawingActiveCutMsgId, and the reason the counter lives out
 * with the session state rather than being captured here.
 *
 * Arguments:
 * 0: Paths in the session <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_paths] call rtz_path_fnc_planningHint
 *
 * Public: No
 */

params ["_paths"];

// Every line the session could show, gathered once. `pushBackUnique` rather than
// a set per kind: a mixed selection gets each line once, in a fixed order, and
// the order is the order they are tested in here.
private _lines = [LLSTRING(HintTrace), LLSTRING(HintCut), LLSTRING(HintReset)];

{
    switch (_x select PATH_KIND) do {
        case KIND_INFANTRY: {
            _lines pushBackUnique LLSTRING(HintRotate);
            _lines pushBackUnique LLSTRING(HintTactical);
        };
        case KIND_LAND: {
            _lines pushBackUnique LLSTRING(HintRoad);
        };
        case KIND_AIR: {
            _lines pushBackUnique LLSTRING(HintAltitude);
        };
    };
} forEach _paths;

// hintSilent, not hint: this fires on entering a mode the curator asked for, and
// a notification chime every time would wear out fast.
hintSilent (_lines joinString endl);

GVAR(hintGeneration) = GVAR(hintGeneration) + 1;

[{
    params ["_generation"];

    // A later session has put up its own hint, and this timer no longer owns the
    // screen
    if (GVAR(hintGeneration) != _generation) exitWith {};

    hintSilent "";
}, [GVAR(hintGeneration)], HINT_TIME] call CBA_fnc_waitAndExecute;
