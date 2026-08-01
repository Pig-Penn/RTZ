// FAST RECOMPILING
// #define DISABLE_COMPILE_CACHE
// To Use: [] call RTZ_PREP_RECOMPILE;

// ELINKFUNC is LINKFUNC across components — the cross-addon form CBA never
// shipped. Same contract: the function reference normally, a late-binding
// wrapper while recompiling, so a hook handed to another addon's function
// (EFUNC(common,approach), CBA event handlers, ...) picks up a recompile.
#ifdef DISABLE_COMPILE_CACHE
    #define LINKFUNC(x) {_this call FUNC(x)}
    #define ELINKFUNC(dir,x) {_this call EFUNC(dir,x)}
    #define PREP_RECOMPILE_START    if (isNil "RTZ_PREP_RECOMPILE") then {RTZ_RECOMPILES = []; RTZ_PREP_RECOMPILE = {{call _x} forEach RTZ_RECOMPILES}}; private _recomp = {
    #define PREP_RECOMPILE_END      }; call _recomp; RTZ_RECOMPILES pushBack _recomp;
#else
    #define LINKFUNC(x) FUNC(x)
    #define ELINKFUNC(dir,x) EFUNC(dir,x)
    #define PREP_RECOMPILE_START /* */
    #define PREP_RECOMPILE_END /* */
#endif
