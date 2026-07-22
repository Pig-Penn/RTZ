#include "script_component.hpp"
/*
 * Author: Maxim
 * ── THE ONE PLACE TO RENAME TAG TEXT ─────────────────────────────────────────
 * Fills GVAR(tagLabels) — the display-label remap the unit head tags
 * (FUNC(unitTags)) and vehicle tags (FUNC(vehicleTags)) run every LAMBS
 * task / tactic string (and RTZ's own status words / flags) through before
 * drawing. LAMBS emits these strings live; RTZ never stored them, so this table
 * is where you re-word them.
 *
 * HOW TO EDIT: each row is ["<raw string>", "<what the tag shows>"]. Change ONLY
 * the RIGHT-hand string. The left key must stay byte-for-byte what LAMBS/RTZ
 * produces or the row simply won't match (and the raw string shows through — no
 * error). Set the right side to "" to blank a label out of the line entirely.
 * Rows default to identity (left == right) so out of the box nothing changes;
 * every possible string is listed so you can see what's available to rename.
 *
 * Anything NOT in the table passes through unchanged (getOrDefault), so a future
 * LAMBS task you didn't list still shows its raw name rather than vanishing.
 *
 * Keys are matched EXACTLY (case-sensitive) — copy them verbatim. A few LAMBS
 * tasks are built with format ["Hide (%1)", _action] etc.; only the fixed forms
 * listed here can be remapped, dynamic variants show raw.
 *
 * Called once from XEH_preInit on interface machines (the tags are client-only),
 * right after GVAR(tagLabels) is created.
 *
 * Arguments: None
 *
 * Return Value:
 *   Number of rows loaded <NUMBER>
 *
 * Example:
 * call rtz_selection_fnc_loadTagLabels
 *
 * Public: No
 */

private _pairs = [
    // ═══ TACTICS — the "TAC …" segment (group-level, leader tag / vehicle) ═══
    // Reactive combat tactics (LAMBS danger component)
    ["Contact!",            "Contact"],
    ["Attacking",           "Attacking"],
    ["Assaulting",          "Assaulting"],
    ["Flanking",            "Flanking"],
    ["CQB clearing",        "Clearing"],
    ["Suppressing",         "Suppressing"],
    ["Hiding",              "Hiding"],
    ["Holding!",            "Holding"],
    ["Garrison/Rally",      "Garrison/Rally"],
    ["Reinforcing",         "Reinforcing"],
    // Waypoint tactics (raw internal names — rename to taste)
    ["taskPatrol",          "taskPatrol"],
    ["taskHunt",            "taskHunt"],
    ["taskGarrison",        "taskGarrison"],
    ["taskCamp",            "taskCamp"],
    ["taskDefend",          "taskDefend"],
    ["taskCreep",           "taskCreep"],
    ["taskRush",            "taskRush"],
    ["taskAssault",         "taskAssault"],
    ["taskRetreat",         "taskRetreat"],
    ["taskCQB",              "taskCQB"],
    ["taskArtillery",       "taskArtillery"],

    // ═══ TASKS — the coloured status word (per unit / vehicle) ═══
    // Contact & assessment
    ["Tactics Assess",              "Assess"],
    ["Heard scream!",               "Heard scream!"],
    ["Incapacitated",               "Incapacitated"],
    // Assault / advance
    ["Assault",                     "Assault"],
    ["Assault Building",            "Assault Building"],
    ["Assault (sympathetic)",       "Assault (Sympathetic)"],
    ["Tactics Assault",             "Tactics Assault"],
    ["Rushing Assault",             "Rushing Assault"],
    ["Rushing Retreat",             "Rushing Retreat"],
    ["Reinforce",                   "Reinforce"],
    ["Tactics Attack",              "Tactics Attack"],
    // Suppress
    ["Suppress!",                   "Suppress"],
    ["Leader Suppress",             "Leader Suppress"],
    ["Group Suppress",              "Group Suppress"],
    ["Group Suppress (Move)",       "Group Suppress (Move)"],
    // Flank
    ["Tactics Flank",               "Tactics Flank"],
    ["Group Flank",                 "Group Flank"],
    ["Group Flank - Suppress",      "Group Flank - Suppress"],
    ["Group Flank - Suppressing!",  "Group Flank - Suppressing!"],
    ["Group Flank - Manoeuvring!",  "Group Flank - Manoeuvring!"],
    // Hide / flee / cover
    ["Hide!",                       "Hide"],
    ["Hide (inside)",               "Hide (inside)"],
    ["Hide (re-hide)",              "Hide (re-hide)"],
    ["Leader Hide",                 "Leader Hide"],
    ["Fleeing",                     "Flee"],
    ["Fleeing (vehicle)",           "Flee (vehicle)"],
    ["Fleeing (enemy near)",        "Flee (enemy near)"],
    ["Panic",                       "Panic"],
    ["Dodge!",                      "Dodge"],
    ["Repositioning",               "Reposition"],
    ["Stay inside",                 "Stay inside"],
    ["Stay inside (reposition)",    "Stay inside (reposition)"],
    // Garrison / CQB
    ["Tactics Garrison",            "Tactics Garrison"],
    ["Group Garrison",              "Group Garrison"],
    ["Tactics CQB",                 "Tactics CQB"],
    ["taskCQB - Rush enemy",        "taskCQB - Rush enemy"],
    ["taskCQB - Clearing rooms",    "taskCQB - Clearing rooms"],
    // Support actions
    ["Shoot UGL",                   "Flushing"],
    ["Throwing smoke grenade",      "Smoking"],
    ["Checking bodies",             "Looting"],
    ["Checking bodies (unknown)",   "Loot (Unknown)"],
    ["Leader Artillery",            "Leader Artillery"],
    ["Deploy Static Weapon",        "Assemble"],
    ["Pack Static Weapon",          "Pack"],
    ["Deploy Commando Mortar",      "Assemble"],
    // Vehicle tasks (shown on vehicle tags)
    ["Vehicle Suppress",            "Suppress"],
    ["Vehicle Rotate",              "Rotate"],
    ["Vehicle Assault",             "Scratch"],
    ["Vehicle Assault Move",        "Assault"],
    ["Jink Vehicle",                "Jink"],
    ["Mortar Fire",                 "Mortar Fire"],
    ["Dismounting troops",          "Dismount"],

    // ═══ RTZ-OWNED STATUS WORDS (always shown, colour-coded) ═══
    ["DOWN",        "DOWN"],       // unit incapacitated (red)
    ["FLEEING",     "FLEEING"],    // unit fleeing (red)
    ["LOW FUEL",    "LOW FUEL"],   // vehicle (amber)
    ["DAMAGED",     "DAMAGED"],    // vehicle (red)

    // ═══ STATUS FLAGS (unit flag-icon hover / vehicle warning line) ═══
    ["PATH OFF",    "PATH OFF"],
    ["MOVE OFF",    "MOVE OFF"],
    ["FORCED",      "FORCED"],
    ["HIDDEN",      "HIDDEN"],
    ["INSIDE",      "INSIDE"],
    ["BUSY",        "BUSY"],
    ["MOUNTED",     "MOUNTED"],
    ["WOUNDED",     "WOUNDED"]
];

{ GVAR(tagLabels) set _x } forEach _pairs;

count _pairs
