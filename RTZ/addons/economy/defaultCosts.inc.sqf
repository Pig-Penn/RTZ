// Built-in per-class cost table, in points (POINTS_MAX = a full resource bar).
// Overrides the inheritance-based category default for these exact classes;
// a mission's rtz_economy_overrides entry still wins over anything here.
//
// Each faction lives in its own file under defaultCosts\ and appends its
// [classname, cost] pairs to _costs. Add a faction by dropping a new file in
// that folder and including it below; later entries win on duplicate classes.
private _costs = [];

#include "defaultCosts\msf.inc.sqf"
#include "defaultCosts\csat.inc.sqf"
#include "defaultCosts\viper.inc.sqf"
#include "defaultCosts\aaf.inc.sqf"
#include "defaultCosts\fia.inc.sqf"
#include "defaultCosts\insurgents.inc.sqf"
#include "defaultCosts\looters.inc.sqf"
#include "defaultCosts\syndikat.inc.sqf"
#include "defaultCosts\tura.inc.sqf"

// Keys are lowercased so lookups are immune to classname case differences
// between the hand-typed table and the engine's config names (same convention
// as rtz_common's defaultSkills table)
GVAR(defaultCosts) = createHashMapFromArray (_costs apply {
    _x params ["_class", "_cost"];
    [toLowerANSI _class, _cost]
});
