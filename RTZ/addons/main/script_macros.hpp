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

// World position of a man's LIVE head, for the renderers that pin something to the
// BODY (EFUNC(spotting,drawSpots), EFUNC(spotting,drawRcIndicator)) — an icon that is
// meant to read as "this man", and so should follow him down when he goes prone.
// The exact expression ACE3's spectator uses for the same EG-spectator chevron
// (ace_spectator_fnc_ui_draw3D).
//
// NOT for the head tags. A label that hangs OVER an entity wants a fixed height, not
// an animated one — see MODEL_TOP below, and EFUNC(hud,tagAnchor) for the split.
//
// A MACRO, not a function, and NOT cached — both deliberate, and the two are the
// same decision. `selectionPosition` returns the selection "in model space
// pertaining to the CURRENT ANIMATION in render time scope": the head moves within
// model space as the man leans, crouches, goes prone or turns his torso. It is not
// a per-class constant, which is what an earlier EFUNC(common,headOffset) memoized
// it as — freezing every man of a class at the pose the first one of that class
// happened to be in, and leaving his chevron hanging beside or above where his head
// actually was. CBA_fnc_modelHeadDir derives a unit's LIVE head facing from two of
// these reads, which it could not do if they were static.
//
// So it has to be re-read per unit per frame, and a macro is what makes that free:
// these renderers walk every drawn entity every frame, and a `call` there buys a
// fresh scope and a `params` destructure per entity per frame (see the cost notes
// in EFUNC(spotting,drawSpots)).
//
// Evaluates its argument TWICE — pass a plain variable, never a command or an
// expression with side effects.
//
// Returns [] while the model has not resolved on this machine, and [] vectorAdd
// [...] stays [] — every caller must still test `count < 3` (Gotchas §3).
#define HEAD_POS(obj) ((obj) modelToWorldVisual ((obj) selectionPosition "Head"))

// Model-space Z of an object's bounding-box top — the anchor height for anything that
// hangs OVER an entity rather than on it — EFUNC(hud,tagAnchor)'s man branch, and the
// fallback its vehicle branch already used.
//
// Static where HEAD_POS is animated, and that is the whole point of it existing. A tag
// anchored to the live head DROPS WITH THE STANCE: a man's head sits ~1.65 m up in model
// space standing and ~0.3 m up (and ~1 m forward) prone, so going prone dropped his tag
// about a metre and a third — straight onto the basegame Zeus entity icon, which does
// not move. boundingBoxReal reports the MODEL's extent, not the current animation's, so
// the tag holds one height through every stance change and a squad in mixed stances
// still reads as one row of labels rather than a staircase.
//
// Do NOT "fix" this back towards a memoized selectionPosition. That was the same bug
// from the other side (Gotchas §`selectionPosition` is animated): static-per-class is
// genuinely what a tag anchor wants, the bounding box actually IS that, and a memoized
// animated read only impersonates it — it freezes every man of a class in whichever
// pose the first one happened to be in.
//
// Being genuinely static-per-class cuts the other way too, and EFUNC(hud,tagAnchor)
// takes it: it memoizes this result by `typeOf` rather than asking the engine for a
// model's geometry once per tagged entity per frame. That is safe for exactly the
// reason the paragraph above is true, and it is NOT safe for HEAD_POS. The two other
// callers (EFUNC(spotting,drawSpots), EFUNC(spotting,drawRcIndicator)) deliberately
// do not cache: both are cold fallbacks behind unitAimPositionVisual, and both are
// inline in a per-entity loop where the `call` would cost more than the read.
//
// Evaluates its argument TWICE — pass a plain variable, never a command or an
// expression with side effects. Yields 0 rather than throwing while the model has not
// resolved on this machine; the caller's `count < 3` test on the modelToWorldVisual
// result still catches that frame (Gotchas §3).
#define MODEL_TOP(obj) (((boundingBoxReal (obj)) param [1, []]) param [2, 0])

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
