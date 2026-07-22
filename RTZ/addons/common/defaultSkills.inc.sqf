// Built-in per-class overall skill table, on the engine's 0..1 scale.
// Every unit whose exact classname appears here gets setSkill applied on
// spawn (all sub-skills at once); classes not listed are left untouched.
//
// Each faction lives in its own file under defaultSkills\ and appends its
// [classname, skill] pairs to _skills. Add a faction by dropping a new file
// in that folder and including it below; later entries win on duplicates.
private _skills = [];

#include "defaultSkills\csat.inc.sqf"
#include "defaultSkills\msf.inc.sqf"
#include "defaultSkills\gendarmerie.inc.sqf"

// Keys are lowercased so lookups are immune to classname case differences
GVAR(defaultSkills) = createHashMapFromArray (_skills apply {
    _x params ["_class", "_skill"];
    [toLowerANSI _class, _skill]
});
