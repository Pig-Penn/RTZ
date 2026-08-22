#include "script_component.hpp"

// The aim session's other three exits — commit, right-click, Escape — are all
// handlers on the curator display itself, so none of them fire if the display
// goes away out from under an open session: the curator exits Zeus, is kicked
// from curation, disconnects, or the display closes some other way mid-drag.
// This is the only exit that catches the display going away underneath it.
// FUNC(endAiming) already early-exits when GVAR(aiming) isEqualTo [], so calling
// it unconditionally on every display close costs nothing when no session is open.
["zen_curatorDisplayUnloaded", {call FUNC(endAiming)}] call CBA_fnc_addEventHandler;

// Sent by FUNC(orderStrike) on the curator's client, targeted at the machine that owns
// the aircraft.
[QGVAR(execute), LINKFUNC(executeStrike)] call CBA_fnc_addEventHandler;

// Sent by FUNC(endStrike) when a strike ends with its aircraft and driver on different
// machines. The receiving copy re-runs the same teardown and picks out whatever is
// local to it; _reroute is false so a split pair cannot bounce the event back and
// forth between two owners forever.
[QGVAR(release), {
    params ["_record", "_reroute"];
    [_record, _reroute] call FUNC(endStrike);
}] call CBA_fnc_addEventHandler;
