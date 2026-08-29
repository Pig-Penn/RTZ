// The same `function` override CfgVehicles.hpp installs on the Create Target module,
// applied to the fire mission DISPLAY: zen_modules_fnc_initDisplay resolves the
// display's function through getText (_config >> "function") in exactly the way
// initModule resolves a module's, so it is the one hook that hands RTZ the display
// object.
//
// It is needed because RTZ has no other way to reach that display. ZEN's module
// displays carry idd = -1 (zen_common/gui.hpp), so findDisplay cannot return one, and
// zen_modules_RscDisplay overrides the onLoad that would otherwise have parked it in
// uiNamespace as zen_common_display.
//
// The parent is restated rather than left off. A bare `class zen_modules_RscFireMission`
// re-declaration merges its members, but it also rewrites the recorded base class to
// nothing — the engine logs "Updating base class 'zen_modules_RscDisplay'->''" and the
// display is one config edit away from losing the onLoad that runs it at all.
// Forward-declaring the parent and inheriting from it is what rtz_restrict does for
// the same reason.
class zen_modules_RscDisplay;

// FUNC(guiFireMission) adds one Unload handler — which is how a cancelled mission
// gets its freshly created target deleted instead of leaving it in the target list —
// and then hands the display to ZEN unchanged. Inert for a fire mission opened from
// the module tree, since nothing is pending then.
class zen_modules_RscFireMission: zen_modules_RscDisplay {
    function = QFUNC(guiFireMission);
};
