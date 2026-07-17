#include "script_component.hpp"
/*
 * Author: Maxim
 * Reads a weapon bag's assembleInfo >> base, the support/tripod bags that must also
 * be present to assemble it. base is normally base[] = {..} but some configs use a
 * bare string, both forms are normalized to an array with empty entries dropped.
 * Single bag weapons such as the Mk6 mortar have no support bag and return [].
 *
 * Config reference: CfgVehicles >> <bag> >> assembleInfo (BI wiki, CfgVehicles
 * Config Reference - assembleTo / primary / base[] / dissasembleTo[]).
 *
 * Arguments:
 * 0: Backpack Class <STRING>
 *
 * Return Value:
 * Required Support Bags <ARRAY of STRING>
 *
 * Example:
 * ["B_HMG_01_weapon_F"] call rtz_assemble_fnc_getBaseBags
 *
 * Public: No
 */

params [["_bag", "", [""]]];

if (_bag isEqualTo "") exitWith {[]};

private _cfgBase = configFile >> "CfgVehicles" >> _bag >> "assembleInfo" >> "base";

(if (isText _cfgBase) then {[getText _cfgBase]} else {getArray _cfgBase}) - [""]
