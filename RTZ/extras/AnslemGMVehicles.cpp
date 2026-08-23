////////////////////////////////////////////////////////////////////
//DeRap: config.bin
//Produced from mikero's Dos Tools Dll version 9.98
//https://mikero.bytex.digital/Downloads
//'now' is Sat Aug 22 20:31:14 2026 : 'file' last modified on Wed Aug 17 11:07:03 2022
////////////////////////////////////////////////////////////////////

#define _ARMA_

class CfgPatches
{
	class ACM_SaintAnselm_Submod_GMVehicles
	{
		name = "ProjectAnselm Optional GM Vehicles";
		author = "Anthrax";
		url = "https://discord.gg/ptrCdbAj2B";
		units[] = {"acm_o_alci_vehicle_fuchs_command","acm_o_alci_vehicle_fuchs_reconnaissance","acm_o_alci_vehicle_fuchs_engineer","acm_o_alci_vehicle_ural_cargo","acm_o_alci_vehicle_ural_repair","acm_o_alci_vehicle_ural_refuel","acm_o_alci_vehicle_ural_ammo","acm_o_alci_vehicle_2s1_M","acm_o_alci_vehicle_fuchs_command_M","acm_o_alci_vehicle_fuchs_reconnaissance_M","acm_o_alci_vehicle_fuchs_engineer_M","acm_o_alci_vehicle_luchsa1_M","acm_o_alci_vehicle_marder_M","acm_o_alci_vehicle_ural_cargo_M","acm_o_alci_vehicle_ural_repair_M","acm_o_alci_vehicle_ural_refuel_M","acm_o_alci_vehicle_ural_ammo_M","acm_o_alci_vehicle_ural_MLRS_M","acm_b_sac_vehicle_m113","acm_b_sac_vehicle_m113_engineer","acm_b_sac_vehicle_m113_command","acm_b_sac_vehicle_u1300_flatbed","acm_b_sac_vehicle_u1300_repair","acm_b_sac_vehicle_u1300_cargo","acm_b_sac_vehicle_kat452_container_M","acm_b_sac_vehicle_kat451_cargo_M","acm_b_sac_vehicle_kat451_ammo_M","acm_b_sac_vehicle_kat454_ammo_M","acm_b_sac_vehicle_kat463_mlrs_M","acm_b_sac_vehicle_m109g_M","acm_b_sac_vehicle_m113_M","acm_b_sac_vehicle_m113_engineer_M","acm_b_sac_vehicle_m113_command_M","acm_b_sac_vehicle_m113a2dk_pnmk","acm_b_sac_vehicle_u1300_flatbed_M","acm_b_sac_vehicle_u1300_repair_M","acm_b_sac_vehicle_u1300_cargo_M","acm_b_sac_vehicle_kat451_refuel"};
		weapons[] = {};
		requiredVersion = 0.1;
		requiredAddons[] = {"A3_Characters_F","cba_xeh","A3_Data_F","armor_f_vietnam_c","gm_core_vehicles","ACM_SaintAnselm"};
	};
};
class CfgGroups
{
	class EAST
	{
		class ACM_O_ATIU
		{
			name = "Alcillian Territorial Integrity Units";
			class Motorized
			{
				name = "Motorized";
				class o_acmoatiu_motorized_motorized_reinforcements
				{
					name = "Motorized Reinforcements";
					side = 0;
					faction = "ACM_O_ATIU";
					icon = "\A3\ui_f\data\map\markers\nato\o_motor_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "acm_o_alci_vehicle_ural_cargo";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_SL";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_rifleman_3";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_MG";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_Medic";
					};
					class Unit5
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_Marksman";
					};
					class Unit6
					{
						position[] = {-15,-15,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_grenadier";
					};
					class Unit7
					{
						position[] = {20,-20,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_KneeMortar";
					};
					class Unit8
					{
						position[] = {-20,-20,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_rifleman_AT";
					};
					class Unit9
					{
						position[] = {25,-25,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_RTO2";
					};
					class Unit10
					{
						position[] = {-25,-25,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_Medic";
					};
					class Unit11
					{
						position[] = {30,-30,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_Demo";
					};
					class Unit12
					{
						position[] = {-30,-30,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_rifleman";
					};
					class Unit13
					{
						position[] = {35,-35,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_MG";
					};
					class Unit14
					{
						position[] = {-35,-35,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_Trench";
					};
				};
				class o_acmoatiu_motorized_m151_armoured_section
				{
					name = "M151 Armoured Section";
					side = 0;
					faction = "ACM_O_ATIU";
					icon = "\A3\ui_f\data\map\markers\nato\o_motor_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "acm_o_alci_vehicle_m151_Armoured";
					};
					class Unit1
					{
						position[] = {5,-7,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "acm_o_alci_vehicle_m151_Armoured";
					};
				};
			};
			class Mechanized
			{
				name = "Mechanized Infantry";
			};
		};
		class ACM_O_ATIU_2035
		{
			name = "Alcillian Territorial Integrity Units (2035)";
			class Motorized
			{
				name = "Motorized Infantry";
				class o_acmoatiu2035_motorized_motorized_reinforcements
				{
					name = "Motorized Reinforcements";
					side = 0;
					faction = "ACM_O_ATIU_2035";
					icon = "\A3\ui_f\data\map\markers\nato\o_motor_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "acm_o_alci_vehicle_ural_cargo_M";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_SL";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_grenadier";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_rifleman";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_RTO";
					};
					class Unit5
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_Medic";
					};
					class Unit6
					{
						position[] = {-15,-15,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_MG";
					};
					class Unit7
					{
						position[] = {20,-20,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_marksman";
					};
					class Unit8
					{
						position[] = {-20,-20,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_rifleman_3";
					};
					class Unit9
					{
						position[] = {25,-25,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_Sapper";
					};
					class Unit10
					{
						position[] = {-25,-25,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_rifleman_AT";
					};
					class Unit11
					{
						position[] = {30,-30,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_rifleman";
					};
					class Unit12
					{
						position[] = {-30,-30,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_rifleman_4";
					};
					class Unit13
					{
						position[] = {35,-35,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_AT";
					};
					class Unit14
					{
						position[] = {-35,-35,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_Medic";
					};
				};
			};
			class Mechanized
			{
				name = "Mechanized Infantry";
				class o_acmoatiu2035_mechanized_mechanized_reinforcements
				{
					name = "Mechanized Reinforcements";
					side = 0;
					faction = "ACM_O_ATIU_2035";
					icon = "\A3\ui_f\data\map\markers\nato\o_mech_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "acm_o_alci_vehicle_fuchs_reconnaissance_M";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_SL";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_rifleman_AT";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_grenadier";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_marksman";
					};
					class Unit5
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_RTO";
					};
					class Unit6
					{
						position[] = {-15,-15,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_MG";
					};
					class Unit7
					{
						position[] = {20,-20,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_Medic";
					};
				};
				class o_acmoatiu2035_mechanized_mobile_hq
				{
					name = "Mobile HQ";
					side = 0;
					faction = "ACM_O_ATIU_2035";
					icon = "\A3\ui_f\data\map\markers\nato\o_mech_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "acm_o_alci_vehicle_fuchs_command_M";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_Officer";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_UAV";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_Officer";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_RTO";
					};
				};
				class o_acmoatiu2035_mechanized_marder_assault_group
				{
					name = "Marder Assault Group";
					side = 0;
					faction = "ACM_O_ATIU_2035";
					icon = "\A3\ui_f\data\map\markers\nato\o_mech_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "acm_o_alci_vehicle_marder_M";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_SL";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_rifleman";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_AT";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_Medic";
					};
					class Unit5
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_RTO";
					};
					class Unit6
					{
						position[] = {-15,-15,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_grenadier";
					};
					class Unit7
					{
						position[] = {20,-20,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_MG";
					};
				};
			};
			class Artillery
			{
				name = "Artillery";
				class o_acmoatiu2035_artillery_artillery_section
				{
					name = "Artillery Section";
					side = 0;
					faction = "ACM_O_ATIU_2035";
					icon = "\A3\ui_f\data\map\markers\nato\o_art.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "acm_o_alci_vehicle_2s1_M";
					};
					class Unit1
					{
						position[] = {7,-11,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "acm_o_alci_vehicle_2s1_M";
					};
				};
				class o_acmoatiu2035_artillery_mlrs_section
				{
					name = "MLRS Section";
					side = 0;
					faction = "ACM_O_ATIU_2035";
					icon = "\A3\ui_f\data\map\markers\nato\o_art.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "acm_o_alci_vehicle_ural_MLRS_M";
					};
					class Unit1
					{
						position[] = {5,-13,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "acm_o_alci_vehicle_ural_MLRS_M";
					};
				};
			};
		};
	};
	class WEST
	{
		class ACM_B_SAC
		{
			name = "Saint Anselm Constabulary";
			class Motorized
			{
				name = "Motorized";
				class b_acmbsac_motorized_motorized_reinforrcements
				{
					name = "Motorized Reinforrcements";
					side = 1;
					faction = "ACM_B_SAC";
					icon = "\A3\ui_f\data\map\markers\nato\b_motor_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "acm_b_sac_vehicle_u1300_cargo";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_SL";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_rifleman_AT";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_HMG";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_RTO2";
					};
					class Unit5
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_rifleman";
					};
					class Unit6
					{
						position[] = {-15,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_grenadier";
					};
					class Unit7
					{
						position[] = {20,-20,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_Marksman";
					};
					class Unit8
					{
						position[] = {-20,-20,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_rifleman_3";
					};
				};
			};
			class Mechanized
			{
				name = "Mechanized Infantry";
				class b_acmbsac_mechanized_mechanized_reinforcements
				{
					name = "Mechanized Reinforcements";
					side = 1;
					faction = "ACM_B_SAC";
					icon = "\A3\ui_f\data\map\markers\nato\b_mech_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "acm_b_sac_vehicle_m113";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_SL";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_rifleman";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_MG";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_RTO";
					};
					class Unit5
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_Medic";
					};
					class Unit6
					{
						position[] = {-15,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_HMG";
					};
					class Unit7
					{
						position[] = {20,-20,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_grenadier";
					};
					class Unit8
					{
						position[] = {-20,-20,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_rifleman_AT";
					};
					class Unit9
					{
						position[] = {25,-25,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_rifleman_2";
					};
					class Unit10
					{
						position[] = {-25,-25,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_Marksman";
					};
				};
				class b_acmbsac_mechanized_mechanized_assault
				{
					name = "Mechanized Assault";
					side = 1;
					faction = "ACM_B_SAC";
					icon = "\A3\ui_f\data\map\markers\nato\b_mech_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "acm_b_sog_sac_vehicle_m113_ACAV";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_SL";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_rifleman_AT";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_rifleman_3";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_rifleman";
					};
					class Unit5
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_MG";
					};
					class Unit6
					{
						position[] = {-15,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_RTO";
					};
					class Unit7
					{
						position[] = {20,-20,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_Marksman";
					};
					class Unit8
					{
						position[] = {-20,-20,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_Medic";
					};
					class Unit9
					{
						position[] = {25,-25,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_HMG";
					};
					class Unit10
					{
						position[] = {-25,-25,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_grenadier";
					};
				};
			};
		};
		class ACM_B_SAC_2035
		{
			name = "Saint Anselm Constabulary (2035)";
			class Motorized
			{
				name = "Motorized Infantry";
				class b_acmbsac2035_motorized_motorized_reinforcements
				{
					name = "Motorized Reinforcements";
					side = 1;
					faction = "ACM_B_SAC_2035";
					icon = "\A3\ui_f\data\map\markers\nato\b_motor_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "acm_b_sac_vehicle_kat451_cargo_M";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_SL";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_rifleman_AT";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_GR";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_MR";
					};
					class Unit5
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_Medic";
					};
					class Unit6
					{
						position[] = {-15,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_RTO";
					};
					class Unit7
					{
						position[] = {20,-20,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_HAT";
					};
					class Unit8
					{
						position[] = {-20,-20,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_rifleman_3";
					};
					class Unit9
					{
						position[] = {25,-25,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_rifleman";
					};
					class Unit10
					{
						position[] = {-25,-25,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_Medic";
					};
					class Unit11
					{
						position[] = {30,-30,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_rifleman_AT";
					};
					class Unit12
					{
						position[] = {-30,-30,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_Medic";
					};
					class Unit13
					{
						position[] = {35,-35,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_Demo";
					};
					class Unit14
					{
						position[] = {-35,-35,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_AR";
					};
				};
				class b_acmbsac2035_motorized_citizen_sreserve_party_bus
				{
					name = "Citizen's Reserve Party Bus";
					side = 1;
					faction = "ACM_B_SAC_2035";
					icon = "\A3\ui_f\data\map\markers\nato\b_motor_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "acm_b_sac_vehicle_u1300_cargo_M";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_CR_TL";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_CR_CLS";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_CR_RTO";
					};
					class Unit4
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_CR_Rifleman";
					};
					class Unit5
					{
						position[] = {-15,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_CR_Rifleman_AT";
					};
					class Unit6
					{
						position[] = {20,-20,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_CR_Rifleman_AK";
					};
					class Unit7
					{
						position[] = {-20,-20,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_CR_Rifleman_FN49";
					};
					class Unit8
					{
						position[] = {-25,-25,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_CR_Rifleman_Garand";
					};
				};
			};
			class Mechanized
			{
				name = "Mechanized Infantry";
				class b_acmbsac2035_mechanized_mechanized_reinforcements
				{
					name = "Mechanized Reinforcements";
					side = 1;
					faction = "ACM_B_SAC_2035";
					icon = "\A3\ui_f\data\map\markers\nato\b_mech_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "acm_b_sac_vehicle_m113_M";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_SL";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_rifleman_2";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_MR";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_GR";
					};
					class Unit5
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_AR";
					};
					class Unit6
					{
						position[] = {-15,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_Medic";
					};
					class Unit7
					{
						position[] = {20,-20,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_RTO2";
					};
					class Unit8
					{
						position[] = {-20,-20,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_rifleman_AT";
					};
				};
				class b_acmbsac2035_mechanized_assault_group_fire_support
				{
					name = "Assault Group (Fire Support)";
					side = 1;
					faction = "ACM_B_SAC_2035";
					icon = "\A3\ui_f\data\map\markers\nato\b_mech_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "acm_b_sac_vehicle_m113a2dk_pnmk";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_SL";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_rifleman";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_MR";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_GR";
					};
					class Unit5
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_AR";
					};
					class Unit6
					{
						position[] = {-15,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_Medic";
					};
					class Unit7
					{
						position[] = {20,-20,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_RTO";
					};
					class Unit8
					{
						position[] = {-20,-20,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_rifleman_AT";
					};
				};
			};
			class Artillery
			{
				name = "Artillery";
				class b_acmbsac2035_artillery_artillery_section
				{
					name = "Artillery Section";
					side = 1;
					faction = "ACM_B_SAC_2035";
					icon = "\A3\ui_f\data\map\markers\nato\b_art.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "acm_b_sac_vehicle_m109g_M";
					};
					class Unit1
					{
						position[] = {7,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "acm_b_sac_vehicle_m109g_M";
					};
				};
				class b_acmbsac2035_artillery_mlrs_section
				{
					name = "MLRS Section";
					side = 1;
					faction = "ACM_B_SAC_2035";
					icon = "\A3\ui_f\data\map\markers\nato\b_art.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "acm_b_sac_vehicle_kat463_mlrs_M";
					};
					class Unit1
					{
						position[] = {6,-14,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "acm_b_sac_vehicle_kat463_mlrs_M";
					};
				};
			};
		};
	};
};
class cfgMods
{
	author = "Anthrax";
	timepacked = "1660777622";
};
