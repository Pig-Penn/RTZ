#include "script_component.hpp"
/*
 * Author: Maxim
 * Narrows a curator's selection to the guns a fire mission can actually be ordered
 * from. Shared by the context action's condition and its statement so the two can
 * never disagree about what is selected.
 *
 * The three tests mirror zen_modules_fnc_gui_fireMission's own early exits (its
 * lines 31-51) rather than inventing a rule: an entry that survives here opens a
 * dialog that stays open. ZEN's gate is written against ONE anchor gun, so the
 * artilleryScanner/VLS pair is transcribed and the gunner test is applied per gun
 * instead of to the anchor's neighbours.
 *
 * Cheap on purpose. This runs on the condition path, which ZEN evaluates on every
 * context-menu build against the whole selection (Gotchas §1041) — so config reads
 * and `gunner` only, no getArtilleryAmmo and no nearObjects. The expensive questions
 * (which magazines exist, which guns are within reach of the anchor) are asked once
 * in FUNC(selectFireMission) and by ZEN's dialog respectively.
 *
 * Arguments:
 * 0: Selected objects <ARRAY>
 *
 * Return Value:
 * Usable artillery <ARRAY>
 *
 * Example:
 * private _guns = [_objects] call rtz_battery_fnc_fireMissionGuns
 *
 * Public: No
 */

params ["_objects"];

_objects select {
    alive _x
    && {!isNull gunner _x}
    && {
        getNumber (configOf _x >> "artilleryScanner") > 0
        || {[_x] call zen_common_fnc_isVLS}
    }
}
