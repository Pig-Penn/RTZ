// CUP registers the Zubr's three helper scripts through CfgFunctions rather than
// CBA PREP, and the config references them by their built name from Eden
// attribute expressions and vehicle event handlers. Keeping CfgFunctions means
// those expressions in CfgVehicles.hpp stay byte-identical to CUP's apart from
// the tag, so the class names below must not be renamed.
//
// Produces rtz_csat_fnc_zubrEngineMonitor / _zubrMissileRangingFix / _zubrHullNumbers.

class CfgFunctions {
    class ADDON {
        tag = QUOTE(ADDON);

        class zubr {
            class zubrEngineMonitor {
                file = "\x\rtz\addons\zubr\zubr_hovercraft_assets\functions\fn_ZubrEngineMonitor.sqf";
                recompile = 1;
            };
            class zubrMissileRangingFix {
                file = "\x\rtz\addons\zubr\zubr_hovercraft_assets\functions\fn_zubrMissileRangingFix.sqf";
                recompile = 0;
            };
            class zubrHullNumbers {
                file = "\x\rtz\addons\zubr\zubr_hovercraft_assets\functions\fn_zubrhullnumbers.sqf";
                recompile = 0;
            };
        };
    };
};
