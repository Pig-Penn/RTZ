#include "\x\cba\addons\main\script_macros_common.hpp"
#include "\x\cba\addons\xeh\script_xeh.hpp"

#define GETVAR_SYS(var1,var2) getVariable [ARR_2(QUOTE(var1),var2)]
#define SETVAR_SYS(var1,var2) setVariable [ARR_2(QUOTE(var1),var2)]

#undef GETVAR
#define GETVAR(var1,var2,var3) (var1 GETVAR_SYS(var2,var3))
#define GETMVAR(var1,var2) (missionNamespace GETVAR_SYS(var1,var2))

#undef SETVAR
#define SETVAR(var1,var2,var3) var1 SETVAR_SYS(var2,var3)

#define GETUVAR(var1,var2) (uiNamespace GETVAR_SYS(var1,var2))
#define SETUVAR(var1,var2) uiNamespace SETVAR_SYS(var1,var2)

// setVariable with the public (broadcast + JIP) flag
#define SETPVAR_SYS(var1,var2) setVariable [ARR_3(QUOTE(var1),var2,true)]
#define SETPVAR(var1,var2,var3) var1 SETPVAR_SYS(var2,var3)

#define GETGVAR(var1,var2) GETMVAR(GVAR(var1),var2)
#define GETEGVAR(var1,var2,var3) GETMVAR(EGVAR(var1,var2),var3)

// Entity classes considered "a vehicle" by the servicing features (rtz_repair,
// rtz_supply). StaticWeapon is listed alongside the LandVehicle it inherits
// from, so a config hierarchy change cannot silently drop statics out of a
// nearEntities lookup.
#define VEHICLE_TYPES ["LandVehicle", "Air", "Ship", "StaticWeapon"]

// NOTE: rtz_core's frame-loop and stream contracts (RENDER_*, CTX_*, SRC_*,
// SEL_MAX_*, VEH_SIDE_OK, SIDE_NUM) are NOT here. They are ONE component's own
// contract, and they live in addons/core/script_macros_core.hpp, which the
// components that draw or stream include by absolute path — the way ACE3's
// medical components include medical_engine's script_macros_medical.hpp. Only
// what is genuinely mod-wide belongs in this file; a constant that concerns a
// single subsystem belongs to that subsystem.

#ifdef DISABLE_COMPILE_CACHE
    #undef PREP
    #define PREP(fncName) FUNC(fncName) = compile preprocessFileLineNumbers QPATHTOF(functions\DOUBLES(fnc,fncName).sqf)
#else
    #undef PREP
    #define PREP(fncName) [QPATHTOF(functions\DOUBLES(fnc,fncName).sqf), QFUNC(fncName)] call CBA_fnc_compileFunction
#endif

#include "script_curator.hpp"
#include "script_debug.hpp"
