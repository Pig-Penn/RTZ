// NATO (Pacific) (BLU_T_F), the Apex line-up. Costs mirror their nato.inc.sqf
// counterparts, which the Pacific units are re-textures of.
_costs append [

    // Anti-Air
    ["B_T_Pickup_aat_rf", 24], // Pickup (AA)
    ["EF_B_MRAP_01_LAAD_NATO_T", 26], // Hunter LAAD
    ["B_T_APC_Tracked_01_AA_F", 40], // IFV-6a Cheetah

    // APCs
    ["B_T_APC_Tracked_01_CRV_F", 18], // CRV-6e Bobcat
    ["B_T_APC_Tracked_01_rcws_F", 20], // IFV-6c Panther
    ["B_T_APC_Wheeled_01_command_lxWS", 20], // AMV-7 Marshall (CV)
    ["B_T_APC_Wheeled_01_cannon_F", 22], // AMV-7 Marshall
    ["B_T_APC_Wheeled_01_atgm_lxWS", 26], // AMV-7 Marshall (ATGM)

    // Artillery
    ["B_T_APC_Wheeled_01_mortar_lxWS", 25], // AMV-7 Marshall (Mortar)
    ["B_T_MBT_01_arty_F", 35], // M4 Scorcher
    ["B_T_MBT_01_mlrs_F", 50], // M5 Sandstorm MLRS

    // Boats
    ["B_T_Boat_Transport_01_F", 2], // Assault Boat
    ["B_T_Lifeboat", 2], // Rescue Boat
    ["EF_B_CombatBoat_Unarmed_NATO_T", 14], // Combat Boat (Unarmed)
    ["B_T_Boat_Armed_01_minigun_F", 15], // Speedboat Minigun
    ["EF_B_CombatBoat_HMG_NATO_T", 20], // Combat Boat (HMG)
    ["EF_B_CombatBoat_AT_NATO_T", 26], // Combat Boat (AT)

    // Cars
    ["B_T_Quadbike_01_F", 2], // Quad Bike
    ["B_T_Pickup_rf", 3], // Pickup
    ["B_T_Pickup_Comms_rf", 4], // Pickup (Comms)
    ["B_T_Truck_01_mover_F", 4], // HEMTT
    ["B_T_LSV_01_unarmed_F", 4], // Prowler (Unarmed)
    ["B_T_LSV_01_unarmed_black_F", 4], // Prowler (Unarmed)
    ["B_T_LSV_01_unarmed_olive_F", 4], // Prowler (Unarmed)
    ["B_T_LSV_01_unarmed_sand_F", 4], // Prowler (Unarmed)
    ["B_T_Truck_01_transport_F", 4.5], // HEMTT Transport
    ["B_T_Truck_01_covered_F", 4.5], // HEMTT Transport (Covered)
    ["B_T_Truck_01_cargo_F", 4.5], // HEMTT Cargo
    ["B_T_Truck_01_flatbed_F", 4.5], // HEMTT Flatbed
    ["B_T_Truck_01_medical_F", 4.5], // HEMTT Medical
    ["B_T_Truck_01_box_F", 5], // HEMTT Box
    ["B_T_Truck_01_FFT_rf", 5], // HEMTT Fire Truck
    ["B_T_MRAP_01_F", 6], // Hunter
    ["B_T_LSV_01_armed_F", 7], // Prowler (HMG)
    ["B_T_LSV_01_armed_black_F", 7], // Prowler (HMG)
    ["B_T_LSV_01_armed_olive_F", 7], // Prowler (HMG)
    ["B_T_LSV_01_armed_sand_F", 7], // Prowler (HMG)
    ["B_T_Pickup_mmg_rf", 8], // Pickup (MMG)
    ["B_T_Truck_01_fuel_F", 8.5], // HEMTT Fuel
    ["B_T_Truck_01_Repair_F", 9.5], // HEMTT Repair
    ["B_T_MRAP_01_hmg_F", 10], // Hunter HMG
    ["B_T_Truck_01_ammo_F", 10.5], // HEMTT Ammo
    ["B_T_MRAP_01_gmg_F", 14], // Hunter GMG
    ["B_T_LSV_01_AT_F", 15], // Prowler (AT)
    ["EF_B_MRAP_01_AT_NATO_T", 15], // Hunter AT
    ["EF_B_MRAP_01_FSV_NATO_T", 16], // Hunter FSV

    // Drones
    ["B_T_UGV_01_olive_F", 6], // UGV Stomper
    ["B_T_UGV_01_rcws_olive_F", 12], // UGV Stomper RCWS
    ["B_T_UAV_03_dynamicLoadout_F", 20], // MQ-12 Falcon

    // Men
    ["B_T_Soldier_unarmed_F", 0.2], // Rifleman (Unarmed)
    ["B_T_Crew_F", 0.5], // Crewman
    ["B_T_Helicrew_F", 0.5], // Helicopter Crew
    ["B_T_Helipilot_F", 0.5], // Helicopter Pilot
    ["B_T_Pilot_F", 0.5], // Pilot
    ["B_T_Soldier_F", 1], // Rifleman
    ["B_T_Soldier_universal_F", 1], // Soldier
    ["B_T_Medic_F", 1], // Combat Life Saver
    ["B_T_Soldier_PG_F", 1], // Para Trooper
    ["B_T_Soldier_AAR_F", 1], // Asst. Autorifleman
    ["B_T_Soldier_AAT_F", 1], // Asst. Missile Specialist (AT)
    ["B_T_Soldier_AAA_F", 1], // Asst. Missile Specialist (AA)
    ["B_T_Soldier_A_F", 1.1], // Ammo Bearer
    ["B_T_soldier_M_F", 1.1], // Marksman
    ["B_T_Soldier_TL_F", 1.2], // Team Leader
    ["B_T_Soldier_SL_F", 1.2], // Squad Leader
    ["B_T_Soldier_AR_F", 1.3], // Autorifleman
    ["B_T_Soldier_GL_F", 1.5], // Grenadier
    ["B_T_Soldier_Repair_F", 1.5], // Repair Specialist
    ["B_T_Soldier_LAT2_F", 2.5], // Rifleman (Light AT)
    ["B_T_Soldier_LAT_F", 3], // Rifleman (AT)
    ["B_T_Soldier_Exp_F", 3], // Explosive Specialist
    ["B_T_soldier_mine_F", 3], // Mine Specialist
    ["B_T_Support_AMG_F", 3], // Asst. Gunner (HMG/GMG)
    ["B_T_Support_AMort_F", 3], // Asst. Gunner (Mk6)
    ["B_T_Engineer_F", 4], // Engineer
    ["B_T_Soldier_UAV_F", 4], // UAV Operator (AR-2)
    ["B_T_soldier_UAV_06_F", 4], // UAV Operator (AL-6)
    ["B_T_soldier_UAV_06_medical_F", 4], // UAV Operator (AL-6, Medical)
    ["B_T_Support_MG_F", 5], // Gunner (HMG)
    ["B_T_Support_Mort_F", 7], // Gunner (Mk6)
    ["B_T_Support_GMG_F", 9], // Gunner (GMG)
    ["B_T_Soldier_AT_F", 10], // Missile Specialist (AT)
    ["B_T_Soldier_AA_F", 12], // Missile Specialist (AA)
    ["B_T_Officer_F", 20], // Officer

    // Men (Special Forces)
    ["B_T_Recon_F", 2], // Recon Scout
    ["B_T_Recon_Medic_F", 2], // Recon Paramedic
    ["B_T_Recon_M_F", 2.1], // Recon Marksman
    ["B_T_Recon_TL_F", 2.2], // Recon Team Leader
    ["B_T_Recon_JTAC_F", 2.2], // Recon JTAC
    ["B_T_Recon_LAT_F", 4], // Recon Scout (AT)
    ["B_T_Recon_Exp_F", 4], // Recon Demo Specialist
    ["B_T_Diver_F", 2], // Assault Diver
    ["B_T_Diver_TL_F", 2.2], // Diver Team Leader
    ["B_T_Diver_Exp_F", 4], // Diver Explosive Specialist
    ["B_T_Sniper_F", 4], // Sniper
    ["B_T_ghillie_tna_F", 4], // Sniper (Jungle)
    ["B_T_Spotter_F", 4], // Spotter

    // Planes
    ["B_T_VTOL_01_infantry_F", 55], // V-44 X Blackfish (Infantry Transport)
    ["B_T_VTOL_01_infantry_blue_F", 55], // V-44 X Blackfish (Infantry Transport)
    ["B_T_VTOL_01_infantry_olive_F", 55], // V-44 X Blackfish (Infantry Transport)
    ["B_T_VTOL_01_vehicle_F", 55], // V-44 X Blackfish (Vehicle Transport)
    ["B_T_VTOL_01_vehicle_blue_F", 55], // V-44 X Blackfish (Vehicle Transport)
    ["B_T_VTOL_01_vehicle_olive_F", 55], // V-44 X Blackfish (Vehicle Transport)
    ["B_T_VTOL_01_armed_F", 60], // V-44 X Blackfish (Armed)
    ["B_T_VTOL_01_armed_blue_F", 60], // V-44 X Blackfish (Armed)
    ["B_T_VTOL_01_armed_olive_F", 60], // V-44 X Blackfish (Armed)

    // Tank Destroyers
    ["B_T_AFV_Wheeled_01_cannon_F", 22], // Rhino MGS
    ["B_T_AFV_Wheeled_01_up_cannon_F", 24], // Rhino MGS UP

    // Tanks
    ["B_T_MBT_01_cannon_F", 25], // M2A1 Slammer
    ["B_T_MBT_01_TUSK_F", 27], // M2A4 Slammer UP

    // Turrets
    ["B_T_HMG_01_F", 6], // Mk30 HMG
    ["B_T_Mortar_01_F", 8], // Mk6 Mortar
    ["B_T_GMG_01_F", 10], // Mk32 GMG
    ["B_T_Static_AT_F", 12], // Static Titan Launcher (AT)
    ["B_T_Static_AA_F", 14], // Static Titan Launcher (AA)
    ["B_T_TwinMortar_RF", 18] // Twin Mortar 120 mm
];
