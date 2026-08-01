#include "script_component.hpp"
/*
 * Author: Maxim
 * Reads the unit's current errand token — the supersede counter FUNC(approach)
 * stamps on a lead when it takes ownership of it.
 *
 * A hook that outlives its own arrival (rtz_repair's engineer keeps working on a
 * vehicle long after he stopped walking) cannot rely on approach's own guard,
 * because approach has already resolved by then. Snapshotting this token on
 * arrival and re-reading it later answers "does this errand still own the unit,
 * or did a newer order take him?" — a curator who redirects a working engineer to
 * lay a mine must not have the abandoned repair release him back into formation
 * and cancel the new order.
 *
 * Lives here rather than in the consuming component so the token stays private to
 * the errand engine that owns it.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * Errand token, 0 if the unit was never sent on one <NUMBER>
 *
 * Example:
 * private _token = [_unit] call rtz_common_fnc_errandToken;
 *
 * Public: No
 */

params ["_unit"];

_unit getVariable [QGVAR(approachOrder), 0]
