#include "script_component.hpp"
ADDON = false;
#include "XEH_PREP.hpp"

#include "initSettings.inc.sqf"

// Server-side gather caches, filled lazily: magazine class → capacity
// (fnc_gatherUnitInfo) and vehicle class → total seat count
// (fnc_gatherVehicleInfo).
if (isServer) then {
    GVAR(magCapCache)   = createHashMap;
    GVAR(seatCntCache)  = createHashMap;
};

// Display-label tables. Consumed only by the render paths (dialog rows, unit /
// vehicle tags, overlay cards), all client-only, so they are built on interface
// machines. Both hold LOCALIZED text: the packets carry stable wire tokens
// (FLAG_*, STATUS_*, LAMBS' own task/tactic strings) and these turn them into
// something a curator should read — resolved once here, never per frame.
if (hasInterface) then {
    GVAR(tagLabels) = createHashMap;
    call FUNC(loadTagLabels);

    // LAMBS danger causes, indexed by dangerType + 2. Blank keys stay blank
    // ("No Danger" is deliberately not labelled — see DANGER_LABEL_KEYS).
    GVAR(dangerLabels) = DANGER_LABEL_KEYS apply {
        ["", localize _x] select (_x != "")
    };
};

ADDON = true;
