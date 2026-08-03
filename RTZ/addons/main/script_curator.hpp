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
// modifierFunction receives as `_this select 0` and mutates in place. Layout
// per zen_context_menu_fnc_compileActions; every RTZ *ActionModifier needs it.
#define ACTION_INDEX_NAME 0
#define ACTION_INDEX_DISPLAYNAME 1
#define ACTION_INDEX_ICON 2
#define ACTION_INDEX_ICONCOLOR 3
#define ACTION_INDEX_STATEMENT 4
#define ACTION_INDEX_CONDITION 5
#define ACTION_INDEX_ARGS 6
#define ACTION_INDEX_INSERTCHILDREN 7
#define ACTION_INDEX_MODIFIERFUNCTION 8
