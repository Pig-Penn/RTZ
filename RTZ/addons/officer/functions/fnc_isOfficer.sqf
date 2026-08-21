#include "script_component.hpp"
/*
 * Author: Maxim
 * Whether a unit can anchor a command aura: a man whose class name contains
 * "officer" (case-insensitive) — covers vanilla B_/O_/I_officer_F and the
 * guerilla variants. Player-controlled units are never officers, regardless of
 * class — a human player must not be able to spawn a curator editing area
 * around themselves just by playing an officer loadout. The verdict is memoised
 * per class in GVAR(classCache), so the string scan runs once per class instead
 * of once per call; the isPlayer check is deliberately kept outside the cache
 * since it can change for a given unit (disconnect, JIP, etc.) while the class
 * cannot. Widen the computation below for custom command classes.
 *
 * This is the source of truth for THIS component's question, not for the word
 * "officer" across the mod, and widening it here does NOT widen the other two:
 *
 *   - EFUNC(economy,categorize) runs the identical classname scan to charge the
 *     officer rate. Deliberately NOT shared: rtz_economy requires only rtz_main
 *     and zen_common — it is the one component that does not even take
 *     rtz_common — so hoisting this would hand the leanest component in the mod
 *     a new hard edge, to merge a PRICING policy with a CAPABILITY one that
 *     merely agrees today. Widen a custom command class here and it still needs
 *     pricing there.
 *   - EFUNC(common,classInfo) tests the DISPLAY NAME for "officer"/"hq" and
 *     feeds rtz_spotting's staff symbol. A genuinely different rule with a
 *     genuinely different input; the shared word is a trap, not a contract.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * Is Officer <BOOLEAN>
 *
 * Example:
 * [_unit] call rtz_officer_fnc_isOfficer
 *
 * Public: No
 */

params ["_unit"];

// isKindOf is false for objNull, so no separate null check is needed
if !(_unit isKindOf "CAManBase") exitWith {false};
if (isPlayer _unit) exitWith {false};

private _class = typeOf _unit;
GVAR(classCache) getOrDefaultCall [_class, {(toLowerANSI _class) find "officer" >= 0}, true]
