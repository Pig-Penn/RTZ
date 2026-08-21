#include "script_component.hpp"
/*
 * Author: Maxim
 * Flips every live tag system's runtime visibility from the shared "Draw Tags"
 * ZEN context menu entry (FUNC(tagsContext)).
 *
 * Every system gets ONE computed target state instead of each flipping its own:
 * if two ever disagree (a master setting flipped one off mid-mission),
 * independent toggles would swap them forever. The target state is "hide if ANY
 * tags are visible", which converges them on the first press and matches the
 * label FUNC(tagsContext) shows — both read that condition through the one
 * ANY_TAGS_VISIBLE macro so the button cannot describe something it does not do.
 *
 * Systems that were never started (master setting off) are not in
 * GVAR(tagSystems), so there is nothing to guard against here.
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

private _anyVisible = ANY_TAGS_VISIBLE;
private _newVis = !_anyVisible;

// A system whose MASTER setting is off stays off. This action is a runtime
// show/hide layered ON TOP of that setting, never an override of it — and setting
// every record true unconditionally was exactly that override: a system switched
// off in CBA settings came back on the second press (the first hides everything,
// so the second sees ANY_TAGS_VISIBLE false and shows everything). That
// re-registered its renderer AND re-declared its stream demand, so the server
// resumed gathering and pushing a packet per selected entity per tick for a
// display the curator had disabled, until the setting was toggled off and on
// again. Only reachable for a system that was started and then disabled, since a
// system disabled at mission start is never in the registry at all.
//
// Plain getVariable, NOT the GETMVAR macro: TAG_MASTER holds the setting's NAME
// as a string, and GETMVAR quotes its argument — so it would look up this local's
// own name and silently read the default forever (Gotchas §6). Defaults true so a
// master that has not synced yet does not read as disabled.
{
    _y set [TAG_VISIBLE, _newVis && {missionNamespace getVariable [_y select TAG_MASTER, true]}];
} forEach GVAR(tagSystems);

// Sync the renderers and the stream demands with the new flags: hiding the tags
// removes them from the frame loop outright rather than leaving a renderer that
// exits early, and withdraws the slices the server was gathering for them.
call FUNC(applyTagVisibility);

// Reports what actually happened, not what was asked for. Re-reading the same
// macro the label uses matters now that a press can be declined: with every live
// system's master setting off, _newVis is true and nothing becomes visible, and
// announcing "Tags Shown" there would describe a state the curator can see is not
// the case.
[[LLSTRING(MsgTagsHidden), LLSTRING(MsgTagsShown)] select ANY_TAGS_VISIBLE] call zen_common_fnc_showMessage;
