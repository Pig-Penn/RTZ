#include "script_component.hpp"
/*
 * Author: Maxim
 * ── THE ONE PLACE TO RENAME TAG TEXT ─────────────────────────────────────────
 * Fills GVAR(tagLabels) — the display-label remap every render path in this
 * component (unit tags, vehicle tags, dialog rows) runs its LAMBS task /
 * tactic strings and RTZ's own status tokens through before drawing.
 *
 * The table has two halves, and they are edited differently:
 *
 *   1. LAMBS TASKS AND TACTICS — plain string → plain string. LAMBS emits these
 *      live and does not localize them; RTZ never stored them. Change ONLY the
 *      RIGHT-hand string. The left key must stay byte-for-byte what LAMBS
 *      produces or the row simply won't match (and the raw string shows through
 *      — no error). Set the right side to "" to blank a label out of the line
 *      entirely. Rows default to identity (left == right) so out of the box
 *      nothing changes; every possible string is listed so you can see what's
 *      available to rename.
 *
 *   2. RTZ-OWNED TOKENS (FLAG_*, STATUS_*) — token → LLSTRING. These are RTZ's
 *      own words, so they live in stringtable.xml like all other user-facing
 *      text; the packets carry only the stable token. To re-word one, edit its
 *      stringtable entry (or point the row at a different key) — do NOT put a
 *      bare literal here, and never change a token, which the render paths
 *      compare against (`FLAG_FLEEING in _flags`).
 *
 * Anything NOT in the table passes through unchanged (getOrDefault), so a future
 * LAMBS task you didn't list still shows its raw name rather than vanishing.
 *
 * Keys are matched EXACTLY (case-sensitive) — copy them verbatim. A few LAMBS
 * tasks are built with format ["Hide (%1)", _action] etc.; only the fixed forms
 * listed here can be remapped, dynamic variants show raw.
 *
 * Called once from XEH_preInit on interface machines (every consumer is
 * client-only), right after GVAR(tagLabels) is created.
 *
 * Arguments: None
 *
 * Return Value:
 *   Number of rows loaded <NUMBER>
 *
 * Example:
 * call rtz_hud_fnc_loadTagLabels
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
    // LAMBS' own "no tactic" value — blanked so a calm group's tag carries no
    // pointless "TAC None" segment.
    ["None",                ""],
    // Waypoint tactics (raw internal names — rename to taste)
    ["taskPatrol",          "taskPatrol"],
    ["taskHunt",            "taskHunt"],
    ["taskGarrison",        "taskGarrison"],
    ["taskCamp",            "taskCamp"],
    ["taskDefend",          "taskDefend"],
    ["taskCreep",           "taskCreep"],
    ["taskRush",            "taskRush"],
    ["taskCQB",             "taskCQB"],
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

    // ═══ RTZ-OWNED TOKENS — edit the stringtable entry, not this column ═══
    // Status words (always shown, colour-coded by the render path)
    [STATUS_DOWN,   LLSTRING(StatusDown)],       // unit incapacitated (red)
    // Status flags (unit flag-icon hover, vehicle status word / card warnings)
    [FLAG_FLEEING,  LLSTRING(FlagFleeing)],      // unit fleeing (red)
    [FLAG_LOW_FUEL, LLSTRING(FlagLowFuel)],      // vehicle (amber)
    [FLAG_DAMAGED,  LLSTRING(FlagDamaged)],      // vehicle (red)
    [FLAG_PATH_OFF, LLSTRING(FlagPathOff)],
    [FLAG_MOVE_OFF, LLSTRING(FlagMoveOff)],
    [FLAG_FORCED,   LLSTRING(FlagForced)],
    [FLAG_HIDDEN,   LLSTRING(FlagHidden)],
    [FLAG_INSIDE,   LLSTRING(FlagInside)],
    [FLAG_BUSY,     LLSTRING(FlagBusy)],
    [FLAG_MOUNTED,  LLSTRING(FlagMounted)],
    [FLAG_WOUNDED,  LLSTRING(FlagWounded)]
];

{ GVAR(tagLabels) set _x } forEach _pairs;

count _pairs
