// Marines and Navy (Aegis), desert and woodland line-ups. They crew the task
// force in mjtf.inc.sqf.
_costs append [

    // Men
    ["EF_B_Marine_Unarmed_Des", 0.2], // Rifleman (Unarmed)
    ["EF_B_Marine_Unarmed_Wdl", 0.2], // Rifleman (Unarmed)
    ["EF_B_Marine_Crew_Des", 0.5], // Crewman
    ["EF_B_Marine_Crew_Wdl", 0.5], // Crewman
    ["EF_B_Marine_BoatCrew_Des", 0.5], // Boat Crewman
    ["EF_B_Marine_BoatCrew_Wdl", 0.5], // Boat Crewman
    ["EF_B_Navy_Sailor", 0.5], // Sailor
    ["EF_B_Navy_FlightDeckCrew", 0.5], // Flight Deck Crewman
    ["EF_B_Navy_WellDeckCrew", 0.5], // Well Deck Crewman
    ["EF_B_Marine_Light_Des", 0.8], // Rifleman (Light)
    ["EF_B_Marine_Light_Wdl", 0.8], // Rifleman (Light)
    ["EF_B_Marine_R_Des", 1], // Rifleman
    ["EF_B_Marine_R_Wdl", 1], // Rifleman
    ["EF_B_Marine_Medic_Des", 1], // Combat Life Saver
    ["EF_B_Marine_Medic_Wdl", 1], // Combat Life Saver
    ["EF_B_Marine_AAT_Des", 1], // Asst. Missile Specialist (AT)
    ["EF_B_Marine_AAT_Wdl", 1], // Asst. Missile Specialist (AT)
    ["EF_B_Marine_AAA_Des", 1], // Asst. Missile Specialist (AA)
    ["EF_B_Marine_AAA_Wdl", 1], // Asst. Missile Specialist (AA)
    ["EF_B_Marine_AB_Des", 1.1], // Ammo Bearer
    ["EF_B_Marine_AB_Wdl", 1.1], // Ammo Bearer
    ["EF_B_Marine_Mark_Des", 1.1], // Marksman
    ["EF_B_Marine_Mark_Wdl", 1.1], // Marksman
    ["EF_B_Marine_TL_Des", 1.2], // Team Leader
    ["EF_B_Marine_TL_Wdl", 1.2], // Team Leader
    ["EF_B_Marine_SL_Des", 1.2], // Squad Leader
    ["EF_B_Marine_SL_Wdl", 1.2], // Squad Leader
    ["EF_B_Marine_AR_Des", 1.3], // Autorifleman
    ["EF_B_Marine_AR_Wdl", 1.3], // Autorifleman
    ["EF_B_Marine_GL_Des", 1.5], // Grenadier
    ["EF_B_Marine_GL_Wdl", 1.5], // Grenadier
    ["EF_B_Marine_Repair_Des", 1.5], // Repair Specialist
    ["EF_B_Marine_Repair_Wdl", 1.5], // Repair Specialist
    ["EF_B_Marine_JTAC_Des", 2.2], // JTAC
    ["EF_B_Marine_JTAC_Wdl", 2.2], // JTAC
    ["EF_B_Marine_LAT2_Des", 2.5], // Rifleman (Light AT)
    ["EF_B_Marine_LAT2_Wdl", 2.5], // Rifleman (Light AT)
    ["EF_B_Marine_LAT_Des", 3], // Rifleman (AT)
    ["EF_B_Marine_LAT_Wdl", 3], // Rifleman (AT)
    ["EF_B_Marine_Exp_Des", 3], // Explosive Specialist
    ["EF_B_Marine_Exp_Wdl", 3], // Explosive Specialist
    ["EF_B_Marine_AMG_Des", 3], // Asst. Gunner (HMG/GMG)
    ["EF_B_Marine_AMG_Wdl", 3], // Asst. Gunner (HMG/GMG)
    ["EF_B_Marine_AMort_Des", 3], // Asst. Gunner (Mk6)
    ["EF_B_Marine_AMort_Wdl", 3], // Asst. Gunner (Mk6)
    ["EF_B_Marine_Eng_Des", 4], // Engineer
    ["EF_B_Marine_Eng_Wdl", 4], // Engineer
    ["EF_B_Marine_UAV_Des", 4], // UAV Operator
    ["EF_B_Marine_UAV_Wdl", 4], // UAV Operator
    ["EF_B_Marine_HMG_Des", 5], // Gunner (HMG)
    ["EF_B_Marine_HMG_Wdl", 5], // Gunner (HMG)
    ["EF_B_Marine_Mort_Des", 7], // Gunner (Mk6)
    ["EF_B_Marine_Mort_Wdl", 7], // Gunner (Mk6)
    ["EF_B_Marine_GMG_Des", 9], // Gunner (GMG)
    ["EF_B_Marine_GMG_Wdl", 9], // Gunner (GMG)
    ["EF_B_Marine_AT_Des", 10], // Missile Specialist (AT)
    ["EF_B_Marine_AT_Wdl", 10], // Missile Specialist (AT)
    ["EF_B_Marine_AA_Des", 12], // Missile Specialist (AA)
    ["EF_B_Marine_AA_Wdl", 12], // Missile Specialist (AA)
    ["EF_B_Marine_Officer_Des", 20], // Officer
    ["EF_B_Marine_Officer_Wdl", 20], // Officer

    // Men (Special Forces)
    ["EF_B_Marine_Recon_Des", 2], // Recon Scout
    ["EF_B_Marine_Recon_Wdl", 2], // Recon Scout
    ["EF_B_Marine_Recon_Medic_Des", 2], // Recon Paramedic
    ["EF_B_Marine_Recon_Medic_Wdl", 2], // Recon Paramedic
    ["EF_B_Marine_Recon_M_Des", 2.1], // Recon Marksman
    ["EF_B_Marine_Recon_M_Wdl", 2.1], // Recon Marksman
    ["EF_B_Marine_Recon_TL_Des", 2.2], // Recon Team Leader
    ["EF_B_Marine_Recon_TL_Wdl", 2.2], // Recon Team Leader
    ["EF_B_Marine_Recon_JTAC_Des", 2.2], // Recon JTAC
    ["EF_B_Marine_Recon_JTAC_Wdl", 2.2], // Recon JTAC
    ["EF_B_Marine_Recon_LAT_Des", 4], // Recon Scout (AT)
    ["EF_B_Marine_Recon_LAT_Wdl", 4], // Recon Scout (AT)
    ["EF_B_Marine_Recon_Exp_Des", 4], // Recon Demo Specialist
    ["EF_B_Marine_Recon_Exp_Wdl", 4], // Recon Demo Specialist
    ["EF_B_Marine_Diver_Des", 2], // Assault Diver
    ["EF_B_Marine_Diver_Wdl", 2], // Assault Diver
    ["EF_B_Marine_Diver_Scout_Des", 2], // Combat Diver Scout
    ["EF_B_Marine_Diver_Scout_Wdl", 2], // Combat Diver Scout
    ["EF_B_Marine_Diver_TL_Des", 2.2], // Combat Diver Team Leader
    ["EF_B_Marine_Diver_TL_Wdl", 2.2], // Combat Diver Team Leader
    ["EF_B_Marine_Diver_Pointman_Des", 2.3], // Combat Diver Pointman
    ["EF_B_Marine_Diver_Pointman_Wdl", 2.3], // Combat Diver Pointman
    ["EF_B_Marine_Diver_Eng_Des", 4], // Combat Diver Engineer
    ["EF_B_Marine_Diver_Eng_Wdl", 4] // Combat Diver Engineer
];
