// Built-in per-class cost table, in points (POINTS_MAX = a full resource bar).
// Overrides the inheritance-based category default for these exact classes;
// a mission's rtz_economy_overrides entry still wins over anything here.
//
// Each faction lives in its own file under defaultCosts\ and appends its
// [classname, cost] pairs to _costs. Add a faction by dropping a new file in
// that folder and including it below; later entries win on duplicate classes.
private _costs = [];

#include "defaultCosts\west\nato.inc.sqf"
#include "defaultCosts\west\natopacific.inc.sqf"
#include "defaultCosts\west\natowoodland.inc.sqf"
#include "defaultCosts\west\natodesert.inc.sqf"
#include "defaultCosts\west\ctrg.inc.sqf"
#include "defaultCosts\west\mjtf.inc.sqf"
#include "defaultCosts\west\marines.inc.sqf"
#include "defaultCosts\west\msf.inc.sqf"
#include "defaultCosts\west\gendarmerie.inc.sqf"
#include "defaultCosts\east\csat.inc.sqf"
#include "defaultCosts\east\viper.inc.sqf"
#include "defaultCosts\guerilla\aaf.inc.sqf"
#include "defaultCosts\guerilla\fia.inc.sqf"
#include "defaultCosts\guerilla\insurgents.inc.sqf"
#include "defaultCosts\guerilla\looters.inc.sqf"
#include "defaultCosts\guerilla\syndikat.inc.sqf"
#include "defaultCosts\guerilla\tura.inc.sqf"

// Project Anselm, whose two nations each field a Cold War and a 2035 line-up
#include "defaultCosts\west\sac.inc.sqf"
#include "defaultCosts\west\sac2035.inc.sqf"
#include "defaultCosts\east\atiu.inc.sqf"
#include "defaultCosts\east\atiu2035.inc.sqf"
#include "defaultCosts\guerilla\ubpr.inc.sqf"

// Keys are lowercased so lookups are immune to classname case differences
// between the hand-typed table and the engine's config names (same convention
// as rtz_common's defaultSkills table)
GVAR(defaultCosts) = createHashMapFromArray (_costs apply {
    _x params ["_class", "_cost"];
    [toLowerANSI _class, _cost]
});
