#include "script_component.hpp"
/*
 * Author: Maxim
 * Condition of the context menu's Loadout > Edit action, replacing ZEN's own
 * through the CfgContext patch in CfgContext.hpp. Out of zone the entry simply
 * does not appear, matching how the Arsenal and Damage buttons behave in the
 * attribute window.
 *
 * Only the Edit child is gated this way. FUNC(getActiveActions) skips a parent's
 * children entirely when the parent's condition is false, so gating the Loadout
 * parent would take Copy, Paste, Reset and Switch Weapon down with it — a wider
 * restriction than this component is for. The parent keeps ZEN's condition and
 * has its statement gated instead; see FUNC(openArsenal).
 *
 * ZEN's predicate is called rather than reimplemented, so the alive and
 * CAManBase tests stay in step with ZEN.
 *
 * Arguments:
 * 0: Entity <ANY> (passed as _this by the context menu)
 *
 * Return Value:
 * Loadout may be edited <BOOLEAN>
 *
 * Example:
 * _hoveredEntity call rtz_restrict_fnc_canEditLoadout
 *
 * Public: No
 */

// The context menu calls conditions as `_hoveredEntity call _condition`, and
// the hovered entity is objNull rather than an array when nothing is hovered
params ["_entity"];

(_entity call zen_context_actions_fnc_canEditLoadout)
&& {!GVAR(arsenal) || {[_entity] call FUNC(canEditEntity)}}
