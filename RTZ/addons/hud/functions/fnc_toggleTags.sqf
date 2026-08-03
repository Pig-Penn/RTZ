#include "script_component.hpp"
/*
 * Author: Maxim
 * Flips both tag systems' runtime visibility from the shared "Draw Tags" ZEN
 * context menu entry (FUNC(tagsContext)).
 *
 * Each system is independently CBA-setting gated, so only one, both, or neither
 * of GVAR(unitTagsVisible) (FUNC(unitTags)) / GVAR(vehicleTagsVisible)
 * (FUNC(vehicleTags)) may exist at runtime — hence the isNil guards.
 *
 * Both systems get ONE computed target state instead of each flipping its own:
 * if the two ever disagree (e.g. a master setting flipped one off mid-mission),
 * independent toggles would swap them forever. Target state is "hide if ANY tags
 * are visible", which converges them on the first press and matches the label
 * FUNC(tagsContext) shows.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_hud_fnc_toggleTags
 *
 * Public: No
 */

private _newVis = !(GETGVAR(unitTagsVisible,false) || {GETGVAR(vehicleTagsVisible,false)});

if (!isNil QGVAR(unitTagsVisible))    then { GVAR(unitTagsVisible)    = _newVis };
if (!isNil QGVAR(vehicleTagsVisible)) then { GVAR(vehicleTagsVisible) = _newVis };

// Sync the renderers with the new flags: hiding the tags removes them from the
// frame loop outright rather than leaving a renderer that exits early.
call FUNC(applyTagVisibility);

[[LLSTRING(MsgTagsHidden), LLSTRING(MsgTagsShown)] select _newVis] call zen_common_fnc_showMessage;
