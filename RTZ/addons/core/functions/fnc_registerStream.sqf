#include "script_component.hpp"
/*
 * Author: Maxim
 * Declare one data feed to the shared stream engine — BOTH halves. A new curator
 * display costs a gather/draw pair and one call to this; never another registry,
 * PFH, subscribe event, diff cache, or a hand-written entry in someone else's
 * preInit.
 *
 * This used to register the SERVER half only. The client half — which store a
 * snapshot lands in, which renderer the overlay toggle switches on, which master
 * setting the watchdog watches, what the toast and context-menu labels say — was
 * hardcoded in rtz_hud's own XEH_preInit and in switch statements inside
 * FUNC(toggleOverlay) / FUNC(overlayActionModifier). So the "generic" engine knew
 * the ids of four specific displays, and a stream declared from OUTSIDE rtz_hud
 * could not complete itself: rtz_supply had to reach into EGVAR(hud,streamRenderers)
 * and EGVAR(hud,streamSettings) by hand and carry two whole functions
 * (toggleSupplyOverlay, supplyOverlayModifier) that existed purely because the
 * engine's switches fell through to "" for an id they had never heard of. Both are
 * gone; the shared halves now serve every stream because the labels arrive with
 * the declaration.
 *
 * Called on EVERY machine — each half self-gates. The server keeps the gather
 * registry, an interface keeps the presentation registries, a dedicated server
 * builds none of the latter.
 *
 * The GATHERER is handed one entry from the slice its stream declared, plus the
 * watcher's "dialog open" flag for feeds whose expensive fields only matter to the
 * dialog, and returns one snapshot entry — or [] to omit this entity entirely:
 *
 *   SRC_UNITS / SRC_VEHS — [[object, netId], detailed]
 *   SRC_HULLS            — [[watchedEntity, hull], detailed]
 *
 * The RECEIVER is handed [streamId, entries, refTime] on the client as each
 * snapshot lands. It defaults to FUNC(receiveOverlay), the raw store the AI-state
 * overlays read, so a plain overlay stream omits it; the two selection feeds pass
 * their own because they unpack into netId-keyed maps their consumers index by id.
 *
 * The OVERLAY bundle is what makes a stream toggleable from the context menu. Omit
 * it for an always-on feed (the unit and vehicle packets are implied by a non-empty
 * selection and have no switch of their own).
 *
 * Cadence is a SETTING NAME plus a fallback, not a fixed number, so an admin can
 * retune a feed mid-mission and the loop picks it up on its next tick. It is
 * floored to STREAM_TICK — no feed can outrun the loop that drives it.
 *
 * LINKFUNC rather than a stored Code value for every function reference, so a PREP
 * recompile is picked up without re-registering.
 *
 * Arguments:
 * 0: Stream id <STRING>
 * 1: Gather function <CODE>
 * 2: Selection slice to feed it — SRC_UNITS, SRC_VEHS or SRC_HULLS <NUMBER>
 * 3: Variable name of the CBA interval setting <STRING>
 * 4: Interval fallback (s), used before settings sync and if unset <NUMBER>
 * 5: Snapshot receiver <CODE> (default: FUNC(receiveOverlay))
 * 6: Overlay bundle, [] for a non-toggleable feed <ARRAY> (default: [])
 *    0: Renderer, registered with the frame loop while switched on <CODE>
 *    1: Variable name of the master enable setting <STRING>
 *    2: Toast text, [whenHidden, whenShown] <ARRAY>
 *    3: Context-menu labels, [whenOff, whenOn] <ARRAY>
 *    4: Icon tint while off — while on, every overlay greys out <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * ["veh", LINKFUNC(gatherVehicleInfo), SRC_VEHS, QGVAR(gatherInterval), 0.3, LINKFUNC(receiveVehicleData)] call rtz_core_fnc_registerStream
 *
 * Public: No
 */

params [
    "_stream", "_gather", "_source", "_intervalVar", "_defaultInterval",
    ["_onReceive", LINKFUNC(receiveOverlay)], ["_overlay", []]
];

if (isServer) then {
    GVAR(streams) set [_stream, [_gather, _source, _intervalVar, _defaultInterval]];
};

// Presentation registries only exist where there is a screen (see XEH_preInit) —
// a dedicated server gathers and sends, and draws nothing.
if (!hasInterface) exitWith {};

// Always set, never conditionally: the parameter's own default IS the overlay
// behaviour, so there is no "was one supplied?" sentinel to get wrong. Comparing
// a Code value against {} would be the obvious way to ask, and it is exactly the
// thing that breaks under DISABLE_COMPILE_CACHE, where LINKFUNC expands to a
// fresh wrapper literal on every expansion rather than a stable reference.
GVAR(streamReceivers) set [_stream, _onReceive];

// The client needs the slice too, not just the server: when a slice empties,
// FUNC(selectionPoll) delivers an empty snapshot to the receivers that read it so
// each display clears its own store.
GVAR(streamSources) set [_stream, _source];

if (_overlay isEqualTo []) exitWith {};

_overlay params ["_renderer", "_settingVar", ["_toasts", ["", ""]], ["_labels", ["", ""]], ["_accent", COLOR_OVERLAY_ON]];

GVAR(streamRenderers) set [_stream, _renderer];

// Lowercased: the CBA_SettingChanged watchdog in FUNC(streamClient) cannot rely
// on the case a setting was registered with.
GVAR(streamSettings) set [_stream, toLower _settingVar];

// Everything the two shared context-menu halves need to speak about this stream
// without knowing what it is: FUNC(toggleOverlay) reads the toasts,
// FUNC(overlayActionModifier) the labels and the accent.
GVAR(streamLook) set [_stream, [_toasts, _labels, _accent]];
