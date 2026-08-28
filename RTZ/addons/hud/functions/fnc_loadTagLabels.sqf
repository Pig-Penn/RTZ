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
    // ═══ TACTICS — the amber segment (group-level, leader tag / vehicle) ═══
    // Reactive combat tactics (LAMBS danger component)
    ["Contact!",            "Contact"],        // leader's immediate reaction to first sighting (fnc_contact)
    ["Attacking",           "Attack"],         // whole group ordered onto ONE enemy unit (fnc_tacticsAttack)
    ["Assaulting",          "Assault"],        // sustained multi-cycle push onto a building/position
    ["Flanking",            "Flank"],          // probing flank: base-of-fire + manoeuvre element split
    ["CQB clearing",        "Clear"],          // leader declared the nearest building an assault objective
    ["Suppressing",         "Suppress"],       // group laying sustained suppressive fire on a location
    ["Hiding",              "Hide"],           // group disperses into cover (LAMBS' anti-armour mode too)
    ["Holding!",            "Hold"],           // no orders — waits it out, takes cover if fired on
    ["Garrison/Rally",      "Garrison"],       // reactive: group occupies buildings near the enemy
    ["Reinforcing",         "Reinforce"],      // group answering another group's call for help
    // LAMBS' own "no tactic" value — blanked so a calm group's tag carries no
    // pointless "None" segment.
    ["None",                ""],               // inert: LAMBS clears the var to nil and RTZ reads default ""
    // Waypoint tactics (raw internal names — rename to taste)
    ["taskPatrol",          "Patrol"],         // dynamic patrol of an area (lambs_wp module/waypoint)
    ["taskHunt",            "Hunt"],           // tracker — follows the enemy's trail across the map
    ["taskGarrison",        "Garrison"],       // pre-planned occupation of buildings in the area
    ["taskCamp",            "Camp"],           // relaxed camp-like idling at the position
    ["taskDefend",          "Defend"],         // holds an area from buildings and fortifications
    ["taskCreep",           "Creep"],          // slow stealthy close-in approach to the target
    ["taskRush",            "Rush"],           // aggressive attacker — pushes hard onto the target
    ["taskAssault",         "Assault"],        // heedless rush onto a position (AI disabled, FULL speed)
    ["taskRetreat",         "Retreat"],        // same script in retreat mode — weapons off, running away
    ["taskCQB",             "CQB"],            // room-by-room building clearing loop
    ["taskArtillery",       "Shell"],          // gun group shelling a cone-shaped beaten zone

    // ═══ TASKS — the coloured status word (per unit / vehicle) ═══
    // Contact & assessment
    ["Tactics Assess",              "Assess"],                   // leader sizing up the fight before picking a tactic
    ["Heard scream!",               "Contact"],                  // heard a scream (DANGER_SCREAM) — watching the source
    ["Incapacitated",               "Incapacitated"],            // unit unconscious or dead (fnc_brainForced)
    // Assault / advance
    ["Assault",                     "Assault"],                  // pushing to building positions or open terrain
    ["Assault Building",            "Assault Building"],         // CQB pattern — clearing building by building
    ["Assault (sympathetic)",       "Assault"],                  // joins an assault on a spot in the group's memory
    ["Tactics Assault",             "Assault"],                  // leader's own marker while "Assaulting" runs
    ["Reinforce",                   "Reinforce"],                // leader's own marker while "Reinforcing" runs
    ["Tactics Attack",              "Attack"],                   // leader's own marker while "Attacking" runs
    ["Rushing Assault",             "Assault"],          // member of a taskAssault waypoint's headlong rush
    ["Rushing Retreat",             "Retreat"],          // same, retreat mode — disarmed and running
    // Suppress
    ["Suppress!",                   "Suppress"],                 // single unit firing on a target location
    ["Leader Suppress",             "Suppress"],          // leader's own marker while "Suppressing" runs
    ["Group Suppress",              "Suppress"],           // member firing in the group suppression cycle
    ["Group Suppress (Move)",       "Suppress"],    // same cycle, repositioning / vehicle commander
    // Flank
    ["Tactics Flank",               "Flank"],                    // leader's own marker while "Flanking" runs
    ["Group Flank",                 "Flank"],                    // member assigned to the manoeuvre element
    ["Group Flank - Suppress",      "Suppress"],                 // member assigned to the base-of-fire element
    ["Group Flank - Suppressing!",  "Suppress"],                 // vehicle commander in the base-of-fire element
    ["Group Flank - Manoeuvring!",  "Manoeuver"],                // vehicle commander in the manoeuvre element
    // Hide / flee / cover
    ["Hide!",                       "Hide"],                     // moving to a nearby cover position
    ["Hide (inside)",               "Hide"],            // took cover inside a building instead
    ["Hide (re-hide)",              "Hide"],           // group hide's delayed second hide once ready
    ["Hide (group)",                "Hide"],           // group hide's default call (fnc_tacticsHide, no _action)
    ["Hide (holding)",              "Hide"],           // group hide called from fnc_tacticsHold
    ["Leader Hide",                 "Hide"],              // leader's own marker while "Hiding" runs
    ["Fleeing",                     "Flee"],                     // routed on foot (engine `fleeing`, fnc_doFleeing)
    ["Fleeing (vehicle)",           "Flee"],           // routed while mounted in a vehicle
    ["Fleeing (enemy near)",        "Flee"],        // routed with the enemy close or in line of sight
    ["Panic",                       "Panic"],                    // panic reaction — no coherent action yet
    ["Dodge!",                      "Dodge"],                    // instant flinch/reaction to being shot at
    ["Repositioning",               "Reposition"],               // shifting to a better building position vs the target
    ["Stay inside",                 "Stay"],              // indoors, no building to push to — holds
    ["Stay inside (reposition)",    "Stay"], // reposition found nothing better — stays put
    // Garrison / CQB
    ["Tactics Garrison",            "Garrison"],         // leader's own marker while "Garrison/Rally" runs
    ["Group Garrison",              "Garrison"],                 // member moving to its assigned building position
    ["Tactics CQB",                 "CQB"],              // leader's own marker while "CQB clearing" runs
    ["taskCQB - Rush enemy",        "Rush"],     // taskCQB: rushing a building position near the enemy
    ["taskCQB - Clearing rooms",    "Clear"], // taskCQB: working down the uncleared-position list
    // Support actions
    ["Shoot UGL",                   "Flush"],                    // firing a UGL round / flare at the target
    ["Throwing smoke grenade",      "Smoke"],                    // throwing smoke to screen the location
    ["Checking bodies",             "Loot"],                     // walking over to inspect a known corpse
    ["Checking bodies (unknown)",   "Loot"],           // found an own-group corpse — searching nearby buildings
    ["Leader Artillery",            "Call"],                     // leader calling in a friendly artillery mission
    ["Deploy Static Weapon",        "Assemble"],                 // group assembling a static weapon
    ["Pack Static Weapon",          "Pack"],                     // assistant packing a static weapon back up
    ["Deploy Commando Mortar",      "Assemble"],                 // deploying the Reaction Forces CDLC commando mortar
    // Civilians only (lambs_dangerCivilian.fsm — shares "Hide!" with the above)
    ["Escape!",                     "Escape"],                   // civilian running from danger (COMBAT, FULL speed)
    ["Check body",                  "Check Body"],               // civilian walked over to inspect a corpse
    // Vehicle tasks (shown on vehicle tags)
    ["Vehicle Suppress",            "Suppress"],                 // vehicle laying suppressive fire on a location
    ["Vehicle Rotate",              "Rotate"],                   // turning the hull to face the enemy
    ["Vehicle Assault",             "Scratch"],                  // working over building positions with the main gun
    ["Vehicle Assault Move",        "Assault"],                  // driving aggressively to a superior firing position
    ["Jink Vehicle",                "Jink"],                     // evasive shift 50–150 m left / right / rearward
    ["Mortar Fire",                 "Shell"],              // mortar vehicle firing a danger-response mission
    ["Dismounting troops",          "Dismount"],                 // threatened transport ejecting its cargo

    // ═══ RTZ-OWNED TOKENS — edit the stringtable entry, not this column ═══
    // Status words (always shown, colour-coded by the render path)
    [STATUS_DOWN,   LLSTRING(StatusDown)],  // unit incapacitated (red) — packet's _downed field
    // Status flags (unit flag-icon hover, vehicle status word / card warnings)
    [FLAG_FLEEING,  LLSTRING(FlagFleeing)], // unit fleeing (red) — engine `fleeing _unit`
    [FLAG_LOW_FUEL, LLSTRING(FlagLowFuel)], // vehicle (amber) — `fuel _veh < 0.15`
    [FLAG_DAMAGED,  LLSTRING(FlagDamaged)], // vehicle (red) — `damage _veh > 0.60`
    [FLAG_PATH_OFF, LLSTRING(FlagPathOff)], // pathfinding disabled — `checkAIFeature "PATH"`
    [FLAG_MOVE_OFF, LLSTRING(FlagMoveOff)], // movement disabled — `checkAIFeature "MOVE"`
    [FLAG_FORCED,   LLSTRING(FlagForced)],  // LAMBS is force-moving it (`lambs_danger_forceMove`)
    [FLAG_HIDDEN,   LLSTRING(FlagHidden)],  // hidden from the enemy — engine `isHidden`
    [FLAG_INSIDE,   LLSTRING(FlagInside)],  // fully indoors — `insideBuilding _unit isEqualTo 1`
    [FLAG_BUSY,     LLSTRING(FlagBusy)],    // still executing an order — `!(unitReady _unit)`
    [FLAG_MOUNTED,  LLSTRING(FlagMounted)]  // in a vehicle — `!isNull objectParent _unit`
];

{ GVAR(tagLabels) set _x } forEach _pairs;

count _pairs
