// Built-in per-class cost table, in points (POINTS_MAX = a full resource bar).
// Overrides the inheritance-based category default for these exact classes;
// a mission's rtz_economy_overrides entry still wins over anything here.
//
// Each faction lives in its own file under defaultCosts\ and appends its
// [classname, cost] pairs to _costs. Add a faction by dropping a new file in
// that folder and including it below; later entries win on duplicate classes.
private _costs = [];

#include "defaultCosts\acm_msf.inc.sqf"
#include "defaultCosts\csat.inc.sqf"
#include "defaultCosts\guerilla.inc.sqf"

GVAR(defaultCosts) = createHashMapFromArray _costs;
