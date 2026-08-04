#include "script_component.hpp"
/*
 * Author: Maxim
 * CLIENT. Brings the supply-lines overlay in line with GVAR(enableSupplyDisplay).
 *
 * The overlay has NO context action: supply lines are always drawn while the
 * setting allows them, so this is the only thing that ever switches the stream on
 * or off. It used to be a per-curator "Show Supply Lines" toggle in the
 * RTZ_Overlays submenu, which meant a curator had to remember to switch a display
 * on before it could tell them anything.
 *
 * Idempotent, because EFUNC(core,toggleOverlay) is a TOGGLE: called blind by two
 * triggers that agree the overlay should be on, the second one hides it again.
 * CBA can report a setting change during the initial sync — i.e. before
 * CBA_settingsInitialized fires — so both callers can land in the same frame.
 * Comparing wanted against actual is what makes "sync" mean sync, and it also
 * makes this safe alongside the engine's own CBA_SettingChanged watchdog, which
 * independently shuts a running overlay down when its master setting goes off.
 *
 * Reporting is switched off: the toast wording exists for a curator who clicked
 * something, and nobody clicked.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_supply_fnc_syncDisplay
 *
 * Public: No
 */

if (!hasInterface) exitWith {};

// Read defensively rather than as a bare GVAR: CBA_SettingChanged is a shared
// event this may be reached from before the setting itself exists, and a nil read
// would abort the handler rather than resolve to "off"
// (docs/Knowledge Base/Gotchas.md §2).
private _wanted = missionNamespace getVariable [QGVAR(enableSupplyDisplay), false];
if (_wanted isEqualTo (STREAM_SUPPLY in EGVAR(core,activeStreams))) exitWith {};

[STREAM_SUPPLY, false] call EFUNC(core,toggleOverlay);
