#include "\x\rtz\addons\zubr\script_component.hpp"
/*
 * Author: Bravo Zero One development (John_Spartan), edited by Chairborne for CUP,
 *         guarded by Maxim
 * Paints one digit of the hull number onto one of the craft's number selections.
 *
 * Reached from the three CustomShipNumber Eden attributes in CfgVehicles.hpp,
 * which is why it keeps CUP's name and its CfgFunctions registration (see
 * CfgFunctions.hpp).
 *
 * NOT EVERY DIGIT IS PACKED. _rip/build_csat.py prunes 1, 4, 6, 8 and 9 as
 * "unreferenced" once gen_config.py has stripped CUP's non-CSAT liveries — and
 * that reference scan is static, so it cannot see THIS function, which assembles
 * its path with `format` from a number a mission maker types into Eden. An unpacked
 * digit is therefore not a missing file any build step would catch: it is a path
 * built at runtime that resolves to nothing, and the selection goes blank or shows
 * the engine's error texture with nothing in the log.
 *
 * The attribute is an EditShort validated only as a number, so a mission maker can
 * also type a multi-digit value or a negative one and get "hull_num_42_ca.paa" or
 * "hull_num_-1_ca.paa". Both are caught here rather than at the config, which has
 * no way to express "one of this set".
 *
 * Tested with `fileExists` rather than against a hardcoded list of the digits that
 * happen to ship today. A list would be a second place to update, and it would be
 * WRONG the moment build_csat.py's prune is corrected and a re-rip packs all ten —
 * failing shut on digits that are sitting right there in the PBO. ACE3 gates
 * texture paths the same way (ace_common_fnc_getVehicleIcon, ace_inventory's
 * preStart), and it costs one lookup on an Eden attribute edit.
 *
 * An unavailable digit LEAVES THE SELECTION ALONE rather than substituting one.
 * Silently painting a different number than the one typed is worse than painting
 * none — the craft would carry a hull number nobody chose, and it would look
 * deliberate. The warning is what makes it discoverable.
 *
 * Arguments:
 * 0: Ship <OBJECT>
 * 1: Digit to display <NUMBER>
 * 2: Hidden selection index <NUMBER>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_ship, 7, 4] call rtz_zubr_fnc_zubrHullNumbers
 *
 * Public: No
 */

if (!isServer) exitWith {};

private _ship = param [0, objNull, [objNull]];
private _number = param [1, 0, [0]];
private _selection = param [2, -1, [0]];

if (isNull _ship || {_selection < 0}) exitWith {};

// floor, not round: a value arriving as 6.9 is a typed 6 that picked up a float
// somewhere, and rounding it up would paint a digit the mission maker never chose.
_number = floor _number;

private _texture = format [ZUBR_HULL_DIGIT_PATH, _number];

if !(fileExists _texture) exitWith {
    WARNING_3("Zubr hull digit %1 is not packed (%2) - selection %3 left unchanged",_number,_texture,_selection);
};

_ship setObjectTextureGlobal [_selection, _texture];
