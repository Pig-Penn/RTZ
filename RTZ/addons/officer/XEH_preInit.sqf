#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

#include "initSettings.inc.sqf"

// Areas added by THIS client's curator: officerNetId -> [areaId]. The centre and
// radius are not tracked — an area never moves after it is planted, so nothing
// ever needs to re-read them (see FUNC(monitorAreas)).
// Created eagerly so every reader (toggle, modifier) is safe before the monitor starts.
GVAR(areas) = createHashMap;
GVAR(nextAreaId) = AREA_ID_BASE;

// Post-removal placement lock, THIS client only: officerNetId -> CBA_missionTime
// an area may next be added. See FUNC(isOnCooldown).
GVAR(cooldowns) = createHashMap;

// className -> isOfficer verdict, so the string scan runs once per class (see FUNC(isOfficer))
GVAR(classCache) = createHashMap;

ADDON = true;
