// CUP registers the Zubr's three helper scripts through CfgFunctions rather than
// CBA PREP, and the config references them by their built name from Eden
// attribute expressions and vehicle event handlers. Keeping CfgFunctions means
// those expressions in CfgVehicles.hpp stay byte-identical to CUP's apart from
// the tag, so the class names below must not be renamed.
//
// Produces rtz_zubr_fnc_zubrEngineMonitor / _zubrMissileRangingFix / _zubrHullNumbers
// (tag = ADDON = PREFIX_COMPONENT = rtz_zubr). The generated config expressions in
// CfgVehicles.hpp named rtz_csat_fnc_* until 2026-08-29 — a leftover of the
// addons/csat -> addons/zubr rename — so all five resolved to nil and `spawn nil`
// threw. `hemtt check` cannot see that: the call sites are string literals inside
// config properties. If this addon is ever renamed again, grep the config for the
// old tag and fix _rip/gen_config.py's FUNCS table with it.

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
