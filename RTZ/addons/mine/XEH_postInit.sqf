#include "script_component.hpp"

// Orders are executed where the ordered unit is local
[QGVAR(place), LINKFUNC(placeMine)] call CBA_fnc_addEventHandler;

if (!hasInterface) exitWith {};

// Only mark spotted mines while the Zeus display is open
["zen_curatorDisplayLoaded", {_this call FUNC(start)}] call CBA_fnc_addEventHandler;
["zen_curatorDisplayUnloaded", {call FUNC(stop)}] call CBA_fnc_addEventHandler;

// FUNC(start) registers only the handlers whose setting is on and tears down the
// ones whose setting went off, so re-running it IS the toggle. Applying it live
// means a curator flipping a marker off stops paying for it immediately rather
// than at the next mission — and it is the reason neither draw function has to
// re-test its setting every frame.
["CBA_SettingChanged", {
    params ["_name"];

    if !((toLower _name) in [toLower QGVAR(mark3D), toLower QGVAR(markMap)]) exitWith {};

    // Nothing to start unless Zeus is actually open — FUNC(start) is otherwise
    // only ever reached through zen_curatorDisplayLoaded, and the markers are
    // deliberately a curator-only overlay
    if (isNull (findDisplay IDD_RSCDISPLAYCURATOR)) exitWith {};

    [] call FUNC(start);
}] call CBA_fnc_addEventHandler;
