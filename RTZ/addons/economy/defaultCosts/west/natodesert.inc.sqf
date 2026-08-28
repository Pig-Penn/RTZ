// NATO (Desert), the Western Sahara (lxWS) line-up. Costs mirror their
// nato.inc.sqf counterparts, which the Desert units are re-textures of.
_costs append [

    // Anti-Air
    ["B_D_APC_Tracked_01_aa_lxWS", 40], // IFV-6a Cheetah

    // APCs
    ["B_D_APC_Tracked_01_CRV_lxWS", 18], // CRV-6e Bobcat
    ["B_D_APC_Tracked_01_rcws_lxWS", 20], // IFV-6c Panther
    ["B_D_APC_Wheeled_01_command_lxWS", 20], // AMV-7 Marshall (CV)
    ["B_D_APC_Wheeled_01_cannon_lxWS", 22], // AMV-7 Marshall
    ["B_D_APC_Wheeled_01_atgm_lxWS", 26], // AMV-7 Marshall (ATGM)

    // Artillery
    ["B_D_APC_Wheeled_01_mortar_lxWS", 25], // AMV-7 Marshall (Mortar)
    ["B_D_MBT_01_arty_lxWS", 35], // M4 Scorcher
    ["B_D_MBT_01_mlrs_lxWS", 50], // M5 Sandstorm MLRS

    // Cars
    ["B_D_Quadbike_01_lxWS", 2], // Quad Bike
    ["B_D_Truck_01_mover_lxWS", 4], // HEMTT
    ["B_D_Truck_01_transport_lxWS", 4.5], // HEMTT Transport
    ["B_D_Truck_01_covered_lxWS", 4.5], // HEMTT Transport (Covered)
    ["B_D_Truck_01_cargo_lxWS", 4.5], // HEMTT Cargo
    ["B_D_Truck_01_flatbed_lxWS", 4.5], // HEMTT Flatbed
    ["B_D_Truck_01_medical_lxWS", 4.5], // HEMTT Medical
    ["B_D_Truck_01_box_lxWS", 5], // HEMTT Box
    ["B_D_MRAP_01_lxWS", 6], // Hunter
    ["B_D_Truck_01_fuel_lxWS", 8.5], // HEMTT Fuel
    ["B_D_Truck_01_Repair_lxWS", 9.5], // HEMTT Repair
    ["B_D_MRAP_01_hmg_lxWS", 10], // Hunter HMG
    ["B_D_Truck_01_ammo_lxWS", 10.5], // HEMTT Ammo
    ["B_D_MRAP_01_gmg_lxWS", 14], // Hunter GMG

    // Drones
    ["B_D_UGV_01_lxWS", 6], // UGV Stomper
    ["B_D_UGV_01_rcws_lxWS", 12], // UGV Stomper RCWS

    // Helicopters
    ["B_D_Heli_Light_01_lxWS", 16], // MH-9 Hummingbird
    ["B_D_Heli_Light_01_dynamicLoadout_lxWS", 25], // AH-9 Pawnee
    ["B_D_Heli_Transport_01_lxWS", 28], // UH-80 Ghost Hawk
    ["B_D_Heli_Attack_01_dynamicLoadout_lxWS", 42], // AH-99 Blackfoot

    // Men
    ["B_D_Survivor_lxWS", 0], // Survivor
    ["B_D_Soldier_unarmed_lxWS", 0.2], // Rifleman (Unarmed)
    ["B_D_crew_lxWS", 0.5], // Crewman
    ["B_D_HeliPilot_lxWS", 0.5], // Helicopter Pilot
    ["B_D_Pilot_lxWS", 0.5], // Pilot
    ["B_D_Fighter_Pilot_F", 0.5], // Fighter Pilot
    ["B_D_Soldier_lite_lxWS", 0.8], // Rifleman (Light)
    ["B_D_Soldier_lxWS", 1], // Rifleman
    ["B_D_medic_lxWS", 1], // Combat Life Saver
    ["B_D_soldier_PG_lxWS", 1], // Para Trooper
    ["B_D_soldier_AAR_lxWS", 1], // Asst. Autorifleman
    ["B_D_soldier_AAT_lxWS", 1], // Asst. Missile Specialist (AT)
    ["B_D_soldier_AAA_lxWS", 1], // Asst. Missile Specialist (AA)
    ["B_D_Soldier_A_lxWS", 1.1], // Ammo Bearer
    ["B_D_soldier_M_lxWS", 1.1], // Marksman
    ["B_D_Soldier_TL_lxWS", 1.2], // Team Leader
    ["B_D_Soldier_SL_lxWS", 1.2], // Squad Leader
    ["B_D_soldier_AR_lxWS", 1.3], // Autorifleman
    ["B_D_Soldier_GL_lxWS", 1.5], // Grenadier
    ["B_D_soldier_repair_lxWS", 1.5], // Repair Specialist
    ["B_D_soldier_LAT2_lxWS", 2.5], // Rifleman (Light AT)
    ["B_D_soldier_LAT_lxWS", 3], // Rifleman (AT)
    ["B_D_soldier_exp_lxWS", 3], // Explosive Specialist
    ["B_D_soldier_mine_lxWS", 3], // Mine Specialist
    ["B_D_support_AMort_lxWS", 3], // Asst. Gunner (Mk6)
    ["B_D_engineer_lxWS", 4], // Engineer
    ["B_D_soldier_UAV01_lxWS", 4], // UAV Operator
    ["B_D_soldier_AT_lxWS", 10], // Missile Specialist (AT)
    ["B_D_soldier_UAV02_lxWS", 11], // UAV Operator (AP-5)
    ["B_D_soldier_AA_lxWS", 12], // Missile Specialist (AA)
    ["B_D_officer_lxWS", 20], // Officer

    // Men (Special Forces)
    ["B_D_recon_lxWS", 2], // Recon Scout
    ["B_D_recon_medic_lxWS", 2], // Recon Paramedic
    ["B_D_recon_M_lxWS", 2.1], // Recon Marksman
    ["B_D_recon_TL_lxWS", 2.2], // Recon Team Leader
    ["B_D_recon_JTAC_lxWS", 2.2], // Recon JTAC
    ["B_D_recon_LAT_lxWS", 4], // Recon Scout (AT)
    ["B_D_recon_exp_lxWS", 4], // Recon Demo Specialist

    // Planes
    ["B_D_Plane_CAS_01_dynamicLoadout_lxWS", 40], // A-164 Wipeout (CAS)

    // Tanks
    ["B_D_MBT_01_cannon_lxWS", 25], // M2A1 Slammer
    ["B_D_MBT_01_TUSK_lxWS", 27], // M2A4 Slammer UP

    // Turrets
    ["B_D_Mortar_01_lxWS", 8], // Mk6 Mortar
    ["B_D_static_AT_lxWS", 12], // Static Titan Launcher (AT)
    ["B_D_static_AA_lxWS", 14] // Static Titan Launcher (AA)
];
