// Saint Anselm Constabulary (2035) (ACM_B_SAC_2035), the modern line-up of
// Project Anselm's BLUFOR force. Its Cold War counterpart lives in sac.inc.sqf;
// classes suffixed _M are retextures of that era's hardware and are priced the
// same, so a change here usually wants the same change there.
_costs append [

    // Men
    ["ACM_b_sam_2035_men_survivor", 0], // Survivor
    ["ACM_b_sam_2035_men_unarmed", 0.2], // Rifleman (Unarmed)
    ["ACM_b_sam_2035_men_Crew", 0.5], // Crewman
    ["ACM_b_sam_2035_men_JetPilot", 0.5], // Fixed-Wing Pilot
    ["ACM_b_sam_2035_men_JetPilot_Co", 0.5], // Fixed-Wing Copilot
    ["ACM_b_sam_2035_men_rifleman_light", 0.8], // Rifleman (Light)
    ["ACM_b_sam_2035_men_rifleman", 1], // Rifleman
    ["ACM_b_sam_2035_men_rifleman_2", 1], // Rifleman 2
    ["ACM_b_sam_2035_men_rifleman_3", 1], // Rifleman 3
    ["ACM_b_sam_2035_men_gunner", 1], // Gunner 1
    ["ACM_b_sam_2035_men_gunner2", 1], // Gunner 2
    ["ACM_b_sam_2035_men_Medic", 1], // Combat Life Saver
    ["ACM_b_sam_2035_men_ParadeDress", 1], // Constable (Parade Dress)
    ["ACM_b_sam_2035_men_ParadeDress_Vet", 1], // Constable (Parade Dress, Veteran)
    ["ACM_b_sam_2035_men_RTO", 1.2], // RTO 1
    ["ACM_b_sam_2035_men_RTO2", 1.2], // RTO 2
    ["ACM_b_sam_2035_men_AR", 1.5], // Autorifleman
    ["ACM_b_sam_2035_men_MR", 1.5], // Marksman
    ["ACM_b_sam_2035_men_SL", 1.6], // Sergeant
    ["ACM_b_sam_2035_men_GR", 2], // Grenadier
    ["ACM_b_sam_2035_men_Demo", 3], // Demolitions
    ["ACM_b_sam_2035_men_EOD", 3], // EOD
    ["ACM_b_sam_2035_men_rifleman_AT", 3.5], // Rifleman (AT)
    ["ACM_b_sam_2035_men_UAV", 4], // UAV Specialist
    ["ACM_b_sam_2035_men_UGV", 4], // UGV Specialist
    ["ACM_b_sam_2035_men_HAT", 10], // Heavy Anti-Tank
    ["ACM_b_sam_2035_men_AA", 12], // MANPAD Operator
    ["ACM_b_sam_2035_men_officer", 20], // Superintendent

    // Men (Constabulary Reserve)
    ["ACM_b_sam_2035_men_CR_Rifleman", 0.8], // Reserve. Rifleman 1
    ["ACM_b_sam_2035_men_CR_Rifleman_Garand", 0.8], // Reserve. Rifleman 2
    ["ACM_b_sam_2035_men_CR_Rifleman_FN49", 0.8], // Reserve. Rifleman 3
    ["ACM_b_sam_2035_men_CR_Rifleman_AK", 0.8], // Reserve. Rifleman 4
    ["ACM_b_sam_2035_men_CR_Rifleman_SKS", 0.8], // Reserve. Rifleman 5
    ["ACM_b_sam_2035_men_CR_SUB", 0.8], // Reserve. Submachinegunner
    ["ACM_b_sam_2035_men_CR_CLS", 0.8], // Reserve. CLS
    ["ACM_b_sam_2035_men_CR_RTO", 1], // Reserve. RTO
    ["ACM_b_sam_2035_men_CR_AR", 1.2], // Reserve. Autorifleman
    ["ACM_b_sam_2035_men_CR_MR", 1.2], // Reserve. Marksman
    ["ACM_b_sam_2035_men_CR_TL", 1.3], // Reserve. Squad Lead
    ["ACM_b_sam_2035_men_CR_Rifleman_AT", 3], // Reserve. Rifleman (AT)

    // Men (Special Forces)
    ["ACM_b_sam_2035_men_SF_Scout", 2], // Recon Scout
    ["ACM_b_sam_2035_men_SF_Medic", 2], // Recon CLS
    ["ACM_b_sam_2035_men_SF_TL", 2.3], // Recon Team Lead
    ["ACM_b_sam_2035_men_SF_Marksman", 2.5], // Recon Marksman
    ["ACM_b_sam_2035_men_SF_Auto", 2.5], // Recon Autorifleman
    ["ACM_b_sam_2035_men_SF_CT", 2.5], // Counter-Terrorism Expert
    ["ACM_b_sam_2035_men_SF_Grenadier", 3], // Recon Grenadier
    ["ACM_b_sam_2035_men_SF_Demo", 4], // Recon Demolitions
    ["ACM_b_sam_2035_men_SF_Scout_AT", 5], // Recon Scout (AT)

    // Boats
    ["acm_b_sac_boat1_M", 10], // Patrol Boat
    ["acm_b_sac_boat2_M", 16], // Patrol Boat (Heavy)

    // Cars
    ["acm_b_sac_vehicle_Bike_CR", 1], // Bicycle
    ["acm_b_sac_vehicle_Bike_Mule_CR", 1], // Bicycle (Cargo)
    ["acm_b_sac_vehicle_m151_M", 3], // M151
    ["acm_b_sac_vehicle_m151_mg_M", 6], // M151 (MG)
    ["acm_b_sac_vehicle_m151_mg_patrol_M", 7], // M151 (MG, Patrol)
    ["acm_b_sac_vehicle_m151_Armoured_M", 8], // M151 (Armored)
    ["acm_b_sac_vehicle_m151_M40_M", 12], // M151 (M40 Recoilless)
    ["acm_b_sac_vehicle_m151_TOW_M", 14], // M151 (TOW)

    // Trucks
    ["acm_b_sac_vehicle_m54_transport_M", 4], // M54 (Transport)
    ["acm_b_sac_vehicle_m54_transport_Cover_M", 4], // M54 (Covered)
    ["acm_b_sac_vehicle_m54_fuel_M", 8], // M54 (Fuel)
    ["acm_b_sac_vehicle_m54_battleBus_M", 8], // M54 (MG)
    ["acm_b_sac_vehicle_m54_repair_M", 9], // M54 (Repair)
    ["acm_b_sac_vehicle_m54_ammo_M", 10], // M54 (Ammo)
    ["acm_b_sac_vehicle_m54_AA_M", 16], // M54 (AA)

    // APCs
    ["acm_b_sog_sac_vehicle_m113_M", 16], // M113
    ["acm_b_sog_sac_vehicle_m113_ACAV_M", 20], // M113 (ACAV)
    ["acm_b_sog_sac_vehicle_m113_M40_M", 22], // M113 (M40 Recoilless)

    // Tanks
    ["acm_b_sac_vehicle_type63_m", 20], // Type 63
    ["acm_b_sac_vehicle_mora", 26], // FV-720 Mora

    // Helicopters
    ["acm_b_sac_vehicle_WY55", 20], // WY-55 Hellcat (Unarmed)
    ["acm_b_sac_vehicle_WY55_Armed", 30], // WY-55 Hellcat

    // Planes
    ["acm_b_sac_vehicle_F4_CAP", 38], // F-4 (CAP)
    ["acm_b_sac_vehicle_F4_MR", 40], // F-4 (Multi-Role)
    ["acm_b_sac_vehicle_F4_AT", 42], // F-4 (AT)
    ["acm_b_sac_vehicle_F4_SEAD", 42], // F-4 (SEAD)

    // Drones
    ["acm_b_sac_drone_uav", 3], // UAV
    ["acm_b_sac_drone_improv_2035", 3], // UAV (Improvised)
    ["acm_b_sac_drone_UGV", 5], // UGV

    // Turrets
    ["acm_b_sac_turret_m2_low_M", 6], // M2 HMG
    ["acm_b_sac_turret_m2_high_M", 6], // M2 HMG (Raised)
    ["acm_b_sac_turret_mortar_M", 7], // M2 Mortar
    ["acm_b_sac_turret_m101_AT_M", 12], // M101 Howitzer (Direct Fire)
    ["acm_b_sac_turret_m45_M", 12], // M45 Quadmount (AA)
    ["acm_b_sac_turret_m40_M", 14], // M40 Recoilless Rifle
    ["acm_b_sac_turret_tow_M", 14], // TOW Launcher
    ["acm_b_sac_turret_zpu4_M", 14], // ZPU-4 (AA)
    ["acm_b_sac_turret_l60mk3_M", 16], // Bofors L/60 Mk3 (AA)
    ["acm_b_sac_turret_l70mk2_M", 20], // Bofors L/70 Mk2 (AA)

    // Artillery
    ["acm_b_sac_turret_m101_arty_M", 30], // M101 Howitzer

    // --- GM Vehicles submod (acm_saintanselm_gmvehicles) ---

    // Trucks
    ["acm_b_sac_vehicle_u1300_flatbed_M", 4], // U1300L (Flatbed)
    ["acm_b_sac_vehicle_u1300_cargo_M", 4], // U1300L (Cargo)
    ["acm_b_sac_vehicle_kat451_cargo_M", 5], // Kat 451 (Cargo)
    ["acm_b_sac_vehicle_kat452_container_M", 5], // Kat 452 (Container)
    ["acm_b_sac_vehicle_kat451_refuel", 8], // Kat 451 (Fuel), unsuffixed but 2035
    ["acm_b_sac_vehicle_u1300_repair_M", 9], // U1300L (Repair)
    ["acm_b_sac_vehicle_kat451_ammo_M", 10], // Kat 451 (Ammo)
    ["acm_b_sac_vehicle_kat454_ammo_M", 10], // Kat 454 (Ammo)

    // APCs
    ["acm_b_sac_vehicle_m113_M", 16], // M113
    ["acm_b_sac_vehicle_m113_engineer_M", 16], // M113 (Engineer)
    ["acm_b_sac_vehicle_m113_command_M", 16], // M113 (Command)
    ["acm_b_sac_vehicle_m113a2dk_pnmk", 22], // M113A2DK PNMK, unsuffixed but 2035

    // Artillery
    ["acm_b_sac_vehicle_m109g_M", 45], // M109G
    ["acm_b_sac_vehicle_kat463_mlrs_M", 50] // Kat 463 (LARS)
];
