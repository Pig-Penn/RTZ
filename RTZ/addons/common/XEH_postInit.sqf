#include "script_component.hpp"

// Curator modules are server-local, so an errand that spawned an object on any
// other machine forwards its Zeus grant here — see FUNC(grantCurators).
if (isServer) then {
    [QGVAR(grantCurators), LINKFUNC(grantCurators)] call CBA_fnc_addEventHandler;
};

// THE curator feedback channel for the whole mod — the receiving half of
// FUNC(notifyCurator). Every component that has to tell one curator what happened
// on a machine he cannot see fires at this one event: errand timeouts
// (FUNC(approach)), rtz_assemble's build/pack outcomes, rtz_captive's capture
// payout, rtz_officer's aura verdicts. Each of those used to register its own
// identical receiver on its own event name.
//
// The payload IS the zen_common_fnc_showMessage argument list, so a caller with
// format arguments and a caller with plain text share one convention.
if (hasInterface) then {
    [QGVAR(msg), {_this call zen_common_fnc_showMessage}] call CBA_fnc_addEventHandler;
};

// Setting-gated context features. Deferred to CBA_settingsInitialized so each
// synced setting holds the server's value before it is read (see rtz_hud /
// rtz_officer for the same pattern), and so ZEN's own postInit has already
// registered the actions the menu clean-up removes.
["CBA_settingsInitialized", {
    // Strip ZEN's cluttered built-in context entries (client-side only).
    if (hasInterface && {GVAR(enableCleanContextMenu)}) then {
        [] call FUNC(removeContextActions);
    };
}] call CBA_fnc_addEventHandler;

// Turning the clean-up on mid-mission applies immediately instead of waiting
// for a restart. The reverse is one-way: zen_context_menu_fnc_removeAction
// deletes the node out of ZEN's runtime action tree and ZEN offers no re-add
// for its own built-ins, so turning the setting back OFF only takes effect on
// the next mission start. FUNC(removeContextActions) self-guards against a
// repeated ON (ZEN logs an RPT error for an already-removed path).
if (hasInterface) then {
    ["CBA_SettingChanged", {
        params ["_name", "_value"];
        if (toLower _name != toLower QGVAR(enableCleanContextMenu)) exitWith {};
        if (_value) then {
            [] call FUNC(removeContextActions);
        };
    }] call CBA_fnc_addEventHandler;
};

// QGVAR(unitReplacing) — [_unit] — is DECLARED here and raised by rtz_control's
// FUNC(rcRebuild). No receiver lives in this component; the definition sits here because
// the event is a cross-component contract and rtz_common is where those are documented.
//
// Meaning: "this unit is about to be deleted and replaced by a new object of the same
// type. Release anything you are holding on it." Raised globally, while the unit still
// exists, and BEFORE the rebuild captures its AI features and sweeps its variables —
// which is the whole value of it. A listener that clears state here has that state
// neither copied onto the replacement nor stranded on the corpse; a listener that ran
// afterwards would have to un-copy it.
//
// Listeners must test their own locality. CBA runs local handlers synchronously, so the
// rebuild's capture on the next line genuinely sees the result.
//
// The replacement object is deliberately NOT passed. Nothing has needed to migrate state
// onto it — every listener so far tears down instead — and handing it out would invite
// exactly the half-migrated errand this event exists to avoid. Add a second, post-build
// event if a real migration case ever appears; do not widen this one.
