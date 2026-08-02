#include "\x\cba\addons\main\script_macros_common.hpp"
#include "\x\cba\addons\xeh\script_xeh.hpp"

// Default versioning level
#define DEFAULT_VERSIONING_LEVEL 2

#define GETVAR_SYS(var1,var2) getVariable [ARR_2(QUOTE(var1),var2)]
#define SETVAR_SYS(var1,var2) setVariable [ARR_2(QUOTE(var1),var2)]

#undef GETVAR
#define GETVAR(var1,var2,var3) (var1 GETVAR_SYS(var2,var3))
#define GETMVAR(var1,var2) (missionNamespace GETVAR_SYS(var1,var2))

#undef SETVAR
#define SETVAR(var1,var2,var3) var1 SETVAR_SYS(var2,var3)
#define SETMVAR(var1,var2) missionNamespace SETVAR_SYS(var1,var2)

#define GETUVAR(var1,var2) (uiNamespace GETVAR_SYS(var1,var2))
#define SETUVAR(var1,var2) uiNamespace SETVAR_SYS(var1,var2)

// setVariable with the public (broadcast + JIP) flag
#define SETPVAR_SYS(var1,var2) setVariable [ARR_3(QUOTE(var1),var2,true)]
#define SETPVAR(var1,var2,var3) var1 SETPVAR_SYS(var2,var3)

#define GETGVAR(var1,var2) GETMVAR(GVAR(var1),var2)
#define GETEGVAR(var1,var2,var3) GETMVAR(EGVAR(var1,var2),var3)

// CfgWeapons >> type — engine weapon slot flags
#define TYPE_WEAPON_PRIMARY 1
#define TYPE_WEAPON_HANDGUN 2
#define TYPE_WEAPON_SECONDARY 4

// Entity classes considered "a vehicle" by the servicing features (rtz_repair,
// rtz_supply). StaticWeapon is listed alongside the LandVehicle it inherits
// from, so a config hierarchy change cannot silently drop statics out of a
// nearEntities lookup.
#define VEHICLE_TYPES ["LandVehicle", "Air", "Ship", "StaticWeapon"]

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
//
// Lives here rather than in rtz_common because component script_component.hpp
// files are not visible to each other — any component that binds a key needs it,
// and only main is on everyone's include path.
#define CHECK_CURATOR_INPUT \
    if (isNull curatorCamera) exitWith {false}; \
    if (GETMVAR(RscDisplayCurator_search,false)) exitWith {false}

// Indices into ZEN's compiled context-menu action array — the array a
// modifierFunction receives as `_this select 0` and mutates in place. Layout
// per zen_context_menu_fnc_compileActions; lives here rather than in one
// component because every RTZ *ActionModifier needs it.
#define ACTION_INDEX_NAME 0
#define ACTION_INDEX_DISPLAYNAME 1
#define ACTION_INDEX_ICON 2
#define ACTION_INDEX_ICONCOLOR 3
#define ACTION_INDEX_STATEMENT 4
#define ACTION_INDEX_CONDITION 5
#define ACTION_INDEX_ARGS 6
#define ACTION_INDEX_INSERTCHILDREN 7
#define ACTION_INDEX_MODIFIERFUNCTION 8

#ifdef DISABLE_COMPILE_CACHE
    #undef PREP
    #define PREP(fncName) FUNC(fncName) = compile preprocessFileLineNumbers QPATHTOF(functions\DOUBLES(fnc,fncName).sqf)
#else
    #undef PREP
    #define PREP(fncName) [QPATHTOF(functions\DOUBLES(fnc,fncName).sqf), QFUNC(fncName)] call CBA_fnc_compileFunction
#endif

#include "script_debug.hpp"
