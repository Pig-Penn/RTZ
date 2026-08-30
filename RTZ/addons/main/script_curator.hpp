// Zeus and ZEN interface constants — the engine display RTZ lives inside, and
// the shape of the ZEN structures it reaches into. Included from script_macros.hpp,
// so every component gets these without asking.
//
// These belong in main rather than in any one component because they describe
// the HOST (Zeus, ZEN), not any RTZ subsystem: seven components index ZEN's
// action array, five read the curator display, five read the selection. Contrast
// core's script_macros_core.hpp, which is one component's own contract and is
// included only by the components that opt into it.
//
// ZEN structures its main header the same way — zen_main/script_curator.hpp
// carries the SELECTED_* family and is pulled in from zen_main/script_macros.hpp.

// Zeus display
#define IDD_RSCDISPLAYCURATOR 312
#define IDC_RSCDISPLAYCURATOR_MAINMAP 50

// Zeus selected entities (ZEN's script_curator.hpp convention)
#define SELECTED_OBJECTS (curatorSelected select 0)
#define SELECTED_GROUPS (curatorSelected select 1)

// Shared preamble for every Zeus keybind handler: act only while this machine's
// Zeus interface is open, and never hijack a keystroke the curator is typing
// into ZEN's search box. Both paths return false so the key passes through to
// whatever would normally receive it.
#define CHECK_CURATOR_INPUT \
    if (isNull curatorCamera) exitWith {false}; \
    if (GETMVAR(RscDisplayCurator_search,false)) exitWith {false}

// Indices into ZEN's compiled context-menu action array — the array a
// modifierFunction receives as `_this select 0` and mutates in place. Layout per
// zen_context_menu_fnc_compileActions, recorded here in full:
//   0 name | 1 displayName | 2 icon | 3 iconColor | 4 statement
//   5 condition | 6 args | 7 insertChildren | 8 modifierFunction
// Only the slots RTZ actually writes are defined — the rest were never
// referenced anywhere in the mod, and the comment claiming "every RTZ
// *ActionModifier needs it" was true of three of the nine.
#define ACTION_INDEX_DISPLAYNAME 1
#define ACTION_INDEX_ICON 2
#define ACTION_INDEX_ICONCOLOR 3
#define ACTION_INDEX_CONDITION 5

// One level up: the NODE that wraps an action in the compiled tree, which is
// what the tree itself is an array of. Layout per the same function:
//   0 action (the nine slots above) | 1 children (more nodes) | 2 priority
// Needed by anything that restructures the tree rather than restyling one
// entry — see rtz_common's FUNC(regroupVehicleActions). ZEN's addAction cannot
// stand in for this: it builds its node with an EMPTY child list, so a node
// that has children of its own has to be placed by hand.
#define NODE_INDEX_ACTION 0
#define NODE_INDEX_CHILDREN 1
#define NODE_INDEX_PRIORITY 2

// Every RTZ *ActionModifier restyles an action the same way — a label, an icon
// and a tint, written into those three slots. Spelled out as three `set` calls it
// appeared fifteen times across six functions in five components.
#define SET_ACTION(action,label,icon,color) \
    action set [ACTION_INDEX_DISPLAYNAME, label]; \
    action set [ACTION_INDEX_ICON, icon]; \
    action set [ACTION_INDEX_ICONCOLOR, color]
