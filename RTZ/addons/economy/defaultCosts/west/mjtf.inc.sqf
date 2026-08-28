// Multinational Joint Task Force (Aegis), desert and woodland line-ups. Its
// infantry is shared with marines.inc.sqf.
_costs append [

    // Anti-Air
    ["EF_B_MRAP_01_LAAD_MJTF_Des", 26], // Hunter LAAD
    ["EF_B_MRAP_01_LAAD_MJTF_Wdl", 26], // Hunter LAAD

    // APCs
    ["EF_B_AAV9_MJTF_Des", 20], // AAV-9 Mack
    ["EF_B_AAV9_MJTF_Wdl", 20], // AAV-9 Mack
    ["EF_B_AAV9_50mm_MJTF_Des", 26], // AAV-9A1 Mack
    ["EF_B_AAV9_50mm_MJTF_Wdl", 26], // AAV-9A1 Mack

    // Artillery
    ["EF_B_MBT_01_mlrs_MJTF_Des", 50], // M5 Sandstorm MLRS
    ["EF_B_MBT_01_mlrs_MJTF_Wdl", 50], // M5 Sandstorm MLRS

    // Boats
    ["EF_B_Boat_Transport_01_MJTF_Des", 2], // Assault Boat
    ["EF_B_Boat_Transport_01_MJTF_Wdl", 2], // Assault Boat
    ["EF_B_Lifeboat_MJTF_Des", 2], // Rescue Boat
    ["EF_B_Lifeboat_MJTF_Wdl", 2], // Rescue Boat
    ["EF_B_CombatBoat_Unarmed_MJTF_Des", 14], // Combat Boat (Unarmed)
    ["EF_B_CombatBoat_Unarmed_MJTF_Wdl", 14], // Combat Boat (Unarmed)
    ["EF_B_Boat_Armed_01_minigun_MJTF_Des", 15], // Speedboat Minigun
    ["EF_B_Boat_Armed_01_minigun_MJTF_Wdl", 15], // Speedboat Minigun
    ["EF_B_LCC_MJTF_Des", 16], // LCC-1
    ["EF_B_LCC_MJTF_Wdl", 16], // LCC-1
    ["EF_B_LCC_SideLoad_MJTF_Des", 16], // LCC-1 (Side Load)
    ["EF_B_LCC_SideLoad_MJTF_Wdl", 16], // LCC-1 (Side Load)
    ["EF_B_CombatBoat_HMG_MJTF_Des", 20], // Combat Boat (HMG)
    ["EF_B_CombatBoat_HMG_MJTF_Wdl", 20], // Combat Boat (HMG)
    ["EF_B_CombatBoat_AT_MJTF_Des", 26], // Combat Boat (AT)
    ["EF_B_CombatBoat_AT_MJTF_Wdl", 26], // Combat Boat (AT)

    // Cars
    ["EF_B_Quadbike_01_MJTF_Des", 2], // Quad Bike
    ["EF_B_Quadbike_01_MJTF_Wdl", 2], // Quad Bike
    ["EF_B_Truck_01_mover_MJTF_Des", 4], // HEMTT
    ["EF_B_Truck_01_mover_MJTF_Wdl", 4], // HEMTT
    ["EF_B_Truck_01_transport_MJTF_Des", 4.5], // HEMTT Transport
    ["EF_B_Truck_01_transport_MJTF_Wdl", 4.5], // HEMTT Transport
    ["EF_B_Truck_01_covered_MJTF_Des", 4.5], // HEMTT Transport (Covered)
    ["EF_B_Truck_01_covered_MJTF_Wdl", 4.5], // HEMTT Transport (Covered)
    ["EF_B_Truck_01_medical_MJTF_Des", 4.5], // HEMTT Medical
    ["EF_B_Truck_01_medical_MJTF_Wdl", 4.5], // HEMTT Medical
    ["EF_B_Truck_01_box_MJTF_Des", 5], // HEMTT Box
    ["EF_B_Truck_01_box_MJTF_Wdl", 5], // HEMTT Box
    ["EF_B_MRAP_01_MJTF_Des", 6], // Hunter
    ["EF_B_MRAP_01_MJTF_Wdl", 6], // Hunter
    ["EF_B_Truck_01_fuel_MJTF_Des", 8.5], // HEMTT Fuel
    ["EF_B_Truck_01_fuel_MJTF_Wdl", 8.5], // HEMTT Fuel
    ["EF_B_Truck_01_Repair_MJTF_Des", 9.5], // HEMTT Repair
    ["EF_B_Truck_01_Repair_MJTF_Wdl", 9.5], // HEMTT Repair
    ["EF_B_MRAP_01_hmg_MJTF_Des", 10], // Hunter HMG
    ["EF_B_MRAP_01_hmg_MJTF_Wdl", 10], // Hunter HMG
    ["EF_B_Truck_01_ammo_MJTF_Des", 10.5], // HEMTT Ammo
    ["EF_B_Truck_01_ammo_MJTF_Wdl", 10.5], // HEMTT Ammo
    ["EF_B_MRAP_01_gmg_MJTF_Des", 14], // Hunter GMG
    ["EF_B_MRAP_01_gmg_MJTF_Wdl", 14], // Hunter GMG
    ["EF_B_MRAP_01_AT_MJTF_Des", 15], // Hunter AT
    ["EF_B_MRAP_01_AT_MJTF_Wdl", 15], // Hunter AT
    ["EF_B_MRAP_01_FSV_MJTF_Des", 16], // Hunter FSV
    ["EF_B_MRAP_01_FSV_MJTF_Wdl", 16], // Hunter FSV

    // Drones
    ["EF_B_UAV_01_MJTF_Des", 3], // AR-2 Darter
    ["EF_B_UAV_01_MJTF_Wdl", 3], // AR-2 Darter
    ["EF_B_UGV_01_MJTF_Des", 6], // UGV Stomper
    ["EF_B_UGV_01_MJTF_Wdl", 6], // UGV Stomper
    ["EF_B_UGV_01_rcws_MJTF_Des", 12], // UGV Stomper RCWS
    ["EF_B_UGV_01_rcws_MJTF_Wdl", 12], // UGV Stomper RCWS
    ["EF_B_UAV_02_dynamicLoadout_MJTF_Des", 20], // MQ-4A Greyhawk
    ["EF_B_UAV_02_dynamicLoadout_MJTF_Wdl", 20], // MQ-4A Greyhawk
    ["EF_QAV80_MJTF_Des", 20], // QAV-80 Harpy
    ["EF_QAV80_MJTF_Wdl", 20], // QAV-80 Harpy
    ["EF_QAV80_Stealth_MJTF_Des", 22], // QAV-80 Harpy (Stealth)
    ["EF_QAV80_Stealth_MJTF_Wdl", 22], // QAV-80 Harpy (Stealth)

    // Helicopters
    ["EF_B_Heli_Transport_01_MJTF_Des", 28], // UH-80 Ghost Hawk
    ["EF_B_Heli_Transport_01_MJTF_Wdl", 28], // UH-80 Ghost Hawk
    ["EF_B_Heli_Transport_01_pylons_MJTF_Des", 32], // UH-80 Ghost Hawk (Stub Wings)
    ["EF_B_Heli_Transport_01_pylons_MJTF_Wdl", 32], // UH-80 Ghost Hawk (Stub Wings)
    ["EF_B_Heli_Attack_01_dynamicLoadout_MJTF_Des", 42], // AH-99 Blackfoot
    ["EF_B_Heli_Attack_01_dynamicLoadout_MJTF_Wdl", 42], // AH-99 Blackfoot
    ["EF_B_AH99J_MJTF_Des", 42], // AH-99J Python
    ["EF_B_AH99J_MJTF_Wdl", 42], // AH-99J Python

    // Submersibles
    ["EF_B_SDV_01_MJTF_Des", 6], // SDV
    ["EF_B_SDV_01_MJTF_Wdl", 6], // SDV

    // Tanks
    ["EF_B_MBT_01_cannon_MJTF_Des", 25], // M2A1 Slammer
    ["EF_B_MBT_01_cannon_MJTF_Wdl", 25], // M2A1 Slammer
    ["EF_B_MBT_01_TUSK_MJTF_Des", 27], // M2A4 Slammer UP
    ["EF_B_MBT_01_TUSK_MJTF_Wdl", 27], // M2A4 Slammer UP

    // Turrets
    ["EF_B_HMG_01_MJTF_Des", 6], // Mk30 HMG
    ["EF_B_HMG_01_MJTF_Wdl", 6], // Mk30 HMG
    ["EF_B_HMG_01_high_MJTF_Des", 6], // Mk30 HMG (Raised)
    ["EF_B_HMG_01_high_MJTF_Wdl", 6], // Mk30 HMG (Raised)
    ["EF_B_Mortar_01_MJTF_Des", 8], // Mk6 Mortar
    ["EF_B_Mortar_01_MJTF_Wdl", 8], // Mk6 Mortar
    ["EF_B_HMG_01_A_MJTF_Des", 10], // Mk30A HMG
    ["EF_B_HMG_01_A_MJTF_Wdl", 10], // Mk30A HMG
    ["EF_B_GMG_01_MJTF_Des", 10], // Mk32 GMG
    ["EF_B_GMG_01_MJTF_Wdl", 10], // Mk32 GMG
    ["EF_B_GMG_01_high_MJTF_Des", 10], // Mk32 GMG (Raised)
    ["EF_B_GMG_01_high_MJTF_Wdl", 10], // Mk32 GMG (Raised)
    ["EF_B_Static_AT_MJTF_Des", 12], // Static Titan Launcher (AT)
    ["EF_B_Static_AT_MJTF_Wdl", 12], // Static Titan Launcher (AT)
    ["EF_B_GMG_01_A_MJTF_Des", 14], // Mk32A GMG
    ["EF_B_GMG_01_A_MJTF_Wdl", 14], // Mk32A GMG
    ["EF_B_Static_AA_MJTF_Des", 14], // Static Titan Launcher (AA)
    ["EF_B_Static_AA_MJTF_Wdl", 14], // Static Titan Launcher (AA)
    ["EF_LPD_Turret_1_MJTF_Des", 20], // Mk66 50 mm Cannon
    ["EF_LPD_Turret_1_MJTF_Wdl", 20] // Mk66 50 mm Cannon
];
