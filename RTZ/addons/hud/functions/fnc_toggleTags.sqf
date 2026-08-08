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

{ _y set [TAG_VISIBLE, _newVis] } forEach GVAR(tagSystems);

// Sync the renderers and the stream demands with the new flags: hiding the tags
// removes them from the frame loop outright rather than leaving a renderer that
// exits early, and withdraws the slices the server was gathering for them.
call FUNC(applyTagVisibility);

[[LLSTRING(MsgTagsHidden), LLSTRING(MsgTagsShown)] select _newVis] call zen_common_fnc_showMessage;
