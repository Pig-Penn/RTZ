#include "script_component.hpp"

if (!hasInterface) exitWith {};

// ZEN fills its attribute registry at preInit, so this postInit wrap is ordered.
// The visual half (FUNC(lockControls)) is wired in via the hook control gui.hpp
// merges into ZEN's attribute display — zen_attributes_fnc_open itself is
// compiled final by CBA and cannot be wrapped by reassignment.
call FUNC(wrapAttributes);
