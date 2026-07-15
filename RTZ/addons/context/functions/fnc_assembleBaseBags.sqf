#include "script_component.hpp"
/*
 * rtz_fnc_assembleBaseBags
 *
 * Reads a weapon bag's assembleInfo >> base — the support/tripod bags that must
 * also be present to assemble it. base is normally base[] = {..} but some configs
 * use a bare string; both forms are normalized to an array with empty entries
 * dropped (single-bag weapons such as the Mk6 mortar return []). Shared by
 * FUNC(findAssembleSet) and FUNC(buildDisassembleMap), which previously
 * duplicated the normalization.
 *
 * Parameters:
 *   0: String — backpack class ("" → [])
 * Returns: Array of required support-bag classnames.
 */

params [["_bag", ""]];

if (_bag isEqualTo "") exitWith { [] };

private _cfgBase = configFile >> "CfgVehicles" >> _bag >> "assembleInfo" >> "base";

(if (isText _cfgBase) then { [getText _cfgBase] } else { getArray _cfgBase }) - [""]
