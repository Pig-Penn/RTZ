#include "script_component.hpp"

if (!hasInterface) exitWith {};

// ZEN fills its attribute registry at preInit, so reading it here is ordered.
// Enforcement itself is installed per window by FUNC(gateDisplay), wired in
// through the hook control gui.hpp merges into ZEN's attribute display —
// zen_attributes_fnc_open is compiled final by CBA and cannot be wrapped.
call FUNC(initGate);
