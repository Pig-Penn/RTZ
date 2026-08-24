#include "script_component.hpp"
/*
 * Author: Maxim
 * Context menu statement: opens a position picker, then orders every disassembled
 * static weapon the selected squads carry to be walked to the picked spot by its
 * gunner and assistant and raised there. Escape cancels with no order sent.
 *
 * The picker is ZEN's own (zen_common_fnc_selectPosition); RTZ carries no placement
 * preview of its own. It draws the first set's Zeus tree icon at the cursor, and
 * aborts by itself if one of the gunners handed to it is deleted mid-gesture. A
 * mixed selection places every set on the same spot, it just shows one icon.
 *
 * Facing is NOT chosen here - there is no rotate gesture, and adding one back would
 * mean re-growing a bespoke picker. The order carries the -1 sentinel instead, which
 * FUNC(finishBuild) resolves by aiming the weapon at its gunner's nearest known
 * enemy, and FUNC(buildWeapon)'s direct-build fallback resolves to getDir _gunner.
 *
 * The walk, createVehicle and assemble action must run where the gunner is local -
 * the server for Zeus AI, but a headless client or a player's machine for offloaded
 * or player-led groups - so each set is dispatched to his owner over QGVAR(assemble)
 * (the receiver is registered on every machine in XEH_postInit). Every set past the
 * first fans out around the cursor so two weapons don't build on the same point -
 * including two carried by one squad. The ordering curator's player rides along so
 * the errand can toast failures back.
 *
 * Arguments:
 * 0: Selected Objects <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_objects] call rtz_assemble_fnc_orderAssemble
 *
 * Public: No
 */

params ["_objects"];

private _sets = [_objects] call FUNC(collectAssembleSets);
if (_sets isEqualTo []) exitWith {};

private _previewClass = (_sets select 0) select 1;

// The static's own Zeus tree icon (the glyph shown next to its create-menu entry),
// resolved live through ZEN's cache so the cursor reads like a normal Zeus placement
// rather than a generic reticle
private _previewIcon = [_previewClass] call zen_common_fnc_getVehicleIcon;

// Objects slot: the gunners. ZEN watches them for the life of the gesture and
// cancels the picker if any one of them is deleted - the one guarantee the old RTZ
// picker never made, where a set whose gunner died mid-drag still dispatched.
[
    _sets apply {_x select 0},
    {
        params ["_confirmed", "", "_posASL", "_sets"];

        if (!_confirmed) exitWith {};

        // ZEN's picker reports ASL. Everything downstream is AGL - the getPos fan-out
        // below and the QGVAR(assemble) payload both, per FUNC(assembleWeapon)'s
        // documented "Position AGL" argument.
        private _position = ASLToAGL _posASL;

        {
            _x params ["_gunner", "_staticClass", "_assistant"];

            // Fan the sets out around the cursor, the first builds on it
            private _target = _position;

            if (_forEachIndex > 0) then {
                _target = _position getPos [FAN_DISTANCE * _forEachIndex, FAN_BEARING * _forEachIndex];
            };

            // Targeted at the gunner: CBA delivers to whichever machine owns him.
            // -1 is the "no facing chosen" sentinel - FUNC(finishBuild) aims the
            // weapon at the gunner's nearest known enemy instead.
            [QGVAR(assemble), [_gunner, _staticClass, _assistant, _target, -1, player], _gunner] call CBA_fnc_targetEvent;
        } forEach _sets;

        [LLSTRING(Assembling), count _sets] call EFUNC(common,showCountMessage);
    },
    _sets,
    "",             // no hint text - the icon alone, like vanilla Zeus placement
    _previewIcon,
    0,              // upright, not ZEN's default 45 - this icon is a vehicle glyph
    COLOR_PREVIEW
] call zen_common_fnc_selectPosition;
