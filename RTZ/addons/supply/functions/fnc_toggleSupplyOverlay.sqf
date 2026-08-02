#include "script_component.hpp"
/*
 * Author: Maxim
 * Context-menu statement for the supply-lines overlay: master on/off switch,
 * PER-CLIENT (each Zeus curates their own).
 *
 * The switching itself is the shared EFUNC(overlays,toggleOverlay) — this addon
 * owns a stream, not a copy of the engine. It is called with reporting OFF and
 * the toast is emitted here instead, because the engine's own toast resolves its
 * wording from a switch over the stream ids IT knows about and would otherwise
 * fall through to an empty message for this one. Same reason
 * FUNC(supplyOverlayModifier) exists rather than reusing
 * EFUNC(overlays,overlayActionModifier).
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call rtz_supply_fnc_toggleSupplyOverlay
 *
 * Public: No
 */

[STREAM_SUPPLY, false] call EFUNC(overlays,toggleOverlay);

private _on = STREAM_SUPPLY in EGVAR(overlays,active);

[[LLSTRING(MsgSupplyLinesHidden), LLSTRING(MsgSupplyLinesShown)] select _on] call EFUNC(common,showCountMessage);
