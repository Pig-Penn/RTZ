// NATO (BLU_F), the vanilla western alliance. Its national line-ups live in
// natopacific / natowoodland / natodesert.inc.sqf; CTRG, the Aegis Multinational
// Joint Task Force and the Marines have files of their own.
_costs append [

    // Anti-Air
    ["B_Pickup_aat_rf", 24], // Pickup (AA)
    ["EF_B_MRAP_01_LAAD_NATO", 26], // Hunter (LAAD)
    ["B_APC_Tracked_01_AA_F", 40], // IFV-6a Cheetah

    // APCs
    ["B_APC_Tracked_01_CRV_F", 18], // CRV-6e Bobcat
    ["B_APC_Tracked_01_rcws_F", 20], // IFV-6c Panther
    ["B_APC_Wheeled_01_command_lxWS", 20], // AMV-7 Marshall (CV)
    ["B_APC_Wheeled_01_cannon_F", 22], // AMV-7 Marshall
    ["B_APC_Wheeled_03_cannon_F", 22], // AFV-4 Gorgon
    ["B_APC_Wheeled_01_atgm_lxWS", 24], // AMV-7 Marshall (ATGM)

    // Artillery
    ["B_APC_Wheeled_01_mortar_lxWS", 25], // AMV-7 Marshall (Mortar)
    ["B_MBT_01_arty_F", 35], // M4 Scorcher
    ["B_MBT_01_mlrs_F", 50], // M5 Sandstorm MLRS

    // Boats
    ["B_Boat_Transport_01_F", 2], // Assault Boat
    ["B_Lifeboat", 2], // Rescue Boat
    ["B_Boat_Armed_01_minigun_F", 15], // Speedboat Minigun
    ["EF_B_CombatBoat_Unarmed_NATO", 14], // Combat Boat (Unarmed)
    ["EF_B_CombatBoat_HMG_NATO", 20], // Combat Boat (HMG)
    ["EF_B_CombatBoat_AT_NATO", 26], // Combat Boat (AT)

    // Cars
    ["B_Quadbike_01_F", 2], // Quad Bike
    ["B_Pickup_rf", 3], // Pickup
    ["B_Pickup_Comms_rf", 4], // Pickup (Comms)
    ["B_Pickup_mmg_rf", 7], // Pickup (MMG)
    ["B_LSV_01_unarmed_F", 4], // Prowler (Unarmed)
    ["B_LSV_01_unarmed_black_F", 4], // Prowler (Unarmed)
    ["B_LSV_01_unarmed_olive_F", 4], // Prowler (Unarmed)
    ["B_LSV_01_unarmed_sand_F", 4], // Prowler (Unarmed)
    ["B_LSV_01_armed_F", 7], // Prowler (HMG)
    ["B_LSV_01_armed_black_F", 7], // Prowler (HMG)
    ["B_LSV_01_armed_olive_F", 7], // Prowler (HMG)
    ["B_LSV_01_armed_sand_F", 7], // Prowler (HMG)
    ["B_LSV_01_AT_F", 15], // Prowler (AT)
    ["B_MRAP_01_F", 6], // Hunter
    ["B_MRAP_01_hmg_F", 10], // Hunter (HMG)
    ["B_MRAP_01_gmg_F", 14], // Hunter (GMG)
    ["EF_B_MRAP_01_AT_NATO", 15], // Hunter (AT)
    ["EF_B_MRAP_01_FSV_NATO", 16], // Hunter (FSV)
    ["B_Truck_01_mover_F", 3], // HEMTT
    ["B_Truck_01_transport_F", 4], // HEMTT (Transport)
    ["B_Truck_01_covered_F", 4], // HEMTT (Covered)
    ["B_Truck_01_medical_F", 4], // HEMTT (Medical)
    ["B_Truck_01_flatbed_F", 4], // HEMTT (Flatbed)
    ["B_Truck_01_cargo_F", 4], // HEMTT (Cargo)
    ["B_Truck_01_box_F", 5], // HEMTT (Box)
    ["B_Truck_01_FFT_rf", 5], // HEMTT (Fire Truck)
    ["B_Truck_01_fuel_F", 8], // HEMTT (Fuel)
    ["B_Truck_01_Repair_F", 9], // HEMTT (Repair)
    ["B_Truck_01_ammo_F", 10], // HEMTT (Ammo)

    // Drones
    ["B_UGV_02_Science_F", 2], // ED-1E Roller
    ["B_UAV_RC40_SmokeWhite_RF", 2], // RC-40 Smoke (White)
    ["B_UAV_RC40_SmokeBlue_RF", 2], // RC-40 Smoke (Blue)
    ["B_UAV_RC40_SmokeRed_RF", 2], // RC-40 Smoke (Red)
    ["B_UAV_RC40_SmokeGreen_RF", 2], // RC-40 Smoke (Green)
    ["B_UAV_RC40_SmokeOrange_RF", 2], // RC-40 Smoke (Orange)
    ["B_UAV_01_F", 3], // AR-2 Darter
    ["B_UAV_06_F", 3], // AL-6 Pelican
    ["B_UAV_06_medical_F", 3], // AL-6 Pelican (Medical)
    ["B_UAV_RC40_SENSOR_RF", 4], // RC-40 Scout
    ["B_UGV_02_Demining_F", 5], // ED-1D Pelter
    ["B_UAV_RC40_HE_RF", 6], // RC-40 HE
    ["B_UGV_01_F", 6], // UGV Stomper
    ["B_UAV_02_F", 10], // MQ-4A Greyhawk
    ["B_UAV_02_lxWS", 10], // AP-5 Bustard
    ["B_UGV_01_rcws_F", 12], // UGV Stomper RCWS
    ["B_UAV_02_CAS_F", 20], // MQ-4A Greyhawk (CAS)
    ["B_UAV_05_F", 45], // UCAV Sentinel

    // Helicopters
    ["B_Heli_Light_01_F", 16], // MH-9 Hummingbird
    ["B_Heli_light_03_unarmed_RF", 20], // AH-11F Hellcat (Unarmed)
    ["B_Heli_EC_04_military_RF", 24], // MH-245 Cougar (Unarmed)
    ["B_Heli_Light_01_armed_F", 25], // AH-9 Pawnee
    ["B_Heli_Light_01_dynamicLoadout_F", 25], // AH-9 Pawnee
    ["B_Heli_Transport_01_unarmed_F", 25], // UH-80 Ghost Hawk (Unarmed)
    ["B_Heli_Transport_03_unarmed_F", 25], // CH-67 Huron (Unarmed)
    ["B_Heli_Transport_01_F", 28], // UH-80 Ghost Hawk
    ["B_Heli_Transport_01_camo_F", 28], // UH-80 Ghost Hawk (Camo)
    ["B_Heli_Transport_03_F", 28], // CH-67 Huron
    ["B_Heli_light_03_dynamicLoadout_RF", 30], // AH-11F Hellcat
    ["B_Heli_Transport_01_pylons_F", 32], // UH-80 Ghost Hawk (Stub Wings)
    ["B_Heli_EC_03_RF", 32], // MH-245 Cougar
    ["B_Heli_Attack_01_F", 42], // AH-99 Blackfoot
    ["B_Heli_Attack_01_dynamicLoadout_F", 42], // AH-99 Blackfoot
    ["EF_B_AH99J_NATO", 42], // AH-99J Python
    ["B_Heli_Attack_01_pylons_dynamicLoadout_F", 44], // AH-99 Blackfoot (Stub Wings)

    // Men
    ["B_Survivor_F", 0], // Survivor
    ["B_UAV_AI", 0], // AI
    ["B_UAV_AI_F", 0], // AI
    ["B_Soldier_unarmed_F", 0.2], // Rifleman (Unarmed)
    ["B_crew_F", 0.5], // Crewman
    ["B_helicrew_F", 0.5], // Helicopter Crew
    ["B_Helipilot_F", 0.5], // Helicopter Pilot
    ["B_Pilot_F", 0.5], // Pilot
    ["B_Fighter_Pilot_F", 0.5], // Fighter Pilot
    ["B_Deck_Crew_F", 0.5], // Deck Crew
    ["B_Soldier_lite_F", 0.8], // Rifleman (Light)
    ["B_Soldier_F", 1], // Rifleman
    ["B_Soldier_universal_F", 1], // Soldier
    ["B_CombatFatigues_01_wdl_F", 1], // Rifleman
    ["b_soldier_survival_F", 1], // Survival Fatigues
    ["B_CBRN_Man_Oversuit_01_MTP_F", 1], // Rifleman (CBRN)
    ["B_CBRN_Man_Oversuit_01_Tropic_F", 1], // Rifleman (CBRN)
    ["B_CBRN_Man_Oversuit_01_Wdl_F", 1], // Rifleman (CBRN)
    ["B_RangeMaster_F", 1], // Range Master
    ["B_Competitor_F", 1], // Competitor
    ["B_medic_F", 1], // Combat Life Saver
    ["B_soldier_PG_F", 1], // Para Trooper
    ["B_soldier_AAR_F", 1], // Asst. Autorifleman
    ["B_soldier_AAT_F", 1], // Asst. Missile Specialist (AT)
    ["B_soldier_AAA_F", 1], // Asst. Missile Specialist (AA)
    ["B_Soldier_A_F", 1.1], // Ammo Bearer
    ["B_soldier_M_F", 1.1], // Marksman
    ["B_Soldier_TL_F", 1.2], // Team Leader
    ["B_Soldier_SL_F", 1.2], // Squad Leader
    ["B_ReconFatigues_01_wdl_F", 1.2], // Squad Leader
    ["B_Sharpshooter_F", 1.3], // Sharpshooter
    ["B_soldier_AR_F", 1.3], // Autorifleman
    ["B_CombatFatigues_01_Tshirt_wdl_F", 1.3], // Autorifleman
    ["B_HeavyGunner_F", 1.5], // Heavy Gunner
    ["B_Soldier_GL_F", 1.5], // Grenadier
    ["B_soldier_repair_F", 1.5], // Repair Specialist
    ["B_soldier_LAT2_F", 2.5], // Rifleman (Light AT)
    ["B_soldier_LAT_F", 3], // Rifleman (AT)
    ["B_soldier_exp_F", 3], // Explosive Specialist
    ["B_soldier_mine_F", 3], // Mine Specialist
    ["B_soldier_UGV_02_Science_F", 3], // UGV Operator (ED-1E)
    ["B_support_AMG_F", 3], // Asst. Gunner (HMG/GMG)
    ["B_support_AMort_F", 3], // Asst. Gunner (Mk6)
    ["B_engineer_F", 4], // Engineer
    ["B_soldier_UAV_F", 4], // UAV Operator (AR-2)
    ["B_soldier_UAV_06_F", 4], // UAV Operator (AL-6)
    ["B_soldier_UAV_06_medical_F", 4], // UAV Operator (AL-6, Medical)
    ["B_support_MG_F", 5], // Gunner (HMG)
    ["B_soldier_UGV_02_Demining_F", 6], // UGV Operator (ED-1D)
    ["B_support_Mort_F", 7], // Gunner (Mk6)
    ["B_support_CMort_RF", 8], // Gunner (Light Mortar)
    ["B_support_GMG_F", 9], // Gunner (GMG)
    ["B_soldier_AT_F", 10], // Missile Specialist (AT)
    ["B_soldier_UAV_lxWS", 11], // UAV Operator (AP-5)
    ["B_soldier_AA_F", 12], // Missile Specialist (AA)
    ["B_officer_F", 20], // Officer
    ["B_Officer_Parade_F", 20], // Officer (Parade Dress)
    ["B_Officer_Parade_Veteran_F", 20], // Officer (Veteran, Parade Dress)

    // Men (Patrol)
    ["B_Patrol_Medic_F", 1], // Combat Life Saver
    ["B_Patrol_Soldier_A_F", 1.1], // Ammo Bearer
    ["B_Patrol_Soldier_M_F", 1.1], // Marksman
    ["B_Patrol_Soldier_TL_F", 1.2], // Team Leader
    ["B_Patrol_Soldier_AR_F", 1.3], // Autorifleman
    ["B_Patrol_Soldier_MG_F", 1.5], // Machine Gunner
    ["B_Patrol_HeavyGunner_F", 1.5], // Heavy Gunner
    ["B_Patrol_Engineer_F", 4], // Engineer
    ["B_Patrol_Soldier_UAV_F", 4], // UAV Operator
    ["B_Patrol_Soldier_AT_F", 10], // Missile Specialist (AT)

    // Men (QRF)
    ["B_QRF_Soldier_RF", 2], // Rifleman
    ["B_QRF_medic_RF", 2], // Combat Life Saver
    ["B_QRF_Soldier_SL_RF", 2.2], // Squad Leader
    ["B_QRF_Sharpshooter_RF", 2.3], // Sharpshooter
    ["B_QRF_Soldier_AR_RF", 2.3], // Autorifleman
    ["B_QRF_Soldier_GL_RF", 2.5], // Grenadier
    ["B_QRF_soldier_LAT2_RF", 3.5], // Rifleman (Light AT)
    ["B_QRF_soldier_LAT_RF", 4], // Rifleman (Launcher)
    ["B_QRF_soldier_UAV_RF", 5], // UAV Specialist

    // Men (Special Forces)
    ["B_recon_F", 2], // Recon Scout
    ["B_recon_medic_F", 2], // Recon Paramedic
    ["B_recon_M_F", 2.1], // Recon Marksman
    ["B_recon_TL_F", 2.2], // Recon Team Leader
    ["B_recon_JTAC_F", 2.2], // Recon JTAC
    ["B_Recon_Sharpshooter_F", 2.3], // Recon Sharpshooter
    ["B_recon_LAT_F", 4], // Recon Scout (AT)
    ["B_recon_exp_F", 4], // Recon Demo Specialist
    ["B_diver_F", 2], // Assault Diver
    ["B_diver_TL_F", 2.2], // Diver Team Leader
    ["B_diver_exp_F", 4], // Diver Explosive Specialist
    ["B_sniper_F", 4], // Sniper
    ["B_ghillie_ard_F", 4], // Sniper (Arid)
    ["B_ghillie_lsh_F", 4], // Sniper (Lush)
    ["B_ghillie_sard_F", 4], // Sniper (Semi-Arid)
    ["B_spotter_F", 4], // Spotter

    // Men (Story)
    ["B_Story_Protagonist_F", 1], // Kerry
    ["B_Story_SF_Captain_F", 1], // Miller
    ["B_Story_Pilot_F", 1], // Larkin
    ["B_Captain_Jay_F", 1], // Jay
    ["B_Captain_Pettka_F", 1], // Pettka

    // Men (VR)
    ["B_Protagonist_VR_F", 1], // VR Soldier
    ["B_Soldier_VR_F", 1], // VR Entity

    // Planes
    ["B_Plane_CAS_01_F", 40], // A-164 Wipeout (CAS)
    ["B_Plane_CAS_01_dynamicLoadout_F", 40], // A-164 Wipeout (CAS)
    ["B_Plane_CAS_01_Cluster_F", 42], // A-164 Wipeout (Cluster)
    ["B_Plane_Fighter_01_F", 50], // F/A-181 Black Wasp II
    ["B_Plane_Fighter_01_Cluster_F", 52], // F/A-181 Black Wasp II (Cluster)
    ["B_Plane_Fighter_01_Stealth_F", 55], // F/A-181 Black Wasp II (Stealth)

    // Submersibles
    ["B_SDV_01_F", 6], // SDV

    // Tank Destroyers
    ["B_AFV_Wheeled_01_cannon_F", 22], // Rhino MGS
    ["B_AFV_Wheeled_01_up_cannon_F", 24], // Rhino MGS (UP)

    // Tanks
    ["B_MBT_03_cannon_lxWS", 25], // MBT-52 Kuma
    ["B_MBT_01_cannon_F", 25], // M2A1 Slammer
    ["B_MBT_01_TUSK_F", 27], // M2A4 Slammer (UP)

    // Turrets
    ["B_HMG_02_F", 6], // M2 HMG
    ["B_HMG_02_high_F", 6], // M2 HMG (Raised)
    ["B_HMG_01_F", 6], // Mk30 HMG
    ["B_HMG_01_high_F", 6], // Mk30 HMG (Raised)
    ["B_HMG_01_A_F", 10], // Mk30A HMG
    ["B_GMG_01_F", 10], // Mk32 GMG
    ["B_GMG_01_high_F", 10], // Mk32 GMG (Raised)
    ["B_GMG_01_A_F", 14], // Mk32A GMG
    ["B_static_AT_F", 12], // Static Titan Launcher (AT)
    ["B_static_AA_F", 14], // Static Titan Launcher (AA)
    ["B_CommandoMortar_RF", 7], // Commando Mortar
    ["B_Mortar_01_F", 8], // Mk6 Mortar
    ["B_TwinMortar_RF", 18], // Twin Mortar
    ["B_Static_Designator_01_F", 4], // Remote Designator
    ["B_AAA_System_01_F", 23], // Praetorian 1C
    ["B_SAM_System_01_F", 28], // Mk49 Spartan
    ["B_SAM_System_02_F", 30], // Mk21 Centurion
    ["B_Ship_Gun_01_F", 35], // Mk45 Hammer
    ["B_Ship_MRLS_01_F", 50], // Mk41 VLS
    ["B_Radar_System_01_F", 10], // AN/MPQ-105 Radar
    ["B_SAM_System_03_F", 30] // MIM-145 Defender
];
