// Zeus is wired up here rather than as a placed ModuleCurator_F in mission.sqm:
// the module's owner/addon attributes are a fiddly nest of CustomAttributes in
// the SQM, whereas this is three engine calls that are obvious on inspection and
// survive a mission.sqm re-save from the 3DEN editor.
//
// Test scaffolding only — this mission exists so `hemtt launch` drops you
// straight into a curator interface with RTZ loaded. It is not shipped.

if (!hasInterface) exitWith {};

[] spawn {
    waitUntil {!isNull player && {player == player}};

    private _curator = (createGroup sideLogic) createUnit ["ModuleCurator_F", position player, [], 0, "NONE"];

    // Every addon's content in the Zeus tree, and everything already on the map
    // editable. Without the first call the entity list is empty; without the
    // second, nothing placed by the mission itself can be selected — and an RTS
    // mod is untestable if you cannot select what you are ordering.
    _curator addCuratorAddons (["true", "configFile >> 'CfgPatches'"] call BIS_fnc_getCfgSubClasses);
    _curator addCuratorEditableObjects [allMissionObjects "All", true];

    player assignCurator _curator;
};
