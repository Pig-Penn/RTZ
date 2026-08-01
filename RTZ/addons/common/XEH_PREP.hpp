// Selection normalizers — expand a raw ZEN selection into a flat, unique list
// of units / groups / vehicles. Every RTZ entry point goes through these.
PREP(collectSpecialists);
PREP(collectSquads);
PREP(collectUnits);
PREP(collectVehicles);

// Errand engine — the shared walk-there-then-do-something machinery behind
// rtz_assemble, rtz_mine, rtz_loot and rtz_repair, the timed-work loop the
// arrival hooks hand off to (rtz_repair, rtz_supply), plus the curator
// ownership it needs to hand freshly spawned objects back to Zeus.
PREP(approach);
PREP(clearErrand);
PREP(curatorsOf);
PREP(errandToken);
PREP(grantCurators);
PREP(progressJob);

// Deploy countermeasures — context action (CfgZenContext.hpp), its condition,
// and the locality-filtered handler that actually fires.
PREP(canDeploySmoke);
PREP(deploySmokeApply);
PREP(findCountermeasureWeapons);
PREP(orderDeploySmoke);

// Zeus keybind handlers — RTS-style orders issued without opening a context
// menu first. Each guards itself with CHECK_CURATOR_INPUT and returns whether
// it consumed the press.
PREP(curatorMapTeleport);
PREP(flyHeight);
PREP(openUnitInventory);
PREP(switchStance);
PREP(teleportToCursor);
PREP(toggleCombatMode);

// Spawned-unit setup — the CAManBase InitPost path that applies the built-in
// skill table (defaultSkills.inc.sqf).
PREP(applySkill);
PREP(initMan);

// Shared UI / presentation helpers.
PREP(classInfo);
PREP(placementPreview);
PREP(removeContextActions);
PREP(showCountMessage);
PREP(sideColor);
