// Alcillian Territorial Integrity Units (2035) (ACM_O_ATIU_2035), the modern
// line-up of Project Anselm's OPFOR force. Its Cold War counterpart lives in
// atiu.inc.sqf; classes suffixed _M are retextures of that era's hardware and
// are priced the same, so a change here usually wants the same change there.
_costs append [

    // Men
    ["ACM_o_alci_2035_men_survivor", 0], // Survivor
    ["ACM_o_alci_2035_men_unarmed", 0.2], // Rifleman (Unarmed)
    ["ACM_o_alci_2035_men_Crewman", 0.5], // Crewman
    ["ACM_o_alci_2035_men_JetPilot", 0.5], // Fixed-Wing Pilot
    ["ACM_o_alci_2035_men_rifleman_light", 0.8], // Rifleman (Light)
    ["ACM_o_alci_2035_men_rifleman", 1], // Rifleman
    ["ACM_o_alci_2035_men_rifleman_2", 1], // Rifleman (CQB)
    ["ACM_o_alci_2035_men_rifleman_3", 1], // Rifleman 3
    ["ACM_o_alci_2035_men_rifleman_4", 1], // Rifleman 4
    ["ACM_o_alci_2035_men_Gunner", 1], // Gunner 1
    ["ACM_o_alci_2035_men_Medic", 1], // Combat Life Saver
    ["ACM_o_alci_2035_men_RTO", 1.2], // RTO
    ["ACM_o_alci_2035_men_marksman", 1.5], // Marksman
    ["ACM_o_alci_2035_men_MG", 1.5], // Machinegunner
    ["ACM_o_alci_2035_men_SL", 1.6], // Squad Lead
    ["ACM_o_alci_2035_men_grenadier", 2], // Grenadier
    ["ACM_o_alci_2035_men_Sapper", 3], // Sapper
    ["ACM_o_alci_2035_men_rifleman_AT", 3.5], // Rifleman (AT)
    ["ACM_o_alci_2035_men_UAV", 4], // UAV Specialist
    ["ACM_o_alci_2035_men_AT", 10], // Anti-Tank
    ["ACM_o_alci_2035_men_AA", 12], // MANPAD Operator
    ["ACM_o_alci_2035_men_Officer", 20], // Officer

    // Men (Special Forces)
    ["ACM_o_alci_2035_SF_Scout", 2], // Recon Scout
    ["ACM_o_alci_2035_SF_CLS", 2], // Recon CLS
    ["ACM_o_alci_2035_SF_SL", 2.3], // Recon Team Lead
    ["ACM_o_alci_2035_SF_MR", 2.5], // Recon Marksman
    ["ACM_o_alci_2035_SF_AR", 2.5], // Recon Autorifleman
    ["ACM_o_alci_2035_SF_IS", 2.5], // Infiltration Specialist
    ["ACM_o_alci_2035_SF_Grenadier", 3], // Recon Grenadier
    ["ACM_o_alci_2035_SF_Demo", 4], // Recon Sapper
    ["ACM_o_alci_2035_SF_Scout_AT", 5], // Recon Scout (AT)

    // Boats
    ["acm_o_alci_boat1_M", 10], // Patrol Boat
    ["acm_o_alci_boat2_M", 16], // Patrol Boat (Heavy)

    // Cars
    ["acm_o_alci_vehicle_m151_M", 3], // M151
    ["acm_o_alci_vehicle_BTR40_Ambulance_M", 6], // BTR-40 (Medical)
    ["acm_o_alci_vehicle_m151_mg_M", 6], // M151 (MG)
    ["acm_o_alci_vehicle_BTR40_M", 8], // BTR-40
    ["acm_o_alci_vehicle_m151_Armoured_M", 8], // M151 (Armored)
    ["acm_o_alci_vehicle_BTR40_Dshkm_M", 12], // BTR-40 (DShKM)
    ["acm_o_alci_vehicle_m151_M40_M", 12], // M151 (M40 Recoilless)
    ["acm_o_alci_vehicle_m151_TOW_M", 14], // M151 (TOW)
    ["acm_o_alci_vehicle_BTR40_ZPU_M", 16], // BTR-40 (ZPU)

    // Trucks
    ["acm_o_alci_vehicle_z157_transport_M", 4], // Z-157 (Transport)
    ["acm_o_alci_vehicle_z157_transport_cover_M", 4], // Z-157 (Covered)
    ["acm_o_alci_vehicle_z157_fuel_M", 8], // Z-157 (Fuel)
    ["acm_o_alci_vehicle_z157_repair_M", 9], // Z-157 (Repair)
    ["acm_o_alci_vehicle_z157_ammo_M", 10], // Z-157 (Ammo)
    ["acm_o_alci_vehicle_z157_Radar_M", 12], // Z-157 (Radar)
    ["acm_o_alci_vehicle_z157_ZPU_M", 18], // Z-157 (ZPU)
    ["acm_o_alci_vehicle_z157_SAM_M", 20], // Z-157 (SAM)

    // APCs
    ["acm_o_sog_alc_vehicle_m113_M", 16], // M113
    ["acm_o_sog_alc_vehicle_m113_ACAV_M", 20], // M113 (ACAV)

    // Tanks
    ["acm_o_alci_vehicle_type63_m", 20], // Type 63

    // Helicopters
    ["acm_o_alci_vehicle_uh1c_slick_M", 20], // UH-1C (Transport)
    ["acm_o_alci_vehicle_PO30", 20], // PO-30 Orca (Unarmed)
    ["acm_o_alci_vehicle_uh1c_gunship_M", 28], // UH-1C (Gunship)
    ["acm_o_alci_vehicle_PO30_armed", 30], // PO-30 Orca
    ["acm_o_alci_vehicle_ah1g_m", 40], // AH-1G Cobra

    // Planes
    ["acm_o_alci_J6_Base", 36], // J-6 (CAP)
    ["acm_o_alci_J6_CAS", 40], // J-6 (CAS)
    ["acm_o_alci_J6_PortStrike", 40], // J-6 (Port Strike)

    // Drones
    ["acm_o_alci_drone_UAV", 3], // UAV

    // Turrets
    ["acm_o_alci_turret_m2_low_M", 6], // M2 HMG
    ["acm_o_alci_turret_m2_high_M", 6], // M2 HMG (Raised)
    ["acm_o_alci_turret_mortar_M", 7], // M2 Mortar
    ["acm_o_alci_turret_m101_AT_M", 12], // M101 Howitzer (Direct Fire)
    ["acm_o_alci_turret_type56rr_M", 12], // Type 56 Recoilless Rifle
    ["acm_o_alci_turret_rsna75_M", 12], // RSNA-75 Radar
    ["acm_o_alci_turret_m40_M", 14], // M40 Recoilless Rifle
    ["acm_o_alci_turret_tow_M", 14], // TOW Launcher
    ["acm_o_alci_turret_ZPU4_m", 14], // ZPU-4 (AA)
    ["acm_o_alci_turret_l60mk3_M", 16], // Bofors L/60 Mk3 (AA)
    ["acm_o_alci_turret_l70mk2_M", 20], // Bofors L/70 Mk2 (AA)
    ["acm_o_alci_turret_sa2_M", 40], // SA-2 (SAM)

    // Artillery
    ["acm_o_alci_turret_m101_arty_M", 30], // M101 Howitzer
    ["acm_o_alci_turret_h12_m", 30], // H-12 MRL

    // --- GM Vehicles submod (acm_saintanselm_gmvehicles) ---

    // Trucks
    ["acm_o_alci_vehicle_ural_cargo_M", 4], // Ural (Cargo)
    ["acm_o_alci_vehicle_ural_refuel_M", 8], // Ural (Fuel)
    ["acm_o_alci_vehicle_ural_repair_M", 9], // Ural (Repair)
    ["acm_o_alci_vehicle_ural_ammo_M", 10], // Ural (Ammo)

    // APCs
    ["acm_o_alci_vehicle_fuchs_command_M", 14], // Fuchs (Command)
    ["acm_o_alci_vehicle_fuchs_reconnaissance_M", 14], // Fuchs (Recon)
    ["acm_o_alci_vehicle_fuchs_engineer_M", 14], // Fuchs (Engineer)
    ["acm_o_alci_vehicle_luchsa1_M", 18], // Luchs A1
    ["acm_o_alci_vehicle_marder_M", 28], // Marder

    // Artillery
    ["acm_o_alci_vehicle_2s1_M", 45], // 2S1 Gvozdika
    ["acm_o_alci_vehicle_ural_MLRS_M", 50] // Ural (MLRS)
];
