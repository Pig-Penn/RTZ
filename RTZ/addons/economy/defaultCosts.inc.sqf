// Built-in per-class cost table, in points (POINTS_MAX = a full resource bar).
// Overrides the inheritance-based category default for these exact classes;
// a mission's rtz_economy_overrides entry still wins over anything here.
//
// Source: ACM_MSF (Malden Security) cost sheet. A vehicle costs the same with
// or without its crew, so these are the only prices; group compositions cannot
// be priced through a curator cost table.
GVAR(defaultCosts) = createHashMapFromArray [
    // Vehicles
    ["ACM_B_MSF_V_bo105p1m_Attack", 40],
    ["ACM_B_MSF_V_bo105p1m", 18],
    ["ACM_B_MSF_V_bo105p1m_swooper", 20],
    ["ACM_B_MSF_V_Bpz", 15],
    ["ACM_B_MSF_V_M113_Engineering", 14],
    ["ACM_B_MSF_V_M113", 16],
    ["ACM_B_MSF_V_T55", 25],
    ["ACM_B_MSF_V_bmp1", 22],
    ["ACM_B_MSF_V_Ural_Ammo", 10],
    ["ACM_B_MSF_V_Ural_Repair", 10],
    ["ACM_B_MSF_V_Ural_Refuel", 10],
    ["ACM_B_MSF_V_Ural_Medic", 6],
    ["ACM_B_MSF_V_Ural_Transport", 6],
    ["ACM_B_MSF_V_Ural_Tractor", 4],
    ["ACM_B_MSF_V_brdm_unarmed", 10],
    ["ACM_B_MSF_V_brdm", 15],
    ["ACM_B_MSF_V_UAZ_SPG", 18],
    ["ACM_B_MSF_V_UAZ_Armed", 10],
    ["ACM_B_MSF_V_UAZ", 4],
    // Infantry
    ["ACM_MSF_Soldier_Rifleman", 1],
    ["ACM_MSF_Soldier_Crewman", 0.5],
    ["ACM_MSF_Soldier_HeliPilot", 0.5],
    ["ACM_MSF_Soldier_rifleman_at", 4],
    ["ACM_MSF_Soldier_Squad_Leader", 1],
    ["ACM_MSF_Soldier_Medic", 1],
    ["ACM_MSF_Soldier_Grenadier", 2],
    ["ACM_MSF_Soldier_Autorifleman", 1.5],
    ["ACM_MSF_Soldier_Marksman", 1.5],
    ["ACM_MSF_Soldier_Radioman", 1],
    ["ACM_MSF_Soldier_Anti_Tank", 8],
    ["ACM_MSF_Soldier_Officer", 10],
    ["ACM_MSF_Soldier_Anti_Tank_Assistant", 2],
    ["ACM_MSF_Soldier_Anti_Air", 10],
    ["ACM_MSF_Soldier_Pioneer", 1],
    ["ACM_MSF_CG_Soldier_Rifleman", 2],
    ["ACM_MSF_CG_Soldier_Rifleman_AT", 6],
    ["ACM_MSF_CG_Soldier_Team_Lead", 2],
    ["ACM_MSF_CG_Soldier_Autorifleman", 4],
    ["ACM_MSF_CG_Soldier_Grenadier", 3],
    ["ACM_MSF_CG_Soldier_Marksman", 3],
    ["ACM_MSF_CG_Soldier_CombatMedic", 2],
    ["ACM_MSF_CG_Soldier_RAdio_Operator", 2],
    ["ACM_MSF_CG_Soldier_Officer", 12],
    ["ACM_MSF_CG_Soldier_AntiTank", 10],
    ["ACM_MSF_CG_Soldier_AntiAir", 12],
    // Ships
    ["ACM_B_MSF_V_ArmedBoat", 15],
    ["ACM_B_MSF_V_RescueBoat", 2],
    ["ACM_B_MSF_V_Transport_Boat", 2],
    ["ACM_B_MSF_V_Police_Boat", 4]
];
