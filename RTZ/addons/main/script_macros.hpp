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

// ── rtz_hud frame-loop contract ──────────────────────────────────────────────
// RTZ draws every curator-view display from ONE Draw3D handler
// (EFUNC(hud,frameLoop)); a component that wants to draw registers a renderer
// with EFUNC(hud,registerRenderer) instead of adding a handler of its own.
// These live here rather than in rtz_hud's script_component.hpp because
// component headers are not visible to each other — same reason
// CHECK_CURATOR_INPUT does — and any component may register.
//
//   RENDER_WORLD — draws into the 3D scene (drawIcon3D / drawLine3D). Receives
//                  the frame context array below. Skipped while the Zeus MAP is
//                  up: the map covers the 3D view, so the output is invisible
//                  and the whole pass is waste.
//   RENDER_UI    — drives controls on the curator display, which stay visible
//                  OVER the Zeus map. Receives the display, or displayNull when
//                  Zeus is closed — and is called on those frames too, so it can
//                  tear its controls down.
#define RENDER_WORLD 0
#define RENDER_UI    1

// Index into the frame context array a RENDER_WORLD renderer receives. Named so
// a renderer can `select` the one or two it needs without a `params` over all
// seven. Camera-right/up are unit vectors in WORLD space — the axes screen-space
// offsets ride, so "right of the text" holds at any camera orientation.
#define CTX_CAMPOS   0
#define CTX_CAMRIGHT 1
#define CTX_CAMUP    2
#define CTX_MOUSE    3
#define CTX_NOW      4
#define CTX_VIEWDIST 5
#define CTX_DISPLAY  6

// ── rtz_hud stream-engine contract ───────────────────────────────────────────
// Which slice of a watcher's selection a stream's gatherer is fed, resolved ONCE
// per watcher per tick by EFUNC(hud,streamServer) and shared by every stream
// that wants it. Passed to EFUNC(hud,registerStream), so — like the frame-loop
// contract above — any component declaring a stream needs these, and component
// headers cannot see each other.
//   SRC_UNITS — selected infantry, as [object, netId, dialogOpen]; side-filtered
//               and capped client-side, re-validated server-side.
//   SRC_VEHS  — selected vehicles, same shape and treatment.
//   SRC_HULLS — the whole selection resolved to distinct hulls, as
//               [watchedEntity, hull, dialogOpen]: a crewman resolves to his
//               vehicle, which moves and fights as one. What the AI-state
//               overlays want.
#define SRC_UNITS 0
#define SRC_VEHS  1
#define SRC_HULLS 2

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
