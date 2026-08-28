#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        // rtz_core owns the single Draw3D handler every RTZ display draws from,
        // which this component registers FUNC(drawSpots) and FUNC(drawRcIndicator)
        // with. That is the only RTZ dependency this component's drawing carries.
        //
        // rtz_hud is deliberately NOT listed. The two renderers used to live over
        // there, which required it — but they read six of this component's globals
        // in the process, so rtz_hud depended on rtz_spotting just as hard while
        // declaring nothing, and a mutual requiredAddons leaves Arma's load order
        // between the two undefined. The renderers moved here, to the data they
        // read; now neither addon needs the other.
        //
        // rtz_officer is deliberately NOT listed either, and this is the one RTZ
        // edge in the mod that is real in code but absent here ON PURPOSE.
        // FUNC(spotCheck) reads RTZ_officerZoneMap to draw enemy editing-zone
        // rings. That read is a SOFT one by construction: a bare RTZ_-prefixed
        // global rather than an EGVAR, with an empty-map default, so rtz_officer
        // being absent is a supported configuration rather than a fault. Nor is
        // there a load-order hazard to fix — rtz_officer creates the map in its
        // postInit and this component reads it at tick time, long after. Listing
        // it would convert an optional feature into a hard requirement and stop
        // the mod loading without that PBO, which is strictly worse than the
        // nothing it would buy. Soft edges belong in a comment, not in
        // requiredAddons; see docs/Architecture.md.
        requiredAddons[] = {"rtz_main", "rtz_common", "rtz_core", "zen_common", "zen_context_menu"};
        author = "Maxim";
        authors[] = {"Maxim"};
        url = "";
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
