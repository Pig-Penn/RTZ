#include "script_component.hpp"

// The aim session's other three exits — commit, right-click, Escape — are all
// handlers on the curator display itself, so none of them fire if the display
// goes away out from under an open session: the curator exits Zeus, is kicked
// from curation, disconnects, or the display closes some other way mid-drag.
// This is the only exit that catches the display going away underneath it.
// FUNC(endAiming) already early-exits when GVAR(aiming) isEqualTo [], so calling
// it unconditionally on every display close costs nothing when no session is open.
["zen_curatorDisplayUnloaded", {call FUNC(endAiming)}] call CBA_fnc_addEventHandler;

// CBA event handlers for strike execution are registered here from Task 4.
