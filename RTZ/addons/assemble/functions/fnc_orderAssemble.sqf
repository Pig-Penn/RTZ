#include "script_component.hpp"
/*
 * Author: Maxim
 * Context menu statement: opens a ghost model placement preview of the first
 * carried weapon, then orders every disassembled static weapon the selected squads
 * carry to be walked to the picked spot by its gunner and assistant and raised
 * there. The curator drags the translucent static to a spot and rotates it to set
 * its facing, Escape cancels with no order sent. The ghost shows the first set's
 * class: a mixed selection places them all on the same spot, it just previews one
 * of them.
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
// resolved live through ZEN's cache. It rides INSIDE the vanilla Zeus ring
// EFUNC(common,drawZeusIcon) draws, off the same config the engine reads for its
// own placement marker, so a curator cannot tell this picker from a Zeus one
private _previewIcon = [_previewClass] call zen_common_fnc_getVehicleIcon;

[
    _previewClass,
    {
        params ["_confirmed", "_position", "_direction", "_sets"];

        if (!_confirmed) exitWith {};

        {
            _x params ["_gunner", "_staticClass", "_assistant"];

            // Fan the sets out around the cursor, the first builds on it
            private _target = _position;

            if (_forEachIndex > 0) then {
                _target = _position getPos [FAN_DISTANCE * _forEachIndex, FAN_BEARING * _forEachIndex];
            };

            // Targeted at the gunner: CBA delivers to whichever machine owns him
            [QGVAR(assemble), [_gunner, _staticClass, _assistant, _target, _direction, player], _gunner] call CBA_fnc_targetEvent;
        } forEach _sets;

        [LLSTRING(Assembling), count _sets] call EFUNC(common,showCountMessage);
    },
    _sets,
    _previewIcon,
    COLOR_PREVIEW,
    true,
    ""  // no hint text — the ghost static alone, like vanilla Zeus placement
] call EFUNC(common,placementPreview);
