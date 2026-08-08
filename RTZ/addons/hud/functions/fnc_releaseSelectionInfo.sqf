#include "script_component.hpp"
/*
 * Author: Maxim
 * Drops the selection info dialog's lock and withdraws its stream demand.
 *
 * Both halves, always together — that pairing is the reason this is a function.
 * It has five callers (OK, Cancel, a failed control grab, the display going away,
 * and Zeus closing underneath the dialog), and a copy that dropped the lock while
 * leaving the demand standing would keep the server running targetsQuery and
 * checkVisibility over every selected unit, every tick, for the rest of the
 * mission — with no dialog on screen to show for it.
 *
 * Withdrawing is an empty slice list (EFUNC(core,setDemand)): the registry entry
 * is dropped rather than kept as a row of falses.
 *
 * Safe to call more than once — both operations are idempotent — which matters
 * because the tick and the dialog's own close callbacks can both fire for the
 * same close.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_hud_fnc_releaseSelectionInfo
 *
 * Public: No
 */

GVAR(dialogOpen) = false;

[QGVAR(dialog), []] call EFUNC(core,setDemand);
