// Saint Anselm Constabulary (ACM_B_SAC), the Cold War line-up of Project
// Anselm's BLUFOR force. Its 2035 counterpart lives in sac2035.inc.sqf.
_costs append [

    // Men
    ["ACM_b_sam_men_survivor", 0], // Survivor
    ["ACM_b_sam_men_unarmed", 0.2], // Rifleman (Unarmed)
    ["ACM_b_sam_men_Crew", 0.5], // Crew
    ["ACM_b_sam_men_Pilot", 0.5], // Rotary-Wing Pilot
    ["ACM_b_sam_men_rifleman", 1], // Rifleman
    ["ACM_b_sam_men_rifleman_2", 1], // Rifleman 2
    ["ACM_b_sam_men_rifleman_3", 1], // Rifleman 3
    ["ACM_b_sam_men_Trench", 1], // Trench Fighter
    ["ACM_b_sam_men_cg1", 1], // Coast Guard 1
    ["ACM_b_sam_men_cg2", 1], // Coast Guard 2
    ["ACM_b_sam_men_gunner", 1], // Gunner 1
    ["ACM_b_sam_men_gunner2", 1], // Gunner 2
    ["ACM_b_sam_men_Medic", 1], // Medic
    ["ACM_b_sam_men_ParadeDress", 1], // Constable (Parade Dress)
    ["ACM_b_sam_men_ParadeDress_Vet", 1], // Constable (Parade Dress, Veteran)
    ["ACM_b_sam_men_RTO", 1.2], // RTO
    ["ACM_b_sam_men_RTO2", 1.2], // RTO 2
    ["ACM_b_sam_men_MG", 1.3], // Machinegunner
    ["ACM_b_sam_men_Marksman", 1.1], // Marksman
    ["ACM_b_sam_men_SL", 1.2], // Sergeant
    ["ACM_b_sam_men_HMG", 1.5], // Heavy Machinegunner
    ["ACM_b_sam_men_grenadier", 1.5], // Grenadier
    ["ACM_b_sam_men_Demo", 3], // Demolitions
    ["ACM_b_sam_men_rifleman_AT", 3], // Rifleman (AT)
    ["ACM_b_sam_men_officer", 20], // Superintendent

    // Men (Police)
    ["ACM_b_sam_men_police_constable", 0.8], // Constable
    ["ACM_b_sam_men_police_constable_armor", 1], // Constable (Armor)
    ["ACM_b_sam_men_police_riot_shotgunner", 1], // Riot Shotgunner
    ["ACM_b_sam_men_police_riot_SubMachine1", 1], // Riot SubmachineGunner 1
    ["ACM_b_sam_men_police_riot_SubMachine2", 1], // Riot SubmachineGunner 2
    ["ACM_b_sam_men_police_riot_Marksman", 1.1], // Riot Marksman
    ["ACM_b_sam_men_police_riot_Grenadier", 1.5], // Riot Gas Controller
    ["ACM_b_sam_men_police_riot_ArmedResponse", 1.5], // Riot Armed Response

    // Men (Special Forces)
    ["ACM_b_sam_men_SF_scout", 2], // Recon Scout
    ["ACM_b_sam_men_SF_scout_2", 2], // Recon Scout (L1A1)
    ["ACM_b_sam_men_SF_Medic", 2], // Recon CLS
    ["ACM_b_sam_men_SF_Night", 2.2], // Recon Night Fighter
    ["ACM_b_sam_men_SF_TL", 2.3], // Recon Team Lead
    ["ACM_b_sam_men_SF_Autorifleman", 2.5], // Recon Autorifleman
    ["ACM_b_sam_men_SF_Grenadier", 3], // Recon Grenadier
    ["ACM_b_sam_men_SF_Demo", 4], // Recon Demolitions

    // Boats
    ["acm_b_sac_boat1", 15], // Patrol Boat
    ["acm_b_sac_boat2", 30], // Patrol Boat (Heavy)

    // Cars
    ["acm_b_sac_vehicle_m151", 3], // M151
    ["acm_b_sac_vehicle_m151_mg", 8], // M151 (MG)
    ["acm_b_sac_vehicle_m151_mg_patrol", 9], // M151 (MG, Patrol)
    ["acm_b_sac_vehicle_m151_Armoured", 8], // M151 (Armored)
    ["acm_b_sac_vehicle_m151_M40", 13], // M151 (M40 Recoilless)
    ["acm_b_sac_vehicle_m151_TOW", 15], // M151 (TOW)
    ["acm_b_sac_vehicle_u1300_flatbed", 3.5], // U1300L (Flatbed)
    ["acm_b_sac_vehicle_u1300_cargo", 3.5], // U1300L (Cargo)
    ["acm_b_sac_vehicle_u1300_repair", 8], // U1300L (Repair)
    ["acm_b_sac_vehicle_m54_transport", 4], // M54 (Transport)
    ["acm_b_sac_vehicle_m54_transport_Cover", 4], // M54 (Covered)
    ["acm_b_sac_vehicle_m54_fuel", 8], // M54 (Fuel)
    ["acm_b_sac_vehicle_m54_repair", 9], // M54 (Repair)
    ["acm_b_sac_vehicle_m54_ammo", 10], // M54 (Ammo)
    ["acm_b_sac_vehicle_m54_battleBus", 13], // M54 (MG)
    ["acm_b_sac_vehicle_m54_AA", 15], // M54 (AA)

    // APCs
    ["acm_b_sog_sac_vehicle_m113", 15], // M113
    ["acm_b_sog_sac_vehicle_m113_ACAV", 18], // M113 (ACAV)
    ["acm_b_sog_sac_vehicle_m113_M40", 20], // M113 (Recoilless)
    ["acm_b_sac_vehicle_m113", 15], // M113
    ["acm_b_sac_vehicle_m113_engineer", 16], // M113 (Engineer)
    ["acm_b_sac_vehicle_m113_command", 16], // M113 (Command)

    // Helicopters
    ["acm_b_sac_vehicle_ch34", 20], // CH-34
    ["acm_b_sac_vehicle_ch34_CAS", 25], // CH-34 (CAS)

    // Turrets
    ["acm_b_sac_turret_m2_low", 6], // M2 HMG
    ["acm_b_sac_turret_m2_high", 6], // M2 HMG (Raised)
    ["acm_b_sac_turret_mortar", 8], // M2 Mortar
    ["acm_b_sac_turret_m101_AT", 20], // M101 Howitzer (Direct Fire)
    ["acm_b_sac_turret_m45", 12], // M45 Quadmount (AA)
    ["acm_b_sac_turret_m40", 10], // M40 Recoilless Rifle
    ["acm_b_sac_turret_tow", 12], // TOW Launcher
    ["acm_b_sac_turret_l60mk3", 16], // Bofors L/60 Mk3 (AA)
    ["acm_b_sac_turret_l70mk2", 18], // Bofors L/70 Mk2 (AA)

    // Artillery
    ["acm_b_sac_turret_m101_arty", 25] // M101 Howitzer
];
