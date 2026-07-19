#include "script_component.hpp"

if (!hasInterface) exitWith {};

// ZEN fills its attribute registry at preInit, so this postInit wrap is ordered
call FUNC(wrapAttributes);

// Gated rows stay visible for the info their sliders show, so grey them out
// while locked: post-process every ZEN attribute window right after it is
// built. All open paths (double-click, keybind, Skills button) resolve
// zen_attributes_fnc_open by name at call time, so they all land here.
GVAR(zenAttributesOpen) = zen_attributes_fnc_open;
zen_attributes_fnc_open = {
    _this call GVAR(zenAttributesOpen);
    _this call FUNC(lockControls);
};
