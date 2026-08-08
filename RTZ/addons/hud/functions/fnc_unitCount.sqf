#include "script_component.hpp"
/*
 * Author: Maxim
 * Localized "N unit" / "N units" for the selection dialog's header and group
 * descriptors.
 *
 * Two separate stringtable entries rather than a spliced "s": English pluralizes
 * by suffix and most other languages do not, so the singular and plural forms
 * have to be translatable independently.
 *
 * Arguments:
 * 0: Count <NUMBER>
 *
 * Return Value:
 * Localized count phrase <STRING>
 *
 * Example:
 * [3] call rtz_hud_fnc_unitCount
 *
 * Public: No
 */

params ["_n"];

format [[LLSTRING(HeaderUnits), LLSTRING(HeaderUnit)] select (_n == 1), _n]
