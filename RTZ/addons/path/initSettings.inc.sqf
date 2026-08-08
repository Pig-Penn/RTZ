private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

// Global: every machine has to agree on whether the mode exists at all, or a
// curator on one machine could open a planning session whose commit event
// (FUNC(commitPaths)) machines with the feature off never expected to receive.
// Default OFF — this is a new, opt-in system rather than one every mission
// should get for free.
[
    QGVAR(enable), "CHECKBOX",
    [LSTRING(Enable), LSTRING(Enable_Description)],
    _category,
    false,
    true // Global
] call CBA_fnc_addSetting;

// Global, not client-local: it is evaluated where the unit is local (that is the
// only machine disableAI has any effect on), so every machine has to agree or the
// same planning session freezes some of the selection and not the rest.
//
// Default OFF, unlike Wargame, which always freezes. Holding a whole selection
// still while a curator draws is a real tactical choice — it stops units walking
// out from under the path being drawn for them — but it is also a mid-battle
// freeze applied to units that may be under fire, so it is opt-in here.
[
    QGVAR(freezeWhilePlanning), "CHECKBOX",
    [LSTRING(FreezeWhilePlanning), LSTRING(FreezeWhilePlanning_Description)],
    _category,
    false,
    true // Global
] call CBA_fnc_addSetting;

// Client-side: this only changes what the curator drawing the paths sees
// happen on his own screen, and two curators can reasonably disagree about
// whether they want it.
[
    QGVAR(formationTrail), "CHECKBOX",
    [LSTRING(FormationTrail), LSTRING(FormationTrail_Description)],
    _category,
    true,
    false // Client
] call CBA_fnc_addSetting;

// Client-side and purely cosmetic — it tints the screen of the curator who
// opened the session and nothing else.
[
    QGVAR(planningTint), "CHECKBOX",
    [LSTRING(PlanningTint), LSTRING(PlanningTint_Description)],
    _category,
    true,
    false // Client
] call CBA_fnc_addSetting;

// Global, and read in three places that must all agree: where the unit is local
// (it selects the executor, and disableAI only means anything there), on the
// curator's client while drawing (so holding Alt visibly does nothing when
// marked stretches are off), and at commit (it selects how finely the path is
// resampled — a path reduced for the AI's navigation and then walked literally
// has already lost its corners).
//
// Scripted by default. It is Wargame's executor and the only one that walks a
// drawn line as drawn; the AI positions exist for missions that would rather
// never have a unit lose its own navigation, and for comparing the two.
[
    QGVAR(infantryExecutor), "LIST",
    [LSTRING(InfantryExecutor), LSTRING(InfantryExecutor_Description)],
    _category,
    [
        [EXEC_AI, EXEC_SPANS, EXEC_SCRIPTED],
        [LSTRING(InfantryExecutor_AI), LSTRING(InfantryExecutor_Spans), LSTRING(InfantryExecutor_Scripted)],
        2
    ],
    true // Global
] call CBA_fnc_addSetting;

// Global for the same three reasons. On by default: setDriveOnPath does nothing
// at all for Air or Ship, so the alternative is a chain of move orders that
// gives the AI a destination and no line — and a carefully traced valley run
// comes back as a straight leg over the ridge, at whatever height and speed the
// AI preferred. Off keeps real physics, collision and autorotation, at the price
// of a flight plan followed approximately.
[
    QGVAR(scriptedFlight), "CHECKBOX",
    [LSTRING(ScriptedFlight), LSTRING(ScriptedFlight_Description)],
    _category,
    true,
    true // Global
] call CBA_fnc_addSetting;

// Both of the following are read where the UNIT is local, not on the ordering
// curator's client, so every machine has to agree on them or the same path
// behaves differently depending on who happens to own the unit.

// The backstop, not the normal way a path ends. A path that is going to
// complete completes; this is what stops one that never will — a vehicle wedged
// somewhere the stuck check keeps forgiving, a unit walking a path whose far
// end became unreachable — from being followed for the rest of a multi-hour
// operation.
[
    QGVAR(timeout), "SLIDER",
    [LSTRING(Timeout), LSTRING(Timeout_Description)],
    _category,
    [1, 120, 20, 0],
    true // Global
] call CBA_fnc_addSetting;

// Ceiling on the per-point speed handed to setDriveOnPath. A vehicle given its
// config maxSpeed on a traced path drives it like a time trial and loses the
// line on the first corner; this is what makes a drawn path look driven rather
// than flung. The curator's own speed mode still halves it on top.
[
    QGVAR(maxVehicleSpeed), "SLIDER",
    [LSTRING(MaxVehicleSpeed), LSTRING(MaxVehicleSpeed_Description)],
    _category,
    [10, 150, 60, 0],
    true // Global
] call CBA_fnc_addSetting;
