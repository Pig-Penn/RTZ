// Hides LAMBS' nine scripted waypoint types from ZEN's waypoint Type toolbox.
//
// lambs_wp registers these tasks TWICE. Its own CfgWaypoints.hpp files them
// under a category whose displayName is literally
// "Advanced AI [LAMBS] (Deprecated, use modules)]", every entry keyed
// STR_Lambs_WP_Waypoint_Deprecated_*; its ZEN_CfgWaypointTypes.hpp injects the
// same nine into ZEN's list under non-deprecated keys. Only the second set ever
// reaches a curator here — zen_attributes_fnc_compileWaypoints reads
// configFile >> "ZEN_WaypointTypes" and never looks at CfgWaypoints — but both
// point at the same lambs_wp\scripts\fnc_wp*.sqf, which is the deprecated path.
//
// Those scripts pass the group, the position and the waypoint's completion
// radius, then hardcode the rest to the TASK_* defaults: fnc_wpGarrison passes
// 3 of taskGarrison's 8 arguments, dropping the area shape, teleport,
// sort-by-height, exit condition and patrol flags that the Garrison module
// asks for. TASK PATROL is worse than merely thin — taskPatrol opens with
// CBA_fnc_clearWaypoints, so it wipes the group's entire route including the
// waypoint that triggered it. TASK RETREAT is not its own script, just
// taskAssault with isRetreat set. REGISTER ARTILLERY duplicates a module
// outright. All nine have a module counterpart taking the full argument set,
// so hiding them costs a curator nothing they cannot do better elsewhere.
//
// Mind also that the waypoint path leans on the script firing where the group
// is local — every lambs_wp_fnc_task* opens with `if (!local _group) exitWith`,
// a silent no-op otherwise — while the modules and LAMBS' ZEN actions
// CBA_fnc_targetEvent to `leader _group` explicitly. On a server whose units
// are local to whichever curator spawned them, that difference is not academic.
//
// Removal is by condition, not deletion. ZEN compiles each class's `condition`
// once at preStart and evaluates it per dialog open (zen_attributes
// fnc_gui_waypoint filters the compiled list through it), so the setting is
// read live: a curator who turns it off gets the entries back on their next
// waypoint dialog rather than at the next mission start. LAMBS' modules, its
// ZEN context actions and its own CfgWaypoints category are all untouched.

// The same gate on all nine. Spelled once so a rename of the setting is a
// one-line fix rather than nine.
#define HIDDEN_LAMBS_WAYPOINT condition = QUOTE(!GVAR(lambsWaypoints))

class ZEN_WaypointTypes {
    class lambs_danger_Attack           { HIDDEN_LAMBS_WAYPOINT; };  // TASK ASSAULT
    class lambs_danger_Retreat          { HIDDEN_LAMBS_WAYPOINT; };  // TASK RETREAT
    class lambs_danger_Garrison         { HIDDEN_LAMBS_WAYPOINT; };  // TASK GARRISON
    class lambs_danger_Patrol           { HIDDEN_LAMBS_WAYPOINT; };  // TASK PATROL
    class lambs_danger_Rush             { HIDDEN_LAMBS_WAYPOINT; };  // TASK RUSH
    class lambs_danger_Hunt             { HIDDEN_LAMBS_WAYPOINT; };  // TASK HUNT
    class lambs_danger_Creep            { HIDDEN_LAMBS_WAYPOINT; };  // TASK CREEP
    class lambs_danger_CQB              { HIDDEN_LAMBS_WAYPOINT; };  // TASK CQB
    class lambs_danger_RegisterArtillery{ HIDDEN_LAMBS_WAYPOINT; };  // REGISTER ARTILLERY
};
