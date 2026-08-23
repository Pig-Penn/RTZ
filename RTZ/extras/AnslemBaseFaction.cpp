////////////////////////////////////////////////////////////////////
//DeRap: faction\config.bin
//Produced from mikero's Dos Tools Dll version 9.98
//https://mikero.bytex.digital/Downloads
//'now' is Sat Aug 22 20:29:54 2026 : 'file' last modified on Tue Jul 18 13:58:05 2023
////////////////////////////////////////////////////////////////////

#define _ARMA_

class CfgPatches
{
	class ACM_SaintAnselm
	{
		name = "ProjectAnselm";
		author = "Anthrax";
		url = "https://discord.gg/ptrCdbAj2B";
		units[] = {"ACM_o_alci_men_rifleman","ACM_o_alci_men_rifleman_2","ACM_o_alci_men_rifleman_3","ACM_o_alci_men_rifleman_AT","ACM_o_alci_men_SL","ACM_o_alci_men_RTO","ACM_o_alci_men_RTO2","ACM_o_alci_men_MG","ACM_o_alci_men_Medic","ACM_o_alci_men_Marksman","ACM_o_alci_men_Demo","ACM_o_alci_men_Gunner","ACM_o_alci_men_Gunner2","ACM_o_alci_men_Trench","ACM_o_alci_men_cg","ACM_o_alci_men_cg2","ACM_o_alci_men_grenadier","ACM_o_alci_men_crew","ACM_o_alci_men_officer","ACM_o_alci_men_Pilot","ACM_o_alci_men_unarmed","ACM_o_alci_men_survivor","ACM_o_alci_men_SF_Scout","ACM_o_alci_men_SF_TL","ACM_o_alci_men_SF_NF","ACM_o_alci_men_SF_AR","ACM_o_alci_men_SF_CLS","ACM_o_alci_men_SF_GR","ACM_o_alci_men_SF_Demo","ACM_o_alci_men_SF_MR","ACM_o_alci_men_KneeMortar","acm_o_alci_vehicle_m151","acm_o_alci_vehicle_m151_mg","acm_o_alci_vehicle_m151_TOW","acm_o_alci_vehicle_uh1c_gunship","acm_o_alci_vehicle_uh1c_slick","acm_o_alci_boat1","acm_o_alci_turret_l70mk2","acm_o_alci_turret_l60mk3","acm_o_alci_turret_mortar","acm_o_alci_turret_tow","acm_o_alci_turret_m101_AT","acm_o_alci_turret_m101_arty","acm_o_alci_turret_m2_high","acm_o_alci_turret_m2_low","ACM_b_sam_men_rifleman","ACM_b_sam_men_rifleman_2","ACM_b_sam_men_rifleman_3","ACM_b_sam_men_rifleman_AT","ACM_b_sam_men_SL","ACM_b_sam_men_MG","ACM_b_sam_men_RTO","ACM_b_sam_men_RTO2","ACM_b_sam_men_Marksman","ACM_b_sam_men_Medic","ACM_b_sam_men_HMG","ACM_b_sam_men_Trench","ACM_b_sam_men_Demo","ACM_b_sam_men_cg1","ACM_b_sam_men_cg2","ACM_b_sam_men_gunner","ACM_b_sam_men_gunner2","ACM_b_sam_men_grenadier","ACM_b_sam_men_unarmed","ACM_b_sam_men_survivor","ACM_b_sam_men_officer","ACM_b_sam_men_Pilot","ACM_b_sam_men_Crew","ACM_b_sam_men_police_constable","ACM_b_sam_men_police_constable_armor","ACM_b_sam_men_police_riot_shotgunner","ACM_b_sam_men_police_riot_SubMachine1","ACM_b_sam_men_police_riot_SubMachine2","ACM_b_sam_men_police_riot_Marksman","ACM_b_sam_men_police_riot_Grenadier","ACM_b_sam_men_police_riot_ArmedResponse","ACM_b_sam_men_SF_scout","ACM_b_sam_men_SF_Night","ACM_b_sam_men_SF_TL","ACM_b_sam_men_SF_Medic","ACM_b_sam_men_SF_Autorifleman","ACM_b_sam_men_SF_Demo","ACM_b_sam_men_SF_Grenadier","acm_b_sac_vehicle_m151","acm_b_sac_vehicle_m151_mg","acm_b_sac_vehicle_m151_TOW","acm_b_sac_vehicle_m151_mg_patrol","acm_b_sac_vehicle_ch34","acm_b_sac_vehicle_ch34_CAS","acm_b_sac_boat1","acm_b_sac_turret_l70mk2","acm_b_sac_turret_l60mk3","acm_b_sac_turret_mortar","acm_b_sac_turret_tow","acm_b_sac_turret_m101_AT","acm_b_sac_turret_m101_arty","acm_b_sac_turret_m2_high","acm_b_sac_turret_m2_high","ACM_o_alci_2035_men_rifleman","ACM_o_alci_2035_men_rifleman_2","ACM_o_alci_2035_men_rifleman_3","ACM_o_alci_2035_men_rifleman_4","ACM_o_alci_2035_men_rifleman_light","ACM_o_alci_2035_men_rifleman_AT","ACM_o_alci_2035_men_SL","ACM_o_alci_2035_men_grenadier","ACM_o_alci_2035_men_marksman","ACM_o_alci_2035_men_AT","ACM_o_alci_2035_men_MG","ACM_o_alci_2035_men_Sapper","ACM_o_alci_2035_men_RTO","ACM_o_alci_2035_men_Medic","ACM_o_alci_2035_men_Crewman","ACM_o_alci_2035_men_Gunner","ACM_o_alci_2035_men_AA","ACM_o_alci_2035_men_Officer","ACM_o_alci_2035_men_UAV","ACM_o_alci_2035_men_unarmed","ACM_o_alci_2035_men_survivor","ACM_o_alci_2035_SF_Scout","ACM_o_alci_2035_SF_Scout_AT","ACM_o_alci_2035_SF_Grenadier","ACM_o_alci_2035_SF_SL","ACM_o_alci_2035_SF_MR","ACM_o_alci_2035_SF_AR","ACM_o_alci_2035_SF_Demo","ACM_o_alci_2035_SF_CLS","acm_o_alci_vehicle_m151_M","acm_o_alci_vehicle_m151_mg_M","acm_o_alci_vehicle_m151_TOW_M","acm_o_alci_turret_l70mk2_M","acm_o_alci_turret_l60mk3_M","acm_o_alci_turret_mortar_M","acm_o_alci_turret_tow_M","acm_o_alci_turret_m101_AT_M","acm_o_alci_turret_m101_arty_M","acm_o_alci_turret_m2_high_M","acm_o_alci_turret_m2_low_M","acm_o_alci_vehicle_type63_m","acm_o_alci_vehicle_PO30","acm_o_alci_vehicle_PO30_armed","ACM_b_sam_2035_men_rifleman","ACM_b_sam_2035_men_rifleman_2","ACM_b_sam_2035_men_rifleman_3","ACM_b_sam_2035_men_rifleman_light","ACM_b_sam_2035_men_rifleman_AT","ACM_b_sam_2035_men_SL","ACM_b_sam_2035_men_MR","ACM_b_sam_2035_men_GR","ACM_b_sam_2035_men_EOD","ACM_b_sam_2035_men_AR","ACM_b_sam_2035_men_Crew","ACM_b_sam_2035_men_Medic","ACM_b_sam_2035_men_RTO","ACM_b_sam_2035_men_RTO2","ACM_b_sam_2035_men_HAT","ACM_b_sam_2035_men_Demo","ACM_b_sam_2035_men_UAV","ACM_b_sam_2035_men_UGV","ACM_b_sam_2035_men_AA","ACM_b_sam_2035_men_gunner","ACM_b_sam_2035_men_gunner2","ACM_b_sam_2035_men_officer","ACM_b_sam_2035_men_unarmed","ACM_b_sam_2035_men_survivor","ACM_b_sam_2035_men_SF_Scout","ACM_b_sam_2035_men_SF_Scout_AT","ACM_b_sam_2035_men_SF_TL","ACM_b_sam_2035_men_SF_Grenadier","ACM_b_sam_2035_men_SF_Marksman","ACM_b_sam_2035_men_SF_Medic","ACM_b_sam_2035_men_SF_Demo","ACM_b_sam_2035_men_SF_Auto","ACM_b_sam_2035_men_CR_Rifleman","ACM_b_sam_2035_men_CR_Rifleman_AT","ACM_b_sam_2035_men_CR_Rifleman_Garand","ACM_b_sam_2035_men_CR_Rifleman_FN49","ACM_b_sam_2035_men_CR_Rifleman_AK","ACM_b_sam_2035_men_CR_Rifleman_SKS","ACM_b_sam_2035_men_CR_TL","ACM_b_sam_2035_men_CR_AR","ACM_b_sam_2035_men_CR_MR","ACM_b_sam_2035_men_CR_CLS","ACM_b_sam_2035_men_CR_RTO","ACM_b_sam_2035_men_CR_SUB","acm_b_sac_vehicle_m151_M","acm_b_sac_vehicle_m151_mg_M","acm_b_sac_vehicle_m151_TOW_M","acm_b_sac_vehicle_m151_mg_patrol_M","acm_b_sac_turret_l70mk2_M","acm_b_sac_turret_l60mk3_M","acm_b_sac_turret_mortar_M","acm_b_sac_turret_tow_M","acm_b_sac_turret_m101_AT_M","acm_b_sac_turret_m101_arty_M","acm_b_sac_turret_m2_high_M","acm_b_sac_turret_m2_low_M","acm_b_sac_vehicle_type63_m","acm_b_sac_vehicle_WY55","acm_b_sac_vehicle_WY55_Armed","acm_b_sac_vehicle_mora","ACM_b_sam_2035_men_JetPilot","ACM_b_sam_2035_men_JetPilot_Co","acm_b_sac_drone_uav","acm_b_sac_drone_UGV","acm_o_alci_drone_UAV","acm_b_sac_drone_improv_2035","acm_b_sac_boat1_M","acm_o_alci_boat1_M","acm_o_alci_turret_type56rr_M","acm_o_alci_turret_sa2_M","acm_o_alci_turret_rsna75_M","acm_b_sac_turret_zpu4_M","acm_b_sac_vehicle_Bike_CR","acm_b_sac_vehicle_Bike_Mule_CR","ACM_I_Shitpost_UBPR_PMMcKendrick","ACM_I_Shitpost_UBPR_FMJackson","ACM_I_Shitpost_UBPR_DMRadcliffe","acm_b_sac_vehicle_F4_MR","acm_b_sac_vehicle_F4_CAP","acm_b_sac_vehicle_F4_AT","acm_b_sac_vehicle_F4_SEAD","acm_o_alci_boat2","acm_o_alci_boat2_M","acm_b_sac_boat2","acm_b_sac_boat2_M","acm_b_sac_vehicle_m151_M40","acm_b_sac_vehicle_m151_M40_M","acm_o_alci_vehicle_m151_M40","acm_o_alci_vehicle_m151_M40_M","ACM_b_sam_men_SF_scout_2","acm_o_alci_vehicle_uh1c_gunship_M","acm_o_alci_vehicle_uh1c_slick_M","acm_b_sac_turret_m40","acm_b_sac_turret_m40_M","acm_o_alci_turret_m40","acm_o_alci_turret_m40_M","acm_b_sog_sac_vehicle_m113","acm_b_sog_sac_vehicle_m113_M","acm_o_sog_alc_vehicle_m113","acm_o_sog_alc_vehicle_m113_M","acm_b_sog_sac_vehicle_m113_ACAV","acm_b_sog_sac_vehicle_m113_ACAV_M","acm_o_sog_alc_vehicle_m113_ACAV","acm_o_sog_alc_vehicle_m113_ACAV_M","acm_b_sog_sac_vehicle_m113_M40","acm_b_sog_sac_vehicle_m113_M40_M","acm_o_alci_J6_Base","acm_o_alci_J6_PortStrike","acm_o_alci_J6_CAS","acm_o_alci_turret_h12_m","ACM_o_alci_2035_SF_IS","ACM_b_sam_2035_men_SF_CT","acm_b_sac_vehicle_m151_Armoured","acm_b_sac_vehicle_m151_Armoured_M","acm_o_alci_vehicle_m151_Armoured","acm_o_alci_vehicle_m151_Armoured_M","ACM_o_alci_2035_men_JetPilot","acm_o_alci_turret_ZPU4_m","acm_b_sac_turret_m45","acm_b_sac_turret_m45_M","acm_o_alci_vehicle_z157_transport_cover","acm_o_alci_vehicle_z157_transport_cover_M","acm_o_alci_vehicle_z157_transport","acm_o_alci_vehicle_z157_transport_M","acm_o_alci_vehicle_z157_ammo","acm_o_alci_vehicle_z157_ammo_M","acm_o_alci_vehicle_z157_fuel","acm_o_alci_vehicle_z157_fuel_M","acm_o_alci_vehicle_z157_repair","acm_o_alci_vehicle_z157_repair_M","acm_o_alci_vehicle_z157_ZPU_M","acm_o_alci_vehicle_z157_Radar_M","acm_o_alci_vehicle_z157_SAM_M","acm_o_alci_vehicle_BTR40_M","acm_o_alci_vehicle_BTR40_Ambulance_M","acm_o_alci_vehicle_BTR40_ZPU_M","acm_o_alci_vehicle_BTR40_Dshkm_M","acm_b_sac_vehicle_m54_transport","acm_b_sac_vehicle_m54_transport_M","acm_b_sac_vehicle_m54_transport_Cover","acm_b_sac_vehicle_m54_transport_Cover_M","acm_b_sac_vehicle_m54_ammo","acm_b_sac_vehicle_m54_ammo_M","acm_b_sac_vehicle_m54_fuel","acm_b_sac_vehicle_m54_fuel_M","acm_b_sac_vehicle_m54_repair","acm_b_sac_vehicle_m54_repair_M","acm_b_sac_vehicle_m54_battleBus","acm_b_sac_vehicle_m54_battleBus_M","acm_b_sac_vehicle_m54_AA","acm_b_sac_vehicle_m54_AA_M","ACM_b_sam_men_ParadeDress","ACM_b_sam_men_ParadeDress_Vet","ACM_b_sam_2035_men_ParadeDress","ACM_b_sam_2035_men_ParadeDress_Vet"};
		weapons[] = {"acm_vn_m3a1_suppress","acm_fwa_l8t_marksman","acm_fwa_acillo_marksman","acm_vn_m14_sd_marksman","acm_fwa_l1a1_IR","acm_Fwa_m1918a2_bar_LMG","acm_sac_m_trg20","acm_sac_m_trg21","acm_sac_m_trg21_gl","acm_sac_m_MXM","acm_sac_m_MX_SW","acm_sac_m_MXC"};
		requiredVersion = 0.1;
		requiredAddons[] = {"A3_Characters_F","cba_xeh","A3_Data_F","armor_f_vietnam_c"};
	};
};
class EventHandlers;
class cfgFactionClasses
{
	class ACM_B_SAC
	{
		displayName = "Saint Anselm Constabulary";
		side = 1;
		priority = 1;
		icon = "\acm_saintanselm\faction\flag_anselm_ico_co.paa";
		flag = "\acm_saintanselm\faction\flag_anselm_ico_co.paa";
	};
	class ACM_B_SAC_2035
	{
		displayName = "Saint Anselm Constabulary (2035)";
		side = 1;
		priority = 1;
		icon = "\acm_saintanselm\faction\flag_anselm_ico_co.paa";
		flag = "\acm_saintanselm\faction\flag_anselm_ico_co.paa";
	};
	class ACM_O_ATIU
	{
		displayName = "Alcillian Territorial Integrity Units";
		side = 0;
		priority = 1;
		icon = "\acm_saintanselm\faction\flag_alcillo_ico_co.paa";
		flag = "\acm_saintanselm\faction\flag_alcillo_ico_co.paa";
	};
	class ACM_O_ATIU_2035
	{
		displayName = "Alcillian Territorial Integrity Units (2035)";
		side = 0;
		priority = 1;
		icon = "\acm_saintanselm\faction\flag_alcillo_ico_co.paa";
		flag = "\acm_saintanselm\faction\flag_alcillo_ico_co.paa";
	};
	class ACM_I_Shitpost_UBPR
	{
		displayName = "Upper-Blackmouth People's Republic";
		side = 2;
		priority = 1;
	};
};
class CfgEditorSubcategories
{
	class ACM_SAM_Police
	{
		displayName = "Men (Police)";
	};
	class ACM_SAM_Res
	{
		displayName = "Men (Citizen's Reserve)";
	};
};
class CfgWeapons
{
	class vn_m3a1;
	class acm_vn_m3a1_suppress: vn_m3a1
	{
		scope = 1;
		class LinkedItems
		{
			class LinkedItemsMuzzle
			{
				slot = "MuzzleSlot";
				item = "vn_s_m3a1";
			};
		};
	};
	class sp_fwa_enfield_l8t_walnut;
	class acm_fwa_l8t_marksman: sp_fwa_enfield_l8t_walnut
	{
		scope = 1;
		class LinkedItems
		{
			class LinkedItemsOptic
			{
				slot = "CowsSlot";
				item = "sp_fwa_no32_vintage";
			};
		};
	};
	class sp_fwa_enfield_no4t;
	class acm_fwa_acillo_marksman: sp_fwa_enfield_no4t
	{
		scope = 1;
		class LinkedItems
		{
			class LinkedItemsOptic
			{
				slot = "CowsSlot";
				item = "sp_fwa_no32_vintage";
			};
		};
	};
	class vn_m14_sd;
	class acm_vn_m14_sd_marksman: vn_m14_sd
	{
		scope = 1;
		class LinkedItems
		{
			class LinkedItemsMuzzle
			{
				slot = "MuzzleSlot";
				item = "vn_s_m14";
			};
			class LinkedItemsAcc
			{
				slot = "UnderBarrelSlot";
				item = "vn_b_camo_m14";
			};
			class LinkedItemsOptic
			{
				slot = "CowsSlot";
				item = "vn_o_9x_m14";
			};
		};
	};
	class sp_fwa_fal_l1a1_wood;
	class acm_fwa_l1a1_IR: sp_fwa_fal_l1a1_wood
	{
		scope = 1;
		class LinkedItems
		{
			class LinkedItemsOptic
			{
				slot = "CowsSlot";
				item = "sp_fwa_scope_eltro_b8v_ir_scope";
			};
			class LinkedItemsAcc
			{
				slot = "PointerSlot";
				item = "sp_fwa_illuminator_eltro_b8v_ir";
			};
		};
	};
	class sp_fwa_m1918a2_bar;
	class acm_Fwa_m1918a2_bar_LMG: sp_fwa_m1918a2_bar
	{
		scope = 1;
		author = "Free World Armoury";
		class LinkedItems
		{
			class LinkedItemsUnder
			{
				slot = "UnderBarrelSlot";
				item = "sp_fwa_acc_bipod_bar";
			};
			class LinkedItemsAcc
			{
				slot = "PointerSlot";
				item = "sp_fwa_acc_carryHandle_bar";
			};
		};
	};
	class arifle_TRG20_F;
	class arifle_TRG21_F;
	class arifle_TRG21_GL_F;
	class arifle_MXM_Black_F;
	class arifle_MX_SW_Black_F;
	class sp_fwa_fal_factory_50_64;
	class sp_fwa_ar15_646_m16a3_m203;
	class sp_fwa_bm59_mk3_alpine;
	class arifle_Katiba_C_F;
	class arifle_Katiba_GL_F;
	class arifle_Katiba_F;
	class srifle_DMR_05_blk_F;
	class LMG_03_F;
	class vn_m9130;
	class arifle_MXC_Black_F;
	class acm_sac_m_trg20: arifle_TRG20_F
	{
		scope = 1;
		class LinkedItems
		{
			class LinkedItemsOptic
			{
				slot = "CowsSlot";
				item = "optic_Hamr";
			};
			class LinkedItemsMuzzle
			{
				slot = "MuzzleSlot";
				item = "muzzle_snds_M";
			};
		};
	};
	class acm_sac_m_trg21: arifle_TRG21_F
	{
		scope = 1;
		class LinkedItems
		{
			class LinkedItemsOptic
			{
				slot = "CowsSlot";
				item = "optic_Hamr";
			};
			class LinkedItemsMuzzle
			{
				slot = "MuzzleSlot";
				item = "muzzle_snds_M";
			};
		};
	};
	class acm_sac_m_trg21_gl: arifle_TRG21_GL_F
	{
		scope = 1;
		class LinkedItems
		{
			class LinkedItemsOptic
			{
				slot = "CowsSlot";
				item = "optic_Hamr";
			};
			class LinkedItemsMuzzle
			{
				slot = "MuzzleSlot";
				item = "muzzle_snds_M";
			};
		};
	};
	class acm_sac_m_MXM: arifle_MXM_Black_F
	{
		scope = 1;
		class LinkedItems
		{
			class LinkedItemsOptic
			{
				slot = "CowsSlot";
				item = "optic_SOS";
			};
			class LinkedItemsMuzzle
			{
				slot = "MuzzleSlot";
				item = "muzzle_snds_65_TI_blk_F";
			};
			class LinkedItemsUnder
			{
				slot = "UnderBarrelSlot";
				item = "bipod_01_F_blk";
			};
		};
	};
	class acm_sac_m_MX_SW: arifle_MX_SW_Black_F
	{
		scope = 1;
		class LinkedItems
		{
			class LinkedItemsOptic
			{
				slot = "CowsSlot";
				item = "optic_Hamr";
			};
			class LinkedItemsUnder
			{
				slot = "UnderBarrelSlot";
				item = "bipod_01_F_blk";
			};
			class LinkedItemsMuzzle
			{
				slot = "MuzzleSlot";
				item = "muzzle_snds_65_TI_blk_F";
			};
		};
	};
	class acm_sac_m_sp_fal64_scope: sp_fwa_fal_factory_50_64
	{
		scope = 1;
		class LinkedItems
		{
			class LinkedItemsOptic
			{
				slot = "CowsSlot";
				item = "sp_fwa_scope_fal_fn_factory";
			};
			class LinkedItemsUnder
			{
				slot = "UnderBarrelSlot";
				item = "sp_fwa_acc_bipod_fal";
			};
		};
	};
	class acm_sac_m_MXC: arifle_MXC_Black_F
	{
		scope = 1;
		class LinkedItems
		{
			class LinkedItemsOptic
			{
				slot = "CowsSlot";
				item = "optic_ACO_grn";
			};
			class LinkedItemsMuzzle
			{
				slot = "MuzzleSlot";
				item = "muzzle_snds_65_TI_blk_F";
			};
		};
	};
	class acm_sac_m_cr_m19130: vn_m9130
	{
		scope = 1;
		class LinkedItems
		{
			class LinkedItemsOptic
			{
				slot = "CowsSlot";
				item = "vn_o_3x_m9130";
			};
			class LinkedItemsUnder
			{
				slot = "UnderBarrelSlot";
				item = "vn_b_camo_m9130";
			};
		};
	};
	class acm_alc_m_sp_m16_m203: sp_fwa_ar15_646_m16a3_m203
	{
		scope = 1;
		class LinkedItems
		{
			class LinkedItemsOptic
			{
				slot = "CowsSlot";
				item = "sp_fwa_scope_ar_colt3x20";
			};
		};
	};
	class acm_alc_m_sp_bm59: sp_fwa_bm59_mk3_alpine
	{
		scope = 1;
		class LinkedItems
		{
			class LinkedItemsOptic
			{
				slot = "CowsSlot";
				item = "sp_fwa_scope_bm59_diavari";
			};
		};
	};
	class acm_alc_m_sf_kat_c: arifle_Katiba_C_F
	{
		scope = 1;
		class LinkedItems
		{
			class LinkedItemsOptic
			{
				slot = "CowsSlot";
				item = "optic_Arco_blk_F";
			};
			class LinkedItemsMuzzle
			{
				slot = "MuzzleSlot";
				item = "muzzle_snds_65_TI_blk_F";
			};
		};
	};
	class acm_alc_m_sf_kat_GL: arifle_Katiba_GL_F
	{
		scope = 1;
		class LinkedItems
		{
			class LinkedItemsOptic
			{
				slot = "CowsSlot";
				item = "optic_Arco_blk_F";
			};
			class LinkedItemsMuzzle
			{
				slot = "MuzzleSlot";
				item = "muzzle_snds_65_TI_blk_F";
			};
		};
	};
	class acm_alc_m_sf_kat_TL: arifle_Katiba_F
	{
		scope = 1;
		class LinkedItems
		{
			class LinkedItemsOptic
			{
				slot = "CowsSlot";
				item = "optic_Arco_blk_F";
			};
			class LinkedItemsMuzzle
			{
				slot = "MuzzleSlot";
				item = "muzzle_snds_65_TI_blk_F";
			};
		};
	};
	class acm_alc_m_sf_DMR_05: srifle_DMR_05_blk_F
	{
		scope = 1;
		class LinkedItems
		{
			class LinkedItemsOptic
			{
				slot = "CowsSlot";
				item = "optic_DMS";
			};
			class LinkedItemsMuzzle
			{
				slot = "MuzzleSlot";
				item = "muzzle_snds_93mmg";
			};
			class LinkedItemsUnder
			{
				slot = "UnderBarrelSlot";
				item = "bipod_02_F_blk";
			};
		};
	};
	class acm_alc_m_sf_LMG_03_F: LMG_03_F
	{
		scope = 1;
		class LinkedItems
		{
			class LinkedItemsOptic
			{
				slot = "CowsSlot";
				item = "optic_Arco_blk_F";
			};
			class LinkedItemsMuzzle
			{
				slot = "MuzzleSlot";
				item = "muzzle_snds_M";
			};
		};
	};
};
class CfgVehicles
{
	class B_Survivor_F;
	class ACM_b_sam_men_rifleman: B_Survivor_F
	{
		faction = "ACM_B_SAC";
		side = 1;
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_rifleman.jpg";
		displayName = "Rifleman";
		nakedUniform = "vn_b_uniform_basecharacter_01";
		uniformClass = "acm_sam_clothes01_1";
		items[] = {"vn_b_item_firstaidkit","vn_b_item_firstaidkit"};
		respawnItems[] = {"vn_b_item_firstaidkit","vn_b_item_firstaidkit"};
		magazines[] = {"sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		respawnMagazines[] = {"sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		linkedItems[] = {"vn_b_vest_usarmy_02","ACM_Helmet_Mk5_Nostrap","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_02","ACM_Helmet_Mk5_Nostrap","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		backpack = "vn_b_pack_lw_01";
		weapons[] = {"sp_fwa_enfield_l8_walnut","Throw","Put"};
		respawnweapons[] = {"sp_fwa_enfield_l8_walnut","Throw","Put"};
		identityTypes[] = {"LanguageENGB_F","vn_b_camo_us","Head_Euro"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Rifleman";
		accuracy = 2.3;
		camouflage = 1.4;
		minFireTime = 7;
	};
	class ACM_b_sam_men_rifleman_2: ACM_b_sam_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_rifleman_2.jpg";
		displayName = "Rifleman 2";
		uniformClass = "acm_sam_clothes01_2";
		magazines[] = {"sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		respawnMagazines[] = {"sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		linkedItems[] = {"vn_b_vest_usarmy_02","ACM_Helmet_Mk5_Cover","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_02","ACM_Helmet_Mk5_Cover","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Rifleman";
		accuracy = 2.3;
		camouflage = 1.4;
		minFireTime = 7;
	};
	class ACM_b_sam_men_rifleman_3: ACM_b_sam_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_rifleman_3.jpg";
		displayName = "Rifleman 3";
		backpack = "vn_b_pack_pfield_02";
		uniformClass = "acm_sam_clothes01_2";
		magazines[] = {"sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		respawnMagazines[] = {"sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		linkedItems[] = {"vn_b_vest_usarmy_02","ACM_Helmet_Mk5_Scrim2","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_02","ACM_Helmet_Mk5_Scrim2","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Rifleman";
		accuracy = 2.3;
		camouflage = 1.4;
		minFireTime = 7;
	};
	class ACM_b_sam_men_rifleman_AT: ACM_b_sam_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_rifleman_AT.jpg";
		displayName = "Rifleman (AT)";
		uniformClass = "acm_sam_clothes01_1";
		magazines[] = {"sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m72_mag"};
		respawnMagazines[] = {"sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m72_mag"};
		linkedItems[] = {"vn_b_vest_usarmy_03","ACM_Helmet_Mk5_Net","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_03","ACM_Helmet_Mk5_Net","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"sp_fwa_enfield_l8_walnut","vn_m72","Throw","Put"};
		respawnweapons[] = {"sp_fwa_enfield_l8_walnut","vn_m72","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_AT_s"};
				speechPlural[] = {"veh_infantry_AT_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_AT_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_AT_p";
		nameSound = "veh_infantry_AT_s";
		icon = "iconManAT";
		role = "MissileSpecialist";
		cost = 130000;
		secondaryAmmoCoef = 0.5;
		threat[] = {0.8,0.8,0.3};
	};
	class ACM_b_sam_men_SL: ACM_b_sam_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_SL.jpg";
		displayName = "Sergeant";
		uniformClass = "acm_sam_clothes01_4";
		magazines[] = {"vn_l1a1_20_t_mag","vn_l1a1_20_t_mag","vn_l1a1_20_t_mag","vn_l1a1_20_t_mag","vn_l1a1_20_t_mag","vn_l1a1_20_t_mag","vn_l1a1_20_t_mag","vn_l1a1_20_t_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m127_mag","vn_m127_mag"};
		respawnMagazines[] = {"vn_l1a1_20_t_mag","vn_l1a1_20_t_mag","vn_l1a1_20_t_mag","vn_l1a1_20_t_mag","vn_l1a1_20_t_mag","vn_l1a1_20_t_mag","vn_l1a1_20_t_mag","vn_l1a1_20_t_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m127_mag","vn_m127_mag"};
		linkedItems[] = {"vn_b_vest_anzac_07","ACM_Helmet_Mk5_Scrim","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_anzac_07","ACM_Helmet_Mk5_Scrim","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		backpack = "vn_b_pack_lw_06";
		weapons[] = {"vn_l1a1_01","vn_hp","vn_anpvs2_binoc","vn_m127","Throw","Put"};
		respawnweapons[] = {"vn_l1a1_01","vn_hp","vn_anpvs2_binoc","vn_m127","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		icon = "iconManLeader";
		role = "RadioOperator";
		cost = 250000;
	};
	class ACM_b_sam_men_MG: ACM_b_sam_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_MG.jpg";
		displayName = "Machinegunner";
		uniformClass = "acm_sam_clothes01_2";
		magazines[] = {"vn_l1a1_30_02_t_mag","vn_l1a1_30_02_t_mag","vn_l1a1_30_02_t_mag","vn_l1a1_30_02_t_mag","vn_l1a1_30_02_t_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag"};
		respawnMagazines[] = {"vn_l1a1_30_02_t_mag","vn_l1a1_30_02_t_mag","vn_l1a1_30_02_t_mag","vn_l1a1_30_02_t_mag","vn_l1a1_30_02_t_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag"};
		linkedItems[] = {"vn_b_vest_anzac_05","ACM_Helmet_Mk5_Net","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_anzac_05","ACM_Helmet_Mk5_Net","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		backpack = "acm_bag_sam_MG";
		weapons[] = {"vn_l2a1_01","vn_hp","Throw","Put"};
		respawnweapons[] = {"vn_l2a1_01","vn_hp","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_MG_s"};
				speechPlural[] = {"veh_infantry_MG_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_MG_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_MG_p";
		nameSound = "veh_infantry_MG_s";
		icon = "iconManMG";
		role = "MachineGunner";
		cost = 220000;
	};
	class ACM_b_sam_men_RTO: ACM_b_sam_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_RTO.jpg";
		displayName = "RTO";
		uniformClass = "acm_sam_clothes01_3";
		magazines[] = {"sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		respawnMagazines[] = {"sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		linkedItems[] = {"vn_b_vest_usarmy_09","ACM_Helmet_Mk5_Nostrap","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_09","ACM_Helmet_Mk5_Nostrap","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		backpack = "vn_b_pack_prc77_01";
		weapons[] = {"sp_fwa_smg_sterling","Throw","Put"};
		respawnweapons[] = {"sp_fwa_smg_sterling","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		icon = "iconManLeader";
		role = "Grenadier";
		cost = 250000;
	};
	class ACM_b_sam_men_RTO2: ACM_b_sam_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_RTO2.jpg";
		displayName = "RTO 2";
		uniformClass = "acm_sam_clothes01_2";
		magazines[] = {"sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		respawnMagazines[] = {"sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		linkedItems[] = {"vn_b_vest_usarmy_09","ACM_Helmet_Mk5_Cover","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_09","ACM_Helmet_Mk5_Cover","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		backpack = "vn_b_pack_prc77_01";
		weapons[] = {"sp_fwa_smg_sterling","Throw","Put"};
		respawnweapons[] = {"sp_fwa_smg_sterling","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		icon = "iconManLeader";
		role = "Grenadier";
		cost = 250000;
	};
	class ACM_b_sam_men_Marksman: ACM_b_sam_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_Marksman.jpg";
		displayName = "Marksman";
		uniformClass = "acm_sam_clothes01_1";
		magazines[] = {"sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		respawnMagazines[] = {"sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		linkedItems[] = {"vn_b_vest_usarmy_08","ACM_Helmet_Mk5_Scrim","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_08","ACM_Helmet_Mk5_Scrim","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		backpack = "";
		weapons[] = {"acm_fwa_l8t_marksman","Throw","Put"};
		respawnweapons[] = {"acm_fwa_l8t_marksman","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_sniper_s"};
				speechPlural[] = {"veh_infantry_sniper_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_sniper_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_sniper_p";
		nameSound = "veh_infantry_sniper_s";
		role = "Marksman";
		cost = 250000;
	};
	class ACM_b_sam_men_Medic: ACM_b_sam_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_Medic.jpg";
		displayName = "Medic";
		uniformClass = "acm_sam_clothes01_2";
		magazines[] = {"vn_l1a1_20_t_mag","vn_l1a1_20_t_mag","vn_l1a1_20_t_mag","vn_l1a1_20_t_mag","vn_l1a1_20_t_mag","vn_l1a1_20_t_mag","vn_l1a1_20_t_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		respawnMagazines[] = {"vn_l1a1_20_t_mag","vn_l1a1_20_t_mag","vn_l1a1_20_t_mag","vn_l1a1_20_t_mag","vn_l1a1_20_t_mag","vn_l1a1_20_t_mag","vn_l1a1_20_t_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		linkedItems[] = {"vn_b_vest_anzac_06","ACM_Helmet_Mk5_Net","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_anzac_06","ACM_Helmet_Mk5_Net","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		backpack = "acm_bag_sam_medic";
		weapons[] = {"vn_l1a1_01","Throw","Put"};
		respawnweapons[] = {"vn_l1a1_01","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_medic_s"};
				speechPlural[] = {"veh_infantry_medic_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_medic_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_medic_p";
		nameSound = "veh_infantry_medic_s";
		icon = "iconManMedic";
		picture = "pictureHeal";
		role = "CombatLifeSaver";
		attendant = 1;
	};
	class ACM_b_sam_men_HMG: ACM_b_sam_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_HMG.jpg";
		displayName = "Heavy Machinegunner";
		uniformClass = "acm_sam_clothes01_4";
		magazines[] = {"sp_fwa_30Rnd_Curved_762_FAL_Metric","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		respawnMagazines[] = {"sp_fwa_30Rnd_Curved_762_FAL_Metric","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		linkedItems[] = {"vn_b_vest_usarmy_06","ACM_Helmet_Mk5_Scrim2","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_06","ACM_Helmet_Mk5_Scrim2","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		backpack = "acm_bag_sam_hmg";
		weapons[] = {"sp_fwa_bren_l4_lmg","vn_hp","Throw","Put"};
		respawnweapons[] = {"sp_fwa_bren_l4_lmg","vn_hp","Throw","Put"};
	};
	class ACM_b_sam_men_Trench: ACM_b_sam_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_Trench.jpg";
		displayName = "Trench Fighter";
		uniformClass = "acm_sam_clothes01_3";
		magazines[] = {"vn_m1897_buck_mag","vn_m1897_buck_mag","vn_m1897_buck_mag","vn_m1897_buck_mag","vn_m1897_buck_mag","vn_m1897_buck_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m1897_fl_mag","vn_m1897_fl_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag"};
		respawnMagazines[] = {"vn_m1897_buck_mag","vn_m1897_buck_mag","vn_m1897_buck_mag","vn_m1897_buck_mag","vn_m1897_buck_mag","vn_m1897_buck_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m1897_fl_mag","vn_m1897_fl_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag"};
		linkedItems[] = {"vn_b_vest_usarmy_04","ACM_Helmet_Mk5_Cover_Net","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_04","ACM_Helmet_Mk5_Cover_Net","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		backpack = "";
		weapons[] = {"vn_m1897","vn_hp","Throw","Put"};
		respawnweapons[] = {"vn_m1897","vn_hp","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Rifleman";
		accuracy = 2.3;
		camouflage = 1.4;
		minFireTime = 7;
	};
	class ACM_b_sam_men_Demo: ACM_b_sam_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_Demo.jpg";
		displayName = "Demolitions";
		uniformClass = "acm_sam_clothes01_1";
		magazines[] = {"sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		respawnMagazines[] = {"sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		linkedItems[] = {"vn_b_vest_sog_03","ACM_Helmet_Mk5_Scrim","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_sog_03","ACM_Helmet_Mk5_Scrim","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		backpack = "acm_bag_sam_demo";
		weapons[] = {"sp_fwa_enfield_l8_walnut","Throw","Put"};
		respawnweapons[] = {"sp_fwa_enfield_l8_walnut","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		icon = "iconManEngineer";
		picture = "pictureRepair";
		role = "Sapper";
		canDeactivateMines = 1;
		cost = 93000;
		detectSkill = 38;
		engineer = 1;
	};
	class ACM_b_sam_men_cg1: ACM_b_sam_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_cg1.jpg";
		displayName = "Coast Guard 1";
		uniformClass = "acm_sam_clothes01_2";
		magazines[] = {"sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		respawnMagazines[] = {"sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		linkedItems[] = {"vn_b_vest_seal_04","ACM_Helmet_Mk5_Nostrap","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_seal_04","ACM_Helmet_Mk5_Nostrap","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		backpack = "";
		weapons[] = {"sp_fwa_enfield_l8_walnut","Throw","Put"};
		respawnweapons[] = {"sp_fwa_enfield_l8_walnut","Throw","Put"};
	};
	class ACM_b_sam_men_cg2: ACM_b_sam_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_cg2.jpg";
		displayName = "Coast Guard 2";
		uniformClass = "acm_sam_clothes01_3";
		magazines[] = {"sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		respawnMagazines[] = {"sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		linkedItems[] = {"vn_b_vest_seal_04","ACM_Helmet_Mk5_Nostrap","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_seal_04","ACM_Helmet_Mk5_Nostrap","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		backpack = "";
		weapons[] = {"sp_fwa_smg_sterling","Throw","Put"};
		respawnweapons[] = {"sp_fwa_smg_sterling","Throw","Put"};
	};
	class ACM_b_sam_men_gunner: ACM_b_sam_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_gunner.jpg";
		displayName = "Gunner 1";
		uniformClass = "acm_sam_clothes01_3";
		magazines[] = {"sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		respawnMagazines[] = {"sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		linkedItems[] = {"vn_b_vest_usarmy_14","ACM_Helmet_Mk5_Cover_Net","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_14","ACM_Helmet_Mk5_Cover_Net","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		backpack = "";
		weapons[] = {"sp_fwa_enfield_l8_walnut","Throw","Put"};
		respawnweapons[] = {"sp_fwa_enfield_l8_walnut","Throw","Put"};
	};
	class ACM_b_sam_men_gunner2: ACM_b_sam_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_gunner2.jpg";
		displayName = "Gunner 2";
		uniformClass = "acm_sam_clothes01_2";
		magazines[] = {"sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		respawnMagazines[] = {"sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		linkedItems[] = {"vn_b_vest_usarmy_14","ACM_Helmet_Mk5_Nostrap","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_14","ACM_Helmet_Mk5_Nostrap","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		backpack = "";
		weapons[] = {"sp_fwa_enfield_l8_walnut","Throw","Put"};
		respawnweapons[] = {"sp_fwa_enfield_l8_walnut","Throw","Put"};
	};
	class ACM_b_sam_men_grenadier: ACM_b_sam_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_grenadier.jpg";
		displayName = "Grenadier";
		uniformClass = "acm_sam_clothes01_4";
		magazines[] = {"sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		respawnMagazines[] = {"sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		linkedItems[] = {"vn_b_vest_usarmy_03","ACM_Helmet_Mk5_Scrim","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_03","ACM_Helmet_Mk5_Scrim","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		backpack = "acm_bag_sam_grenadier";
		weapons[] = {"sp_fwa_enfield_l8_walnut","Throw","Put"};
		respawnweapons[] = {"sp_fwa_enfield_l8_walnut","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Grenadier";
		cost = 200000;
	};
	class ACM_b_sam_men_unarmed: ACM_b_sam_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_unarmed.jpg";
		displayName = "Rifleman (Unarmed)";
		backpack = "";
		weapons[] = {"Throw","Put"};
		respawnWeapons[] = {"Throw","Put"};
		magazines[] = {};
		respawnMagazines[] = {};
		role = "Unarmed";
		threat[] = {0.1,0.1,0.1};
	};
	class ACM_b_sam_men_survivor: ACM_b_sam_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_survivor.jpg";
		displayName = "Survivor";
		uniformClass = "acm_sam_clothes01_2";
		linkedItems[] = {"vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		backpack = "";
		weapons[] = {"Throw","Put"};
		respawnWeapons[] = {"Throw","Put"};
		magazines[] = {};
		respawnMagazines[] = {};
		role = "Unarmed";
		threat[] = {0.1,0.1,0.1};
	};
	class ACM_b_sam_men_ParadeDress: ACM_b_sam_men_survivor
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_ParadeDress.jpg";
		displayName = "Constable (Parade Dress)";
		uniformClass = "acm_sam_clothes01_6_1";
		linkedItems[] = {"acm_sam_headwear_paradecap","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"acm_sam_headwear_paradecap","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		backpack = "";
		weapons[] = {"Throw","Put"};
		respawnWeapons[] = {"Throw","Put"};
		magazines[] = {};
		respawnMagazines[] = {};
		role = "Unarmed";
		threat[] = {0.1,0.1,0.1};
		identityTypes[] = {"LanguageENGB_F","Head_Euro","Head_NATO"};
	};
	class ACM_b_sam_men_ParadeDress_Vet: ACM_b_sam_men_ParadeDress
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_ParadeDress_Vet.jpg";
		displayName = "Constable (Parade Dress, Veteran)";
		uniformClass = "acm_sam_clothes01_6_2";
		linkedItems[] = {"G_Aviator","acm_sam_headwear_paradecap","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"G_Aviator","acm_sam_headwear_paradecap","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
	};
	class ACM_b_sam_men_officer: ACM_b_sam_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_officer.jpg";
		displayName = "Superintendent";
		uniformClass = "acm_sam_clothes01_1";
		magazines[] = {"vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		respawnMagazines[] = {"vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		linkedItems[] = {"vn_b_vest_usarmy_09","acm_sam_headwear_beret_anselm","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_09","acm_sam_headwear_beret_anselm","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		backpack = "";
		weapons[] = {"vn_hp","vn_m19_binocs_grey","Throw","Put"};
		respawnweapons[] = {"vn_hp","vn_m19_binocs_grey","Throw","Put"};
		identityTypes[] = {"LanguageENGB_F","Head_Euro"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_officer_s"};
				speechPlural[] = {"veh_infantry_officer_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_officer_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_officer_p";
		nameSound = "veh_infantry_officer_s";
		icon = "iconManOfficer";
		role = "Rifleman";
		camouflage = 1.6;
		cost = 250000;
	};
	class ACM_b_sam_men_Pilot: ACM_b_sam_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_Pilot.jpg";
		displayName = "Rotary-Wing Pilot";
		uniformClass = "acm_sam_clothes01_5";
		magazines[] = {"vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		respawnMagazines[] = {"vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		linkedItems[] = {"vn_b_vest_aircrew_04","vn_b_helmet_aph6_01_05","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_aircrew_04","vn_b_helmet_aph6_01_05","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		backpack = "";
		weapons[] = {"vn_hp","vn_m19_binocs_grey","Throw","Put"};
		respawnweapons[] = {"vn_hp","vn_m19_binocs_grey","Throw","Put"};
		identityTypes[] = {"LanguageENGB_F","Head_Euro"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Crewman";
		camouflage = 2;
		cost = 93000;
		engineer = 1;
	};
	class ACM_b_sam_men_Crew: ACM_b_sam_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_Crew.jpg";
		displayName = "Crew";
		uniformClass = "acm_sam_clothes01_1";
		magazines[] = {"vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		respawnMagazines[] = {"vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		linkedItems[] = {"vn_b_vest_usarmy_13","vn_b_helmet_t56_02_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_13","vn_b_helmet_t56_02_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		backpack = "";
		weapons[] = {"vn_hp","sp_fwa_smg_sterling","Throw","Put"};
		respawnweapons[] = {"vn_hp","sp_fwa_smg_sterling","Throw","Put"};
		identityTypes[] = {"LanguageENGB_F","Head_Euro"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Crewman";
		camouflage = 2;
		cost = 93000;
		engineer = 1;
	};
	class ACM_b_sam_men_police_constable: ACM_b_sam_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_police_constable.jpg";
		displayName = "Constable";
		uniformClass = "acm_sam_clothes01_1_Police";
		magazines[] = {"vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag"};
		respawnMagazines[] = {"vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag"};
		linkedItems[] = {"vn_b_vest_usarmy_01","acm_sam_headwear_beret_anselm","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_01","acm_sam_headwear_beret_anselm","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		backpack = "";
		weapons[] = {"vn_hp","Throw","Put"};
		respawnweapons[] = {"vn_hp","Throw","Put"};
		identityTypes[] = {"LanguageENGB_F","Head_Euro","Head_African"};
		editorSubcategory = "ACM_SAM_Police";
	};
	class ACM_b_sam_men_police_constable_armor: ACM_b_sam_men_police_constable
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_police_constable_armor.jpg";
		displayName = "Constable (Armor)";
		uniformClass = "acm_sam_clothes01_1_Police";
		magazines[] = {"vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag"};
		respawnMagazines[] = {"vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag"};
		linkedItems[] = {"vn_b_vest_usarmy_13","acm_sam_headwear_beret_anselm","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_13","acm_sam_headwear_beret_anselm","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"vn_hp","Throw","Put"};
		respawnweapons[] = {"vn_hp","Throw","Put"};
	};
	class ACM_b_sam_men_police_riot_shotgunner: ACM_b_sam_men_police_constable
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_police_riot_shotgunner.jpg";
		displayName = "Riot Shotgunner";
		uniformClass = "acm_sam_clothes01_3_Police";
		magazines[] = {"vn_m1897_buck_mag","vn_m1897_buck_mag","vn_m1897_buck_mag","vn_m1897_buck_mag","vn_m1897_buck_mag","vn_m1897_buck_mag","vn_m1897_fl_mag","vn_m1897_fl_mag","vn_m1897_fl_mag","vn_m1897_fl_mag"};
		respawnMagazines[] = {"vn_m1897_buck_mag","vn_m1897_buck_mag","vn_m1897_buck_mag","vn_m1897_buck_mag","vn_m1897_buck_mag","vn_m1897_buck_mag","vn_m1897_fl_mag","vn_m1897_fl_mag","vn_m1897_fl_mag","vn_m1897_fl_mag"};
		linkedItems[] = {"vn_b_vest_usarmy_14","ACM_Helmet_Mk5_VisorUp","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_14","ACM_Helmet_Mk5_VisorUp","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"vn_m1897","Throw","Put"};
		respawnweapons[] = {"vn_m1897","Throw","Put"};
	};
	class ACM_b_sam_men_police_riot_SubMachine1: ACM_b_sam_men_police_constable
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_police_riot_SubMachine1.jpg";
		displayName = "Riot SubmachineGunner 1";
		uniformClass = "acm_sam_clothes01_3_Police";
		magazines[] = {"sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag"};
		respawnMagazines[] = {"sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag"};
		linkedItems[] = {"vn_b_vest_usarmy_13","ACM_Helmet_Mk5_Visor","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_13","ACM_Helmet_Mk5_Visor","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"sp_fwa_smg_mk6sterling","vn_hp","Throw","Put"};
		respawnweapons[] = {"sp_fwa_smg_mk6sterling","vn_hp","Throw","Put"};
	};
	class ACM_b_sam_men_police_riot_SubMachine2: ACM_b_sam_men_police_riot_SubMachine1
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_police_riot_SubMachine2.jpg";
		displayName = "Riot SubmachineGunner 2";
		uniformClass = "acm_sam_clothes01_1_Police";
	};
	class ACM_b_sam_men_police_riot_Marksman: ACM_b_sam_men_police_constable
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_police_riot_Marksman.jpg";
		displayName = "Riot Marksman";
		uniformClass = "acm_sam_clothes01_2_Police";
		magazines[] = {"sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag"};
		respawnMagazines[] = {"sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag"};
		linkedItems[] = {"vn_b_vest_usarmy_13","ACM_Helmet_Mk5_VisorUp","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_13","ACM_Helmet_Mk5_VisorUp","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"acm_fwa_l8t_marksman","vn_hp","Throw","Put"};
		respawnweapons[] = {"acm_fwa_l8t_marksman","vn_hp","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_sniper_s"};
				speechPlural[] = {"veh_infantry_sniper_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_sniper_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_sniper_p";
		nameSound = "veh_infantry_sniper_s";
		role = "Marksman";
		cost = 250000;
	};
	class ACM_b_sam_men_police_riot_Grenadier: ACM_b_sam_men_police_constable
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_police_riot_Grenadier.jpg";
		displayName = "Riot Gas Controller";
		uniformClass = "acm_sam_clothes01_1_Police";
		magazines[] = {"vn_40mm_m651_cs_mag","vn_40mm_m651_cs_mag","vn_40mm_m651_cs_mag","vn_40mm_m651_cs_mag","vn_40mm_m651_cs_mag","vn_40mm_m651_cs_mag","vn_40mm_m651_cs_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_40mm_m682_smoke_r_mag","vn_40mm_m682_smoke_r_mag","vn_40mm_m583_flare_w_mag","vn_40mm_m583_flare_w_mag"};
		respawnMagazines[] = {"vn_40mm_m651_cs_mag","vn_40mm_m651_cs_mag","vn_40mm_m651_cs_mag","vn_40mm_m651_cs_mag","vn_40mm_m651_cs_mag","vn_40mm_m651_cs_mag","vn_40mm_m651_cs_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_40mm_m682_smoke_r_mag","vn_40mm_m682_smoke_r_mag","vn_40mm_m583_flare_w_mag","vn_40mm_m583_flare_w_mag"};
		linkedItems[] = {"vn_b_vest_usarmy_13","ACM_Helmet_Mk5_Nostrap","vn_b_acc_m17_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_13","ACM_Helmet_Mk5_Nostrap","vn_b_acc_m17_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"vn_m79","vn_hp","Throw","Put"};
		respawnweapons[] = {"vn_m79","vn_hp","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Grenadier";
		cost = 200000;
	};
	class ACM_b_sam_men_police_riot_ArmedResponse: ACM_b_sam_men_police_constable
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_police_riot_ArmedResponse.jpg";
		displayName = "Riot Armed Response";
		uniformClass = "acm_sam_clothes01_1_Police";
		linkedItems[] = {"vn_b_vest_usarmy_13","ACM_Helmet_Mk5_Visor","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_13","ACM_Helmet_Mk5_Visor","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
	};
	class ACM_b_sam_men_SF_scout: ACM_b_sam_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_SF_scout.jpg";
		displayName = "Recon Scout";
		uniformClass = "acm_sam_clothes01_4";
		magazines[] = {"sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","vn_f1_grenade_mag","vn_f1_grenade_mag","vn_mine_m18_mag","vn_mine_m18_mag"};
		respawnMagazines[] = {"sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","vn_f1_grenade_mag","vn_f1_grenade_mag","vn_mine_m18_mag","vn_mine_m18_mag"};
		linkedItems[] = {"vn_b_vest_sog_04","acm_sam_headwear_boonie","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_sog_04","acm_sam_headwear_boonie","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		backpack = "vn_b_pack_lw_01";
		weapons[] = {"sp_fwa_smg_mk5sterling","Throw","Put"};
		respawnweapons[] = {"sp_fwa_smg_mk5sterling","Throw","Put"};
		editorSubcategory = "EdSubcat_Personnel_SpecialForces";
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_SF_s"};
				speechPlural[] = {"veh_infantry_SF_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_SF_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_SF_p";
		nameSound = "veh_infantry_SF_s";
		role = "Rifleman";
		camouflage = 0.6;
		detectSkill = 18;
	};
	class ACM_b_sam_men_SF_scout_2: ACM_b_sam_men_SF_scout
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_SF_scout.jpg";
		displayName = "Recon Scout (L1A1)";
		uniformClass = "acm_sam_clothes01_2";
		magazines[] = {"vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_22mm_n94_heat_mag","vn_22mm_n94_heat_mag","vn_22mm_n94_heat_mag","vn_22mm_m61_frag_mag"};
		respawnMagazines[] = {"vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_22mm_n94_heat_mag","vn_22mm_n94_heat_mag","vn_22mm_n94_heat_mag","vn_22mm_m61_frag_mag"};
		linkedItems[] = {"vn_b_vest_anzac_04","ACM_Helmet_Mk5_Scrim2","vn_b_acc_towel_02","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_anzac_04","ACM_Helmet_Mk5_Scrim2","vn_b_acc_towel_02","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		backpack = "vn_b_pack_p44_03";
		weapons[] = {"vn_l1a1_01_gl","Throw","Put"};
		respawnweapons[] = {"vn_l1a1_01_gl","Throw","Put"};
	};
	class ACM_b_sam_men_SF_Night: ACM_b_sam_men_SF_scout
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_SF_Night.jpg";
		displayName = "Recon Night Fighter";
		uniformClass = "acm_sam_clothes01_2";
		magazines[] = {"sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","vn_f1_grenade_mag","vn_f1_grenade_mag","vn_mine_m18_mag","vn_mine_m18_mag"};
		respawnMagazines[] = {"sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","vn_f1_grenade_mag","vn_f1_grenade_mag","vn_mine_m18_mag","vn_mine_m18_mag"};
		linkedItems[] = {"vn_b_vest_usarmy_03","acm_sam_headwear_beret_anselm","vn_b_scarf_01_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_03","acm_sam_headwear_beret_anselm","vn_b_scarf_01_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		backpack = "vn_b_pack_lw_01";
		weapons[] = {"acm_fwa_l1a1_IR","Throw","Put"};
		respawnweapons[] = {"acm_fwa_l1a1_IR","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_SF_s"};
				speechPlural[] = {"veh_infantry_SF_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_SF_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_SF_p";
		nameSound = "veh_infantry_SF_s";
		role = "Rifleman";
		camouflage = 0.6;
		detectSkill = 18;
	};
	class ACM_b_sam_men_SF_TL: ACM_b_sam_men_SF_scout
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_SF_TL.jpg";
		displayName = "Recon Team Lead";
		uniformClass = "acm_sam_clothes01_4";
		magazines[] = {"vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_f1_grenade_mag","vn_f1_grenade_mag","vn_mine_m18_mag","vn_mine_m18_mag"};
		respawnMagazines[] = {"vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_f1_grenade_mag","vn_f1_grenade_mag","vn_mine_m18_mag","vn_mine_m18_mag"};
		linkedItems[] = {"vn_b_vest_sas_04","acm_sam_headwear_boonie_Fold","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_sas_04","acm_sam_headwear_boonie_Fold","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		backpack = "vn_b_pack_lw_06";
		weapons[] = {"vn_l1a1_03","Throw","Put"};
		respawnweapons[] = {"vn_l1a1_03","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_SF_s"};
				speechPlural[] = {"veh_infantry_SF_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_SF_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_SF_p";
		nameSound = "veh_infantry_SF_s";
		icon = "iconManLeader";
		role = "RadioOperator";
		camouflage = 0.6;
		cost = 250000;
		detectSkill = 18;
	};
	class ACM_b_sam_men_SF_Medic: ACM_b_sam_men_SF_scout
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_SF_Medic.jpg";
		displayName = "Recon CLS";
		uniformClass = "acm_sam_clothes01_3";
		magazines[] = {"sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","vn_f1_grenade_mag","vn_f1_grenade_mag","vn_mine_m18_mag","vn_mine_m18_mag"};
		respawnMagazines[] = {"sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","vn_f1_grenade_mag","vn_f1_grenade_mag","vn_mine_m18_mag","vn_mine_m18_mag"};
		linkedItems[] = {"vn_b_vest_sog_02","acm_sam_headwear_boonie_Fold","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_sog_02","acm_sam_headwear_boonie_Fold","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		backpack = "acm_bag_sam_medic";
		weapons[] = {"sp_fwa_smg_mk5sterling","Throw","Put"};
		respawnweapons[] = {"sp_fwa_smg_mk5sterling","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_medic_s"};
				speechPlural[] = {"veh_infantry_medic_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_medic_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_medic_p";
		nameSound = "veh_infantry_medic_s";
		icon = "iconManMedic";
		picture = "pictureHeal";
		role = "CombatLifeSaver";
		attendant = 1;
		camouflage = 0.6;
		detectSkill = 18;
	};
	class ACM_b_sam_men_SF_Autorifleman: ACM_b_sam_men_SF_scout
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_SF_Autorifleman.jpg";
		displayName = "Recon Autorifleman";
		uniformClass = "acm_sam_clothes01_4";
		magazines[] = {"vn_l1a1_30_02_mag","vn_l1a1_30_02_mag","vn_l1a1_30_02_mag","vn_l1a1_30_02_mag","vn_l1a1_30_02_mag","vn_l1a1_30_02_mag","vn_l1a1_30_02_mag","vn_l1a1_30_02_mag","vn_l1a1_30_02_mag","vn_f1_grenade_mag","vn_f1_grenade_mag","vn_mine_m18_mag","vn_mine_m18_mag"};
		respawnMagazines[] = {"vn_l1a1_30_02_mag","vn_l1a1_30_02_mag","vn_l1a1_30_02_mag","vn_l1a1_30_02_mag","vn_l1a1_30_02_mag","vn_l1a1_30_02_mag","vn_l1a1_30_02_mag","vn_l1a1_30_02_mag","vn_l1a1_30_02_mag","vn_f1_grenade_mag","vn_f1_grenade_mag","vn_mine_m18_mag","vn_mine_m18_mag"};
		linkedItems[] = {"vn_b_vest_sog_05","acm_sam_headwear_boonie","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_sog_05","acm_sam_headwear_boonie","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		backpack = "vn_b_pack_lw_05";
		weapons[] = {"vn_l2a1_01","Throw","Put"};
		respawnweapons[] = {"vn_l2a1_01","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_MG_s"};
				speechPlural[] = {"veh_infantry_MG_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_MG_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_MG_p";
		nameSound = "veh_infantry_MG_s";
		icon = "iconManMG";
		role = "MachineGunner";
		camouflage = 0.6;
		cost = 220000;
		detectSkill = 38;
	};
	class ACM_b_sam_men_SF_Demo: ACM_b_sam_men_SF_scout
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_SF_Demo.jpg";
		displayName = "Recon Demolitions";
		uniformClass = "acm_sam_clothes01_4";
		magazines[] = {"sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","vn_f1_grenade_mag","vn_f1_grenade_mag","vn_mine_m18_mag","vn_mine_m18_mag"};
		respawnMagazines[] = {"sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","vn_f1_grenade_mag","vn_f1_grenade_mag","vn_mine_m18_mag","vn_mine_m18_mag"};
		linkedItems[] = {"vn_b_vest_sog_03","acm_sam_headwear_beret_anselm","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_sog_03","acm_sam_headwear_beret_anselm","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		backpack = "acm_bag_sam_demo";
		weapons[] = {"sp_fwa_smg_mk5sterling","Throw","Put"};
		respawnweapons[] = {"sp_fwa_smg_mk5sterling","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_SF_s"};
				speechPlural[] = {"veh_infantry_SF_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_SF_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_SF_p";
		nameSound = "veh_infantry_SF_s";
		icon = "iconManEngineer";
		picture = "pictureRepair";
		role = "Sapper";
		canDeactivateMines = 1;
		camouflage = 0.6;
		detectSkill = 38;
	};
	class ACM_b_sam_men_SF_Grenadier: ACM_b_sam_men_SF_scout
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_SF_Grenadier.jpg";
		displayName = "Recon Grenadier";
		uniformClass = "acm_sam_clothes01_1";
		magazines[] = {"vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag"};
		respawnMagazines[] = {"vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag","vn_l1a1_30_mag"};
		linkedItems[] = {"vn_b_vest_sog_04","acm_sam_headwear_boonie_Fold","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_sog_04","acm_sam_headwear_boonie_Fold","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		backpack = "acm_bag_sam_SF_grenadier";
		weapons[] = {"vn_l1a1_xm148","Throw","Put"};
		respawnweapons[] = {"vn_l1a1_xm148","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_SF_s"};
				speechPlural[] = {"veh_infantry_SF_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_SF_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_SF_p";
		nameSound = "veh_infantry_SF_s";
		role = "Grenadier";
		camouflage = 0.6;
		cost = 200000;
		detectSkill = 18;
	};
	class ACM_I_Shitpost_UBPR_PMMcKendrick: B_Survivor_F
	{
		faction = "ACM_I_Shitpost_UBPR";
		side = 2;
		editorPreview = "\acm_saintanselm\ui\ACM_I_Shitpost_UBPR_PMMcKendrick.jpg";
		displayName = "Prime Minister McKendrick";
		editorSubcategory = "EdSubcat_Personnel_Story";
		nakedUniform = "vn_b_uniform_basecharacter_01";
		uniformClass = "U_I_C_Soldier_Para_5_F";
		items[] = {"vn_b_item_firstaidkit","vn_b_item_firstaidkit"};
		respawnItems[] = {"vn_b_item_firstaidkit","vn_b_item_firstaidkit"};
		magazines[] = {"vn_sten_mag","vn_sten_mag","vn_sten_mag","vn_sten_mag","vn_sten_mag","vn_sten_mag","vn_sten_mag","vn_sten_mag","vn_sten_mag","vn_sten_mag","vn_sten_mag","vn_sten_mag","vn_sten_mag","vn_sten_mag","vn_izh54_so_mag","vn_izh54_so_mag","vn_izh54_so_mag","vn_izh54_so_mag","vn_izh54_so_mag","vn_izh54_so_mag","vn_izh54_so_mag","vn_izh54_so_mag"};
		respawnMagazines[] = {"vn_sten_mag","vn_sten_mag","vn_sten_mag","vn_sten_mag","vn_sten_mag","vn_sten_mag","vn_sten_mag","vn_sten_mag","vn_sten_mag","vn_sten_mag","vn_sten_mag","vn_sten_mag","vn_sten_mag","vn_sten_mag","vn_izh54_so_mag","vn_izh54_so_mag","vn_izh54_so_mag","vn_izh54_so_mag","vn_izh54_so_mag","vn_izh54_so_mag","vn_izh54_so_mag","vn_izh54_so_mag"};
		linkedItems[] = {"vn_o_vest_08","ACM_Helmet_Mk5_Nostrap","G_Aviator","ACM_Misc_Clothband_Green","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_o_vest_08","ACM_Helmet_Mk5_Nostrap","G_Aviator","ACM_Misc_Clothband_Green","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		backpack = "";
		weapons[] = {"vn_sten","vn_izh54_p","Throw","Put"};
		respawnweapons[] = {"vn_sten","vn_izh54_p","Throw","Put"};
		identityTypes[] = {"LanguageENGB_F","Head_Euro"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Rifleman";
		accuracy = 2.3;
		camouflage = 1.4;
		minFireTime = 7;
	};
	class ACM_I_Shitpost_UBPR_FMJackson: ACM_I_Shitpost_UBPR_PMMcKendrick
	{
		editorPreview = "\acm_saintanselm\ui\ACM_I_Shitpost_UBPR_FMJackson.jpg";
		displayName = "Foreign Minister Jackson";
		uniformClass = "U_I_C_Soldier_Bandit_1_F";
		magazines[] = {"sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","vn_m10_mag","vn_m10_mag","vn_m10_mag","vn_m10_mag","vn_m10_mag","vn_m10_mag","vn_m10_mag","vn_m10_mag"};
		respawnMagazines[] = {"sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","vn_m10_mag","vn_m10_mag","vn_m10_mag","vn_m10_mag","vn_m10_mag","vn_m10_mag","vn_m10_mag","vn_m10_mag"};
		linkedItems[] = {"vn_b_vest_usarmy_04","ACM_Helmet_Mk5_Nostrap","G_Balaclava_blk","ACM_Misc_Clothband_Green","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_04","ACM_Helmet_Mk5_Nostrap","G_Balaclava_blk","ACM_Misc_Clothband_Green","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"sp_fwa_enfield_no4_walnut","vn_p38s","Throw","Put"};
		respawnweapons[] = {"sp_fwa_enfield_no4_walnut","vn_p38s","Throw","Put"};
		identityTypes[] = {"LanguageENGB_F","Head_Euro"};
	};
	class ACM_I_Shitpost_UBPR_DMRadcliffe: ACM_I_Shitpost_UBPR_PMMcKendrick
	{
		editorPreview = "\acm_saintanselm\ui\ACM_I_Shitpost_UBPR_DMRadcliffe.jpg";
		displayName = "Defence Minister Radcliffe";
		uniformClass = "U_I_C_Soldier_Bandit_3_F";
		magazines[] = {"sp_fwa_20Rnd_762_ar10_Tracer","sp_fwa_20Rnd_762_ar10_Tracer","sp_fwa_20Rnd_762_ar10_Tracer","sp_fwa_20Rnd_762_ar10_Tracer","sp_fwa_20Rnd_762_ar10_Tracer","sp_fwa_20Rnd_762_ar10_Tracer","sp_fwa_20Rnd_762_ar10_Tracer","sp_fwa_20Rnd_762_ar10_Tracer","sp_fwa_20Rnd_762_ar10_Tracer","sp_fwa_20Rnd_762_ar10_Tracer"};
		respawnMagazines[] = {"sp_fwa_20Rnd_762_ar10_Tracer","sp_fwa_20Rnd_762_ar10_Tracer","sp_fwa_20Rnd_762_ar10_Tracer","sp_fwa_20Rnd_762_ar10_Tracer","sp_fwa_20Rnd_762_ar10_Tracer","sp_fwa_20Rnd_762_ar10_Tracer","sp_fwa_20Rnd_762_ar10_Tracer","sp_fwa_20Rnd_762_ar10_Tracer","sp_fwa_20Rnd_762_ar10_Tracer","sp_fwa_20Rnd_762_ar10_Tracer"};
		linkedItems[] = {"vn_o_vest_02","ACM_Helmet_Mk5_Nostrap","ACM_Misc_Clothband_Green","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_o_vest_02","ACM_Helmet_Mk5_Nostrap","ACM_Misc_Clothband_Green","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"sp_fwa_ar10_od","vn_fkb1","Throw","Put"};
		respawnweapons[] = {"sp_fwa_ar10_od","vn_fkb1","Throw","Put"};
		identityTypes[] = {"LanguageENGB_F","Head_Euro"};
	};
	class vn_b_pack_p44_02;
	class vn_b_pack_lw_07;
	class vn_b_pack_pfield_01;
	class acm_bag_sam_medic: vn_b_pack_lw_07
	{
		ScopeArsenal = 1;
		scope = 1;
		class TransportItems
		{
			class _xx_vn_b_item_medikit_01
			{
				name = "vn_b_item_medikit_01";
				count = 1;
			};
			class _xx_vn_b_item_firstaidkit
			{
				name = "vn_b_item_firstaidkit";
				count = 10;
			};
		};
	};
	class vn_b_pack_lw_05;
	class acm_bag_sam_hmg: vn_b_pack_lw_05
	{
		ScopeArsenal = 1;
		scope = 1;
		class TransportMagazines
		{
			class _xx_sp_fwa_200Rnd_762_mag
			{
				magazine = "sp_fwa_30Rnd_Curved_762_FAL_Metric";
				count = 20;
			};
		};
	};
	class acm_bag_sam_grenadier: vn_b_pack_lw_05
	{
		ScopeArsenal = 1;
		scope = 1;
		class TransportMagazines
		{
			class _xx_sp_fwa_1rnd_riflegrenade_mas_ap
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_ap";
				count = 4;
			};
			class _xx_sp_fwa_1rnd_riflegrenade_mas_wp
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_wp";
				count = 2;
			};
			class _xx_sp_fwa_1rnd_riflegrenade_mas_at_l
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_at_l";
				count = 2;
			};
		};
	};
	class vn_b_pack_lw_02;
	class acm_bag_sam_demo: vn_b_pack_lw_02
	{
		ScopeArsenal = 1;
		scope = 1;
		class TransportItems
		{
			class _xx_vn_b_item_toolkit
			{
				name = "vn_b_item_toolkit";
				count = 1;
			};
		};
		class TransportMagazines
		{
			class _xx_vn_mine_m112_remote_mag
			{
				magazine = "vn_mine_m112_remote_mag";
				count = 2;
			};
			class _xx_vn_mine_tripwire_m49_02_mag
			{
				magazine = "vn_mine_tripwire_m49_02_mag";
				count = 1;
			};
			class _xx_vn_mine_m18_x3_range_mag
			{
				magazine = "vn_mine_m18_x3_range_mag";
				count = 1;
			};
			class _xx_vn_mine_satchel_remote_02_mag
			{
				magazine = "vn_mine_satchel_remote_02_mag";
				count = 1;
			};
			class _xx_vn_mine_tm57_mag
			{
				magazine = "vn_mine_tm57_mag";
				count = 1;
			};
		};
	};
	class acm_bag_sam_MG: vn_b_pack_p44_02
	{
		ScopeArsenal = 1;
		scope = 1;
		class TransportMagazines
		{
			class _xx_vn_l1a1_30_02_t_mag
			{
				magazine = "vn_l1a1_30_02_t_mag";
				count = 12;
			};
		};
	};
	class acm_bag_sam_SF_grenadier: vn_b_pack_pfield_01
	{
		ScopeArsenal = 1;
		scope = 1;
		class TransportMagazines
		{
			class _xx_vn_40mm_m406_he_mag
			{
				magazine = "vn_40mm_m406_he_mag";
				count = 9;
			};
			class _xx_vn_40mm_m583_flare_w_mag
			{
				magazine = "vn_40mm_m583_flare_w_mag";
				count = 3;
			};
			class _xx_vn_40mm_m680_smoke_w_mag
			{
				magazine = "vn_40mm_m680_smoke_w_mag";
				count = 4;
			};
		};
	};
	class acm_bag_sam_2035_MG: vn_b_pack_lw_02
	{
		ScopeArsenal = 1;
		scope = 1;
		class TransportMagazines
		{
			class _xx_100Rnd_65x39_caseless_black_mag
			{
				magazine = "100Rnd_65x39_caseless_black_mag";
				count = 10;
			};
		};
	};
	class vn_b_pack_trp_03_02;
	class acm_bag_sam_2035_AT: vn_b_pack_trp_03_02
	{
		ScopeArsenal = 1;
		scope = 1;
		class TransportMagazines
		{
			class _xx_MRAWS_HEAT_F
			{
				magazine = "MRAWS_HEAT_F";
				count = 2;
			};
		};
	};
	class ACM_o_alci_men_rifleman: B_Survivor_F
	{
		faction = "ACM_O_ATIU";
		side = 0;
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_men_rifleman.jpg";
		displayName = "Rifleman";
		nakedUniform = "vn_b_uniform_basecharacter_01";
		uniformClass = "acm_sam_clothes02_1";
		items[] = {"vn_b_item_firstaidkit","vn_b_item_firstaidkit"};
		respawnItems[] = {"vn_b_item_firstaidkit","vn_b_item_firstaidkit"};
		magazines[] = {"sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		respawnMagazines[] = {"sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		linkedItems[] = {"vn_o_vest_02","vn_b_helmet_m1_01_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_o_vest_02","vn_b_helmet_m1_01_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"sp_fwa_enfield_no5_beech_old","Throw","Put"};
		respawnweapons[] = {"sp_fwa_enfield_no5_beech_old","Throw","Put"};
		identityTypes[] = {"LanguageGRE_F","vn_b_camo_us","Head_Euro"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Rifleman";
		accuracy = 2.3;
		camouflage = 1.4;
		minFireTime = 7;
	};
	class ACM_o_alci_men_rifleman_2: ACM_o_alci_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_men_rifleman_2.jpg";
		displayName = "Rifleman 2";
		uniformClass = "acm_sam_clothes02_2";
		magazines[] = {"sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		respawnMagazines[] = {"sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		linkedItems[] = {"vn_o_vest_02","vn_b_boonie_01_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_o_vest_02","vn_b_boonie_01_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"sp_fwa_enfield_no5_beech_old","Throw","Put"};
		respawnweapons[] = {"sp_fwa_enfield_no5_beech_old","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Rifleman";
		accuracy = 2.3;
		camouflage = 1.4;
		minFireTime = 7;
	};
	class ACM_o_alci_men_rifleman_3: ACM_o_alci_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_men_rifleman_3.jpg";
		displayName = "Rifleman 3 (FN-49)";
		uniformClass = "acm_sam_clothes02_2";
		magazines[] = {"sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		respawnMagazines[] = {"sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		linkedItems[] = {"vn_b_vest_seal_05","vn_b_helmet_m1_07_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_seal_05","vn_b_helmet_m1_07_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"sp_fwa_fn49_arg","Throw","Put"};
		respawnweapons[] = {"sp_fwa_fn49_arg","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Rifleman";
		accuracy = 2.3;
		camouflage = 1.4;
		minFireTime = 7;
	};
	class ACM_o_alci_men_rifleman_AT: ACM_o_alci_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_men_rifleman_AT.jpg";
		displayName = "Rifleman (AT)";
		uniformClass = "acm_sam_clothes02_1";
		magazines[] = {"sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m72_mag"};
		respawnMagazines[] = {"sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m72_mag"};
		linkedItems[] = {"vn_o_vest_02","vn_i_helmet_m1_02_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_o_vest_02","vn_i_helmet_m1_02_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"sp_fwa_enfield_no5_beech_old","vn_m72","Throw","Put"};
		respawnweapons[] = {"sp_fwa_enfield_no5_beech_old","vn_m72","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_AT_s"};
				speechPlural[] = {"veh_infantry_AT_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_AT_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_AT_p";
		nameSound = "veh_infantry_AT_s";
		icon = "iconManAT";
		role = "MissileSpecialist";
		cost = 130000;
		secondaryAmmoCoef = 0.5;
		threat[] = {0.8,0.8,0.3};
	};
	class ACM_o_alci_men_SL: ACM_o_alci_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_men_SL.jpg";
		displayName = "Squad Lead";
		uniformClass = "acm_sam_clothes02_3";
		magazines[] = {"sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_m127_mag","vn_m127_mag"};
		respawnMagazines[] = {"sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_hp_mag","vn_hp_mag","vn_hp_mag","vn_m127_mag","vn_m127_mag"};
		linkedItems[] = {"vn_o_vest_07","vn_i_helmet_m1_03_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_o_vest_07","vn_i_helmet_m1_03_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"sp_fwa_fn49_arg","vn_hp","vn_mk21_binocs","vn_m127","Throw","Put"};
		respawnweapons[] = {"sp_fwa_fn49_arg","vn_hp","vn_mk21_binocs","vn_m127","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		icon = "iconManLeader";
		role = "RadioOperator";
		cost = 250000;
	};
	class ACM_o_alci_men_RTO: ACM_o_alci_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_men_RTO.jpg";
		displayName = "RTO";
		uniformClass = "acm_sam_clothes02_2";
		magazines[] = {"sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		respawnMagazines[] = {"sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		linkedItems[] = {"vn_o_vest_01","vn_b_helmet_m1_01_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_o_vest_01","vn_b_helmet_m1_01_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"sp_fwa_enfield_no5_beech_old","Throw","Put"};
		respawnweapons[] = {"sp_fwa_enfield_no5_beech_old","Throw","Put"};
		backpack = "vn_b_pack_prc77_01";
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		icon = "iconManLeader";
		role = "Grenadier";
		cost = 250000;
	};
	class ACM_o_alci_men_RTO2: ACM_o_alci_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_men_RTO2.jpg";
		displayName = "RTO 2";
		uniformClass = "acm_sam_clothes02_4";
		magazines[] = {"vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		respawnMagazines[] = {"vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		linkedItems[] = {"vn_o_vest_01","vn_b_helmet_m1_01_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_o_vest_01","vn_b_helmet_m1_01_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"vn_m1a1_tommy","Throw","Put"};
		respawnweapons[] = {"vn_m1a1_tommy","Throw","Put"};
		backpack = "vn_b_pack_prc77_01";
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		icon = "iconManLeader";
		role = "Grenadier";
		cost = 250000;
	};
	class ACM_o_alci_men_MG: ACM_o_alci_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_men_MG.jpg";
		displayName = "Machinegunner";
		uniformClass = "acm_sam_clothes02_2";
		magazines[] = {"vn_m1918_t_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		respawnMagazines[] = {"vn_m1918_t_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		linkedItems[] = {"vn_b_vest_usarmy_06","vn_i_helmet_m1_03_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_06","vn_i_helmet_m1_03_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"vn_m1918_bipod","vn_m1911","Throw","Put"};
		respawnweapons[] = {"vn_m1918_bipod","vn_m1911","Throw","Put"};
		backpack = "acm_bag_AL_MG";
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_MG_s"};
				speechPlural[] = {"veh_infantry_MG_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_MG_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_MG_p";
		nameSound = "veh_infantry_MG_s";
		icon = "iconManMG";
		role = "MachineGunner";
		cost = 220000;
	};
	class ACM_o_alci_men_Medic: ACM_o_alci_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_men_Medic.jpg";
		displayName = "Medic";
		uniformClass = "acm_sam_clothes02_1";
		magazines[] = {"sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		respawnMagazines[] = {"sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		linkedItems[] = {"vn_o_vest_vc_04","vn_b_helmet_m1_07_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_o_vest_vc_04","vn_b_helmet_m1_07_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"sp_fwa_fn49_arg","Throw","Put"};
		respawnweapons[] = {"sp_fwa_fn49_arg","Throw","Put"};
		backpack = "acm_bag_sam_medic";
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_medic_s"};
				speechPlural[] = {"veh_infantry_medic_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_medic_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_medic_p";
		nameSound = "veh_infantry_medic_s";
		icon = "iconManMedic";
		picture = "pictureHeal";
		role = "CombatLifeSaver";
		attendant = 1;
	};
	class ACM_o_alci_men_Marksman: ACM_o_alci_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_men_Marksman.jpg";
		displayName = "Marksman";
		uniformClass = "acm_sam_clothes02_1";
		magazines[] = {"sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		respawnMagazines[] = {"sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		linkedItems[] = {"vn_b_vest_usarmy_04","vn_b_boonie_02_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_04","vn_b_boonie_02_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"acm_fwa_acillo_marksman","vn_m19_binocs_grey","Throw","Put"};
		respawnweapons[] = {"acm_fwa_acillo_marksman","vn_m19_binocs_grey","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_sniper_s"};
				speechPlural[] = {"veh_infantry_sniper_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_sniper_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_sniper_p";
		nameSound = "veh_infantry_sniper_s";
		role = "Marksman";
		cost = 250000;
	};
	class ACM_o_alci_men_Demo: ACM_o_alci_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_men_Demo.jpg";
		displayName = "Demolitions";
		uniformClass = "acm_sam_clothes02_1";
		magazines[] = {"sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_mine_m14_mag","vn_mine_m14_mag","vn_mine_m112_remote_mag","vn_mine_tm57_mag","vn_mine_m18_x3_range_mag"};
		respawnMagazines[] = {"sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_mine_m14_mag","vn_mine_m14_mag","vn_mine_m112_remote_mag","vn_mine_tm57_mag","vn_mine_m18_x3_range_mag"};
		linkedItems[] = {"vn_o_vest_08","vn_b_helmet_m1_01_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_o_vest_08","vn_b_helmet_m1_01_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"sp_fwa_enfield_no5_beech_old","Throw","Put"};
		respawnweapons[] = {"sp_fwa_enfield_no5_beech_old","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		icon = "iconManEngineer";
		picture = "pictureRepair";
		role = "Sapper";
		canDeactivateMines = 1;
		cost = 93000;
		detectSkill = 38;
		engineer = 1;
	};
	class ACM_o_alci_men_Gunner: ACM_o_alci_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_men_Gunner.jpg";
		displayName = "Gunner 1";
		uniformClass = "acm_sam_clothes02_2";
		magazines[] = {"sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		respawnMagazines[] = {"sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		linkedItems[] = {"vn_b_vest_usarmy_12","vn_b_helmet_m1_01_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_12","vn_b_helmet_m1_01_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"sp_fwa_enfield_no5_beech_old","Throw","Put"};
		respawnweapons[] = {"sp_fwa_enfield_no5_beech_old","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		icon = "iconManEngineer";
		picture = "pictureRepair";
		role = "Sapper";
		canDeactivateMines = 1;
		cost = 93000;
		detectSkill = 38;
		engineer = 1;
	};
	class ACM_o_alci_men_Gunner2: ACM_o_alci_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_men_Gunner2.jpg";
		displayName = "Gunner 2";
		uniformClass = "acm_sam_clothes02_4";
		magazines[] = {"vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		respawnMagazines[] = {"vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		linkedItems[] = {"vn_b_vest_usarmy_11","vn_b_helmet_m1_01_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_11","vn_b_helmet_m1_01_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"vn_m1911","Throw","Put"};
		respawnweapons[] = {"vn_m1911","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		icon = "iconManEngineer";
		picture = "pictureRepair";
		role = "Sapper";
		canDeactivateMines = 1;
		cost = 93000;
		detectSkill = 38;
		engineer = 1;
	};
	class ACM_o_alci_men_Trench: ACM_o_alci_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_men_Trench.jpg";
		displayName = "Trench Fighter";
		uniformClass = "acm_sam_clothes02_4";
		magazines[] = {"vn_mp40_mag","vn_mp40_mag","vn_mp40_mag","vn_mp40_mag","vn_mp40_mag","vn_mp40_mag","vn_mp40_mag","vn_mp40_mag","vn_mp40_mag","vn_mp40_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag"};
		respawnMagazines[] = {"vn_mp40_mag","vn_mp40_mag","vn_mp40_mag","vn_mp40_mag","vn_mp40_mag","vn_mp40_mag","vn_mp40_mag","vn_mp40_mag","vn_mp40_mag","vn_mp40_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag"};
		linkedItems[] = {"vn_o_vest_01","vn_b_helmet_m1_09_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_o_vest_01","vn_b_helmet_m1_09_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"vn_mp40","Throw","Put"};
		respawnweapons[] = {"vn_mp40","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Rifleman";
		accuracy = 2.3;
		camouflage = 1.4;
		minFireTime = 7;
	};
	class ACM_o_alci_men_cg: ACM_o_alci_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_men_cg.jpg";
		displayName = "Coast Guard 1";
		uniformClass = "acm_sam_clothes02_2";
		magazines[] = {"sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		respawnMagazines[] = {"sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","sp_fwa_10Rnd_303_No4","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		linkedItems[] = {"vn_b_vest_seal_04","vn_i_helmet_m1_02_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_seal_04","vn_i_helmet_m1_02_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"sp_fwa_enfield_no5_beech_old","Throw","Put"};
		respawnweapons[] = {"sp_fwa_enfield_no5_beech_old","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Rifleman";
		accuracy = 2.3;
		camouflage = 1.4;
		minFireTime = 7;
	};
	class ACM_o_alci_men_cg2: ACM_o_alci_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_men_cg2.jpg";
		displayName = "Coast Guard 2";
		uniformClass = "acm_sam_clothes02_4";
		magazines[] = {"vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		respawnMagazines[] = {"vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		linkedItems[] = {"vn_b_vest_seal_02","vn_b_helmet_m1_01_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_seal_02","vn_b_helmet_m1_01_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"vn_m1a1_tommy","Throw","Put"};
		respawnweapons[] = {"vn_m1a1_tommy","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Rifleman";
		accuracy = 2.3;
		camouflage = 1.4;
		minFireTime = 7;
	};
	class ACM_o_alci_men_grenadier: ACM_o_alci_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_men_grenadier.jpg";
		displayName = "Grenadier";
		uniformClass = "acm_sam_clothes02_3";
		magazines[] = {"sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_1rnd_riflegrenade_mas_wp","sp_fwa_1rnd_riflegrenade_mas_wp"};
		respawnMagazines[] = {"sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_20Rnd_762_FN49","sp_fwa_1rnd_riflegrenade_mas_wp","sp_fwa_1rnd_riflegrenade_mas_wp"};
		linkedItems[] = {"vn_o_vest_01","vn_i_helmet_m1_03_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_o_vest_01","vn_i_helmet_m1_03_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"sp_fwa_fn49_arg","Throw","Put"};
		respawnweapons[] = {"sp_fwa_fn49_arg","Throw","Put"};
		backpack = "acm_bag_AL_GL";
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Grenadier";
		cost = 200000;
	};
	class ACM_o_alci_men_crew: ACM_o_alci_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_men_crew.jpg";
		displayName = "Crew";
		uniformClass = "acm_sam_clothes02_2";
		magazines[] = {"vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag"};
		respawnMagazines[] = {"vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag","vn_m1a1_30_mag"};
		linkedItems[] = {"vn_b_vest_usarmy_12","vn_b_helmet_t56_02_03","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_12","vn_b_helmet_t56_02_03","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"vn_m1a1_tommy","Throw","Put"};
		respawnweapons[] = {"vn_m1a1_tommy","Throw","Put"};
		identityTypes[] = {"LanguageGRE_F","Head_Euro"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Crewman";
		camouflage = 2;
		cost = 93000;
		engineer = 1;
	};
	class ACM_o_alci_men_officer: ACM_o_alci_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_men_officer.jpg";
		displayName = "Officer";
		uniformClass = "acm_sam_clothes02_1";
		magazines[] = {"vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag"};
		respawnMagazines[] = {"vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag"};
		linkedItems[] = {"vn_o_vest_vc_05","vn_b_helmet_m1_01_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_o_vest_vc_05","vn_b_helmet_m1_01_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"vn_m1911","vn_mk21_binocs","Throw","Put"};
		respawnweapons[] = {"vn_m1911","vn_mk21_binocs","Throw","Put"};
		identityTypes[] = {"LanguageGRE_F","Head_Euro"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_officer_s"};
				speechPlural[] = {"veh_infantry_officer_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_officer_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_officer_p";
		nameSound = "veh_infantry_officer_s";
		icon = "iconManOfficer";
		role = "Rifleman";
		camouflage = 1.6;
		cost = 250000;
	};
	class ACM_o_alci_men_Pilot: ACM_o_alci_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_men_Pilot.jpg";
		displayName = "Rotary-Wing Pilot";
		uniformClass = "acm_sam_clothes02_5";
		magazines[] = {"vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag"};
		respawnMagazines[] = {"vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag"};
		linkedItems[] = {"vn_b_vest_aircrew_05","vn_b_helmet_svh4_02_05","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_aircrew_05","vn_b_helmet_svh4_02_05","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"vn_m1911","Throw","Put"};
		respawnweapons[] = {"vn_m1911","Throw","Put"};
		identityTypes[] = {"LanguageGRE_F","Head_Euro"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Crewman";
		camouflage = 2;
		cost = 93000;
		engineer = 1;
	};
	class ACM_o_alci_men_unarmed: ACM_o_alci_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_men_unarmed.jpg";
		displayName = "Rifleman (Unarmed)";
		weapons[] = {"Throw","Put"};
		respawnWeapons[] = {"Throw","Put"};
		magazines[] = {};
		respawnMagazines[] = {};
		role = "Unarmed";
		threat[] = {0.1,0.1,0.1};
	};
	class ACM_o_alci_men_survivor: ACM_o_alci_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_men_survivor.jpg";
		displayName = "Survivor";
		uniformClass = "acm_sam_clothes02_2";
		linkedItems[] = {"vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"Throw","Put"};
		respawnWeapons[] = {"Throw","Put"};
		magazines[] = {};
		respawnMagazines[] = {};
		role = "Unarmed";
		threat[] = {0.1,0.1,0.1};
	};
	class ACM_o_alci_men_KneeMortar: ACM_o_alci_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_men_KneeMortar.jpg";
		displayName = "Rifleman (Mortar)";
		uniformClass = "acm_sam_clothes02_2";
		linkedItems[] = {"vn_b_vest_usarmy_05","vn_i_helmet_m1_02_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_05","vn_i_helmet_m1_02_01","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"sp_fwa_enfield_no5","sp_fwa_2InchMortar","Throw","Put"};
		respawnweapons[] = {"sp_fwa_enfield_no5","sp_fwa_2InchMortar","Throw","Put"};
		backpack = "acm_bag_AL_Mortar";
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Rifleman";
		accuracy = 2.3;
		camouflage = 1.4;
		minFireTime = 7;
	};
	class ACM_o_alci_men_SF_Scout: ACM_o_alci_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_men_SF_Scout.jpg";
		displayName = "Recon Scout";
		uniformClass = "acm_sam_clothes02_3";
		magazines[] = {"vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		respawnMagazines[] = {"vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		linkedItems[] = {"vn_b_vest_seal_05","vn_b_boonie_01_04","G_Bandanna_oli","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_seal_05","vn_b_boonie_01_04","G_Bandanna_oli","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"acm_vn_m3a1_suppress","Throw","Put"};
		respawnweapons[] = {"acm_vn_m3a1_suppress","Throw","Put"};
		editorSubcategory = "EdSubcat_Personnel_SpecialForces";
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_SF_s"};
				speechPlural[] = {"veh_infantry_SF_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_SF_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_SF_p";
		nameSound = "veh_infantry_SF_s";
		role = "Rifleman";
		camouflage = 0.6;
		detectSkill = 18;
	};
	class ACM_o_alci_men_SF_TL: ACM_o_alci_men_SF_Scout
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_men_SF_TL.jpg";
		displayName = "Recon Team Lead";
		uniformClass = "acm_sam_clothes02_3";
		magazines[] = {"vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m127_mag","vn_m127_mag"};
		respawnMagazines[] = {"vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m127_mag","vn_m127_mag"};
		linkedItems[] = {"vn_b_vest_seal_02","vn_b_helmet_m1_06_01","G_Bandanna_oli","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_seal_02","vn_b_helmet_m1_06_01","G_Bandanna_oli","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"vn_m16_sd","vn_anpvs2_binoc","vn_m127","Throw","Put"};
		respawnweapons[] = {"vn_m16_sd","vn_anpvs2_binoc","vn_m127","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_SF_s"};
				speechPlural[] = {"veh_infantry_SF_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_SF_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_SF_p";
		nameSound = "veh_infantry_SF_s";
		icon = "iconManLeader";
		role = "RadioOperator";
		camouflage = 0.6;
		cost = 250000;
		detectSkill = 18;
	};
	class ACM_o_alci_men_SF_NF: ACM_o_alci_men_SF_Scout
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_men_SF_NF.jpg";
		displayName = "Recon Night Fighter";
		uniformClass = "acm_sam_clothes02_1";
		magazines[] = {"vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m127_mag","vn_m127_mag"};
		respawnMagazines[] = {"vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m127_mag","vn_m127_mag"};
		linkedItems[] = {"vn_b_vest_seal_04","vn_b_boonie_03_04","G_Bandanna_oli","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_seal_04","vn_b_boonie_03_04","G_Bandanna_oli","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"vn_m16_nvg_sd","vn_m127","Throw","Put"};
		respawnweapons[] = {"vn_m16_nvg_sd","vn_m127","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_SF_s"};
				speechPlural[] = {"veh_infantry_SF_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_SF_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_SF_p";
		nameSound = "veh_infantry_SF_s";
		role = "Rifleman";
		camouflage = 0.6;
		detectSkill = 18;
	};
	class ACM_o_alci_men_SF_AR: ACM_o_alci_men_SF_Scout
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_men_SF_AR.jpg";
		displayName = "Recon Autorifleman";
		uniformClass = "acm_sam_clothes02_3";
		magazines[] = {"vn_m63a_150_mag","vn_m63a_150_mag","vn_m63a_150_mag","vn_m63a_150_mag","vn_m63a_150_mag","vn_m63a_150_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m127_mag","vn_m127_mag"};
		respawnMagazines[] = {"vn_m63a_150_mag","vn_m63a_150_mag","vn_m63a_150_mag","vn_m63a_150_mag","vn_m63a_150_mag","vn_m63a_150_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m127_mag","vn_m127_mag"};
		linkedItems[] = {"vn_b_vest_seal_03","vn_b_helmet_m1_08_01","G_Bandanna_oli","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_seal_03","vn_b_helmet_m1_08_01","G_Bandanna_oli","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"vn_m63a_cdo","vn_m127","Throw","Put"};
		respawnweapons[] = {"vn_m63a_cdo","vn_m127","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_MG_s"};
				speechPlural[] = {"veh_infantry_MG_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_MG_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_MG_p";
		nameSound = "veh_infantry_MG_s";
		icon = "iconManMG";
		role = "MachineGunner";
		camouflage = 0.6;
		cost = 220000;
		detectSkill = 38;
	};
	class ACM_o_alci_men_SF_CLS: ACM_o_alci_men_SF_Scout
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_men_SF_CLS.jpg";
		displayName = "Recon CLS";
		uniformClass = "acm_sam_clothes02_4";
		magazines[] = {"vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		respawnMagazines[] = {"vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		linkedItems[] = {"vn_b_vest_seal_06","vn_b_boonie_02_04","G_Bandanna_blk","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_seal_06","vn_b_boonie_02_04","G_Bandanna_blk","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"acm_vn_m3a1_suppress","Throw","Put"};
		respawnweapons[] = {"acm_vn_m3a1_suppress","Throw","Put"};
		backpack = "acm_bag_sam_medic";
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_medic_s"};
				speechPlural[] = {"veh_infantry_medic_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_medic_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_medic_p";
		nameSound = "veh_infantry_medic_s";
		icon = "iconManMedic";
		picture = "pictureHeal";
		role = "CombatLifeSaver";
		attendant = 1;
		camouflage = 0.6;
		detectSkill = 18;
	};
	class ACM_o_alci_men_SF_GR: ACM_o_alci_men_SF_Scout
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_men_SF_GR.jpg";
		displayName = "Recon Grenadier";
		uniformClass = "acm_sam_clothes02_2";
		magazines[] = {"vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_40mm_m680_smoke_w_mag","vn_40mm_m680_smoke_w_mag","vn_40mm_m680_smoke_w_mag","vn_40mm_m651_cs_mag","vn_40mm_m583_flare_w_mag","vn_40mm_m583_flare_w_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag"};
		respawnMagazines[] = {"vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m16_20_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_40mm_m680_smoke_w_mag","vn_40mm_m680_smoke_w_mag","vn_40mm_m680_smoke_w_mag","vn_40mm_m651_cs_mag","vn_40mm_m583_flare_w_mag","vn_40mm_m583_flare_w_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag","vn_40mm_m381_he_mag"};
		linkedItems[] = {"vn_b_vest_seal_07","vn_b_helmet_m1_04_01","G_Bandanna_oli","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_seal_07","vn_b_helmet_m1_04_01","G_Bandanna_oli","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"vn_m16_xm148","Throw","Put"};
		respawnweapons[] = {"vn_m16_xm148","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_SF_s"};
				speechPlural[] = {"veh_infantry_SF_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_SF_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_SF_p";
		nameSound = "veh_infantry_SF_s";
		role = "Grenadier";
		camouflage = 0.6;
		cost = 200000;
		detectSkill = 18;
	};
	class ACM_o_alci_men_SF_Demo: ACM_o_alci_men_SF_Scout
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_men_SF_Demo.jpg";
		displayName = "Recon Demolitions";
		uniformClass = "acm_sam_clothes02_3";
		magazines[] = {"vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		respawnMagazines[] = {"vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m3a1_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		linkedItems[] = {"vn_o_vest_08","vn_b_helmet_m1_09_01","G_Bandanna_oli","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_o_vest_08","vn_b_helmet_m1_09_01","G_Bandanna_oli","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"acm_vn_m3a1_suppress","Throw","Put"};
		respawnweapons[] = {"acm_vn_m3a1_suppress","Throw","Put"};
		backpack = "acm_bag_alc_demo";
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_SF_s"};
				speechPlural[] = {"veh_infantry_SF_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_SF_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_SF_p";
		nameSound = "veh_infantry_SF_s";
		icon = "iconManEngineer";
		picture = "pictureRepair";
		role = "Sapper";
		canDeactivateMines = 1;
		camouflage = 0.6;
		detectSkill = 38;
	};
	class ACM_o_alci_men_SF_MR: ACM_o_alci_men_SF_Scout
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_men_SF_MR.jpg";
		displayName = "Recon Marksman";
		uniformClass = "acm_sam_clothes02_1";
		magazines[] = {"vn_m14_mag","vn_m14_mag","vn_m14_mag","vn_m14_mag","vn_m14_mag","vn_m14_mag","vn_m14_mag","vn_m14_mag","vn_m14_mag","vn_m14_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		respawnMagazines[] = {"vn_m14_mag","vn_m14_mag","vn_m14_mag","vn_m14_mag","vn_m14_mag","vn_m14_mag","vn_m14_mag","vn_m14_mag","vn_m14_mag","vn_m14_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m61_grenade_mag","vn_m61_grenade_mag"};
		linkedItems[] = {"vn_b_vest_sog_05","vn_b_bandana_04","G_Bandanna_oli","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_vest_sog_05","vn_b_bandana_04","G_Bandanna_oli","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		weapons[] = {"acm_vn_m14_sd_marksman","vn_mx991_m1911","Throw","Put"};
		respawnweapons[] = {"acm_vn_m14_sd_marksman","vn_mx991_m1911","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_sniper_s"};
				speechPlural[] = {"veh_infantry_sniper_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_sniper_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_sniper_p";
		nameSound = "veh_infantry_sniper_s";
		role = "Marksman";
		camouflage = 0.6;
		cost = 250000;
		detectSkill = 18;
	};
	class acm_bag_AL_MG: vn_b_pack_lw_02
	{
		ScopeArsenal = 1;
		scope = 1;
		class TransportMagazines
		{
			class _xx_vn_m1918_t_mag
			{
				magazine = "vn_m1918_t_mag";
				count = 20;
			};
		};
	};
	class vn_b_pack_lw_04;
	class acm_bag_alc_demo: vn_b_pack_lw_04
	{
		ScopeArsenal = 1;
		scope = 1;
		class TransportItems
		{
			class _xx_vn_b_item_toolkit
			{
				name = "vn_b_item_toolkit";
				count = 1;
			};
		};
		class TransportMagazines
		{
			class _xx_vn_mine_m112_remote_mag
			{
				magazine = "vn_mine_m112_remote_mag";
				count = 2;
			};
			class _xx_vn_mine_tripwire_m49_02_mag
			{
				magazine = "vn_mine_tripwire_m49_02_mag";
				count = 1;
			};
			class _xx_vn_mine_m18_x3_range_mag
			{
				magazine = "vn_mine_m18_x3_range_mag";
				count = 1;
			};
			class _xx_vn_mine_satchel_remote_02_mag
			{
				magazine = "vn_mine_satchel_remote_02_mag";
				count = 1;
			};
			class _xx_vn_mine_tm57_mag
			{
				magazine = "vn_mine_tm57_mag";
				count = 1;
			};
		};
	};
	class vn_o_pack_02;
	class acm_bag_AL_GL: vn_o_pack_02
	{
		ScopeArsenal = 1;
		scope = 1;
		class TransportMagazines
		{
			class _xx_sp_fwa_1rnd_riflegrenade_mas_ap
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_ap";
				count = 5;
			};
			class _xx_sp_fwa_1rnd_riflegrenade_mas_at_l
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_at_l";
				count = 3;
			};
		};
	};
	class acm_bag_AL_M_MG: vn_o_pack_02
	{
		ScopeArsenal = 1;
		scope = 1;
		class TransportMagazines
		{
			class _xx_sp_fwa_100Rnd_762_mag
			{
				magazine = "sp_fwa_100Rnd_762_mag";
				count = 4;
			};
		};
	};
	class vn_o_pack_03;
	class acm_bag_AL_M_AT: vn_o_pack_03
	{
		ScopeArsenal = 1;
		scope = 1;
		class TransportMagazines
		{
			class _xx_vn_rpg7_mag
			{
				magazine = "vn_rpg7_mag";
				count = 5;
			};
		};
	};
	class vn_o_pack_05;
	class acm_bag_AL_M_demo: vn_o_pack_05
	{
		ScopeArsenal = 1;
		scope = 1;
		class TransportItems
		{
			class _xx_vn_b_item_toolkit
			{
				name = "vn_b_item_toolkit";
				count = 1;
			};
		};
		class TransportMagazines
		{
			class _xx_vn_mine_m112_remote_mag
			{
				magazine = "vn_mine_m112_remote_mag";
				count = 2;
			};
			class _xx_vn_mine_tripwire_m49_02_mag
			{
				magazine = "vn_mine_tripwire_m49_02_mag";
				count = 1;
			};
			class _xx_vn_mine_m18_x3_range_mag
			{
				magazine = "vn_mine_m18_x3_range_mag";
				count = 1;
			};
			class _xx_vn_mine_satchel_remote_02_mag
			{
				magazine = "vn_mine_satchel_remote_02_mag";
				count = 1;
			};
			class _xx_vn_mine_tm57_mag
			{
				magazine = "vn_mine_tm57_mag";
				count = 1;
			};
		};
	};
	class vn_o_pack_08;
	class acm_bag_AL_Mortar: vn_o_pack_08
	{
		ScopeArsenal = 1;
		scope = 1;
		class TransportMagazines
		{
			class _xx_sp_fwa_2inch_he_mag
			{
				magazine = "sp_fwa_2inch_he_mag";
				count = 8;
			};
			class _xx_sp_fwa_2inch_wp_mag
			{
				magazine = "sp_fwa_2inch_wp_mag";
				count = 3;
			};
			class _xx_sp_fwa_2inch_flare_mag
			{
				magazine = "sp_fwa_2inch_flare_mag";
				count = 1;
			};
		};
	};
	class vn_o_pack_07;
	class acm_bag_AL_M_AT_SF: vn_o_pack_07
	{
		ScopeArsenal = 1;
		scope = 1;
		class TransportMagazines
		{
			class _xx_vn_rpg7_mag
			{
				magazine = "vn_rpg7_mag";
				count = 5;
			};
		};
	};
	class vn_o_pack_06;
	class acm_bag_AL_M_rifleman3: vn_o_pack_06
	{
		ScopeArsenal = 1;
		scope = 1;
		class TransportMagazines
		{
			class _xx_sp_fwa_1rnd_riflegrenade_mas_ap
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_ap";
				count = 3;
			};
			class _xx_sp_fwa_1rnd_riflegrenade_mas_at_l
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_at_l";
				count = 3;
			};
			class _xx_sp_fwa_1rnd_riflegrenade_mas_wp
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_wp";
				count = 2;
			};
		};
	};
	class ACM_b_sam_2035_men_rifleman: B_Survivor_F
	{
		faction = "ACM_B_SAC_2035";
		side = 1;
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_rifleman.jpg";
		displayName = "Rifleman";
		nakedUniform = "vn_b_uniform_basecharacter_01";
		uniformClass = "acm_sam_clothes_m_1_1";
		items[] = {"vn_b_item_firstaidkit","vn_b_item_firstaidkit"};
		respawnItems[] = {"vn_b_item_firstaidkit","vn_b_item_firstaidkit"};
		magazines[] = {"sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		respawnMagazines[] = {"sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		linkedItems[] = {"acm_sam_m_vest2","acm_pasgt_base","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_sam_m_vest2","acm_pasgt_base","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "vn_b_pack_lw_01";
		weapons[] = {"sp_fwa_fal_factory_50_64","Throw","Put"};
		respawnweapons[] = {"sp_fwa_fal_factory_50_64","Throw","Put"};
		identityTypes[] = {"LanguageENGB_F","vn_b_camo_us","Head_Euro"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Rifleman";
		accuracy = 2.3;
		camouflage = 1.4;
		minFireTime = 7;
	};
	class ACM_b_sam_2035_men_rifleman_2: ACM_b_sam_2035_men_rifleman
	{
		side = 1;
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_rifleman_2.jpg";
		displayName = "Rifleman 2";
		uniformClass = "acm_sam_clothes_m_1_1";
		linkedItems[] = {"acm_sam_m_vest1","acm_pasgt_esscover_front","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_sam_m_vest1","acm_pasgt_esscover_front","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "";
		weapons[] = {"sp_fwa_fal_factory_50_64","Throw","Put"};
		respawnweapons[] = {"sp_fwa_fal_factory_50_64","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Rifleman";
		accuracy = 2.3;
		camouflage = 1.4;
		minFireTime = 7;
	};
	class ACM_b_sam_2035_men_rifleman_3: ACM_b_sam_2035_men_rifleman
	{
		side = 1;
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_rifleman_3.jpg";
		displayName = "Rifleman 3";
		uniformClass = "acm_sam_clothes_m_1_1";
		linkedItems[] = {"acm_sam_m_vest2","acm_pasgt_scrim","acm_sam_g_bandana","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_sam_m_vest2","acm_pasgt_scrim","acm_sam_g_bandana","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "";
		weapons[] = {"sp_fwa_fal_factory_50_63","Throw","Put"};
		respawnweapons[] = {"sp_fwa_fal_factory_50_63","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Rifleman";
		accuracy = 2.3;
		camouflage = 1.4;
		minFireTime = 7;
	};
	class ACM_b_sam_2035_men_rifleman_light: ACM_b_sam_2035_men_rifleman
	{
		side = 1;
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_rifleman_light.jpg";
		displayName = "Rifleman (Light)";
		uniformClass = "acm_sam_clothes_m_1_2";
		linkedItems[] = {"vn_b_vest_seal_05","acm_pasgt_nocover","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"vn_b_vest_seal_05","acm_pasgt_nocover","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "";
		weapons[] = {"sp_fwa_fal_factory_50_64","Throw","Put"};
		respawnweapons[] = {"sp_fwa_fal_factory_50_64","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Rifleman";
		accuracy = 2.3;
		camouflage = 1.4;
		minFireTime = 7;
	};
	class ACM_b_sam_2035_men_rifleman_AT: ACM_b_sam_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_rifleman_AT.jpg";
		displayName = "Rifleman (AT)";
		uniformClass = "acm_sam_clothes_m_1_2";
		magazines[] = {"sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag","NLAW_F"};
		respawnMagazines[] = {"sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag","NLAW_F"};
		linkedItems[] = {"acm_sam_m_vest1","acm_pasgt_esscover_front","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_sam_m_vest1","acm_pasgt_esscover_front","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "vn_b_pack_lw_01";
		weapons[] = {"sp_fwa_fal_factory_50_64","launch_NLAW_F","Throw","Put"};
		respawnweapons[] = {"sp_fwa_fal_factory_50_64","launch_NLAW_F","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_AT_s"};
				speechPlural[] = {"veh_infantry_AT_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_AT_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_AT_p";
		nameSound = "veh_infantry_AT_s";
		icon = "iconManAT";
		role = "MissileSpecialist";
		cost = 130000;
		secondaryAmmoCoef = 0.5;
		threat[] = {0.8,0.8,0.3};
	};
	class ACM_b_sam_2035_men_SL: ACM_b_sam_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_SL.jpg";
		displayName = "Sergeant";
		uniformClass = "acm_sam_clothes_m_1_4";
		magazines[] = {"sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag","vn_m127_mag","vn_m127_mag","vn_m127_mag"};
		respawnMagazines[] = {"sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag","vn_m127_mag","vn_m127_mag","vn_m127_mag"};
		linkedItems[] = {"acm_sam_m_vest2","acm_pasgt_esscover_back","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_sam_m_vest2","acm_pasgt_esscover_back","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "vn_b_pack_trp_04_02";
		weapons[] = {"acm_sac_m_sp_fal64_scope","vn_m127","Rangefinder","Throw","Put"};
		respawnweapons[] = {"acm_sac_m_sp_fal64_scope","vn_m127","Rangefinder","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		icon = "iconManLeader";
		role = "RadioOperator";
		cost = 250000;
	};
	class ACM_b_sam_2035_men_MR: ACM_b_sam_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_MR.jpg";
		displayName = "Marksman";
		uniformClass = "acm_sam_clothes_m_1_4";
		magazines[] = {"20Rnd_762x51_Mag","20Rnd_762x51_Mag","20Rnd_762x51_Mag","20Rnd_762x51_Mag","20Rnd_762x51_Mag","20Rnd_762x51_Mag","20Rnd_762x51_Mag","20Rnd_762x51_Mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag","vn_m127_mag","vn_m127_mag","vn_m127_mag"};
		respawnMagazines[] = {"20Rnd_762x51_Mag","20Rnd_762x51_Mag","20Rnd_762x51_Mag","20Rnd_762x51_Mag","20Rnd_762x51_Mag","20Rnd_762x51_Mag","20Rnd_762x51_Mag","20Rnd_762x51_Mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag","vn_m127_mag","vn_m127_mag","vn_m127_mag"};
		linkedItems[] = {"acm_sam_m_vest1","acm_pasgt_scrim","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_sam_m_vest1","acm_pasgt_scrim","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "vn_b_pack_lw_05";
		weapons[] = {"arifle_SPAR_03_blk_MOS_Pointer_Bipod_F","Rangefinder","Throw","Put"};
		respawnweapons[] = {"arifle_SPAR_03_blk_MOS_Pointer_Bipod_F","Rangefinder","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		icon = "iconManLeader";
		role = "RadioOperator";
		cost = 250000;
	};
	class ACM_b_sam_2035_men_GR: ACM_b_sam_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_GR.jpg";
		displayName = "Grenadier";
		uniformClass = "acm_sam_clothes_m_1_2";
		linkedItems[] = {"acm_sam_m_vest2","acm_pasgt_goggles","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_sam_m_vest2","acm_pasgt_goggles","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "acm_bag_sam_grenadier";
		weapons[] = {"sp_fwa_fal_factory_50_64","Throw","Put"};
		respawnweapons[] = {"sp_fwa_fal_factory_50_64","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Grenadier";
		cost = 200000;
	};
	class ACM_b_sam_2035_men_EOD: ACM_b_sam_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_EOD.jpg";
		displayName = "EOD";
		uniformClass = "acm_sam_clothes_m_1_1";
		items[] = {"MineDetector","ToolKit"};
		Respawnitems[] = {"MineDetector","ToolKit"};
		magazines[] = {"30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01"};
		RespawnMagazines[] = {"30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01"};
		linkedItems[] = {"acm_sam_m_vest3","acm_pasgt_esscover_front","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_sam_m_vest3","acm_pasgt_esscover_front","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "";
		weapons[] = {"SMG_01_F","Throw","Put"};
		respawnweapons[] = {"SMG_01_F","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		icon = "iconManEngineer";
		picture = "pictureRepair";
		role = "Sapper";
		canDeactivateMines = 1;
		cost = 93000;
		detectSkill = 38;
		engineer = 1;
	};
	class ACM_b_sam_2035_men_AR: ACM_b_sam_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_AR.jpg";
		displayName = "Autorifleman";
		uniformClass = "acm_sam_clothes_m_1_4";
		magazines[] = {"sp_fwa_20Rnd_9mm_HiPower","sp_fwa_20Rnd_9mm_HiPower","sp_fwa_20Rnd_9mm_HiPower","sp_fwa_20Rnd_9mm_HiPower","vn_m67_grenade_mag","vn_m67_grenade_mag"};
		RespawnMagazines[] = {"sp_fwa_20Rnd_9mm_HiPower","sp_fwa_20Rnd_9mm_HiPower","sp_fwa_20Rnd_9mm_HiPower","sp_fwa_20Rnd_9mm_HiPower","vn_m67_grenade_mag","vn_m67_grenade_mag"};
		linkedItems[] = {"acm_sam_m_vest1","acm_pasgt_base","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_sam_m_vest1","acm_pasgt_base","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "vn_b_pack_lw_02_m60_pl";
		weapons[] = {"vn_m60","sp_fwa_l9a1_hipower","Throw","Put"};
		respawnweapons[] = {"vn_m60","sp_fwa_l9a1_hipower","Throw","Put"};
	};
	class ACM_b_sam_2035_men_Crew: ACM_b_sam_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_Crew.jpg";
		displayName = "Crewman";
		uniformClass = "acm_sam_clothes_m_1_3";
		magazines[] = {"30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","sp_fwa_20Rnd_9mm_HiPower","sp_fwa_20Rnd_9mm_HiPower","sp_fwa_20Rnd_9mm_HiPower"};
		RespawnMagazines[] = {"30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","sp_fwa_20Rnd_9mm_HiPower","sp_fwa_20Rnd_9mm_HiPower","sp_fwa_20Rnd_9mm_HiPower"};
		linkedItems[] = {"vn_b_vest_usarmy_13","vn_b_helmet_t56_02_01","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_13","vn_b_helmet_t56_02_01","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "";
		weapons[] = {"SMG_01_F","sp_fwa_l9a1_hipower","Throw","Put"};
		respawnweapons[] = {"SMG_01_F","sp_fwa_l9a1_hipower","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Crewman";
		camouflage = 2;
		cost = 93000;
		engineer = 1;
	};
	class ACM_b_sam_2035_men_Medic: ACM_b_sam_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_Medic.jpg";
		displayName = "Combat Life Saver";
		uniformClass = "acm_sam_clothes_m_1_4";
		linkedItems[] = {"acm_sam_m_vest2","acm_pasgt_base","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_sam_m_vest2","acm_pasgt_base","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "acm_bag_sam_medic";
		weapons[] = {"sp_fwa_fal_factory_50_63","Throw","Put"};
		respawnweapons[] = {"sp_fwa_fal_factory_50_63","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_medic_s"};
				speechPlural[] = {"veh_infantry_medic_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_medic_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_medic_p";
		nameSound = "veh_infantry_medic_s";
		icon = "iconManMedic";
		picture = "pictureHeal";
		role = "CombatLifeSaver";
		attendant = 1;
	};
	class ACM_b_sam_2035_men_RTO: ACM_b_sam_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_RTO.jpg";
		displayName = "RTO 1";
		uniformClass = "acm_sam_clothes_m_1_1";
		linkedItems[] = {"acm_sam_m_vest2","acm_pasgt_scrim","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_sam_m_vest2","acm_pasgt_scrim","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "vn_b_pack_lw_06";
		weapons[] = {"sp_fwa_fal_factory_50_63","Throw","Put"};
		respawnweapons[] = {"sp_fwa_fal_factory_50_63","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		icon = "iconManLeader";
		role = "Grenadier";
		cost = 250000;
	};
	class ACM_b_sam_2035_men_RTO2: ACM_b_sam_2035_men_RTO
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_RTO2.jpg";
		displayName = "RTO 2";
		uniformClass = "acm_sam_clothes_m_1_2";
		linkedItems[] = {"acm_sam_m_vest1","acm_sam_headwear_beret_anselm_headset","acm_sam_g_bandana","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_sam_m_vest1","acm_sam_headwear_beret_anselm_headset","acm_sam_g_bandana","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
	};
	class ACM_b_sam_2035_men_HAT: ACM_b_sam_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_HAT.jpg";
		displayName = "Heavy Anti-Tank";
		uniformClass = "acm_sam_clothes_m_1_1";
		linkedItems[] = {"acm_sam_m_vest1","acm_pasgt_goggles","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_sam_m_vest1","acm_pasgt_goggles","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "acm_bag_sam_2035_AT";
		weapons[] = {"sp_fwa_fal_factory_50_63","sp_fwa_m2_carlGustav_no78","Throw","Put"};
		respawnweapons[] = {"sp_fwa_fal_factory_50_63","sp_fwa_m2_carlGustav_no78","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_AT_s"};
				speechPlural[] = {"veh_infantry_AT_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_AT_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_AT_p";
		nameSound = "veh_infantry_AT_s";
		icon = "iconManAT";
		role = "MissileSpecialist";
		camouflage = 1.5;
		cost = 130000;
		secondaryAmmoCoef = 0.5;
		threat[] = {0.8,0.8,0.3};
	};
	class ACM_b_sam_2035_men_Demo: ACM_b_sam_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_Demo.jpg";
		displayName = "Demolitions";
		uniformClass = "acm_sam_clothes_m_1_3";
		linkedItems[] = {"acm_sam_m_vest3","acm_pasgt_esscover_front","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_sam_m_vest3","acm_pasgt_esscover_front","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "acm_bag_sam_demo";
		weapons[] = {"sp_fwa_fal_factory_50_63","Throw","Put"};
		respawnweapons[] = {"sp_fwa_fal_factory_50_63","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		icon = "iconManEngineer";
		picture = "pictureRepair";
		role = "Sapper";
		canDeactivateMines = 1;
		cost = 93000;
		detectSkill = 38;
		engineer = 1;
	};
	class ACM_b_sam_2035_men_UAV: ACM_b_sam_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_UAV.jpg";
		displayName = "UAV Specialist";
		uniformClass = "acm_sam_clothes_m_1_2";
		linkedItems[] = {"acm_sam_m_vest1","acm_sam_headwear_beret_anselm","G_Goggles_VR","ItemMap","ItemCompass","ItemWatch","ItemRadio","B_UavTerminal"};
		respawnLinkedItems[] = {"acm_sam_m_vest1","acm_sam_headwear_beret_anselm","G_Goggles_VR","ItemMap","ItemCompass","ItemWatch","ItemRadio","B_UavTerminal"};
		backpack = "B_UAV_01_backpack_F";
		weapons[] = {"sp_fwa_fal_factory_50_63"};
		respawnweapons[] = {"sp_fwa_fal_factory_50_63"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "SpecialOperative";
		uavHacker = 1;
	};
	class ACM_b_sam_2035_men_UGV: ACM_b_sam_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_UGV.jpg";
		displayName = "UGV Specialist";
		uniformClass = "acm_sam_clothes_m_1_1";
		linkedItems[] = {"acm_sam_m_vest1","acm_pasgt_nocover","G_Goggles_VR","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_sam_m_vest1","acm_pasgt_nocover","G_Goggles_VR","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "B_UGV_02_Demining_backpack_F";
		weapons[] = {"sp_fwa_fal_factory_50_63","ItemMap","ItemCompass","ItemWatch","ItemRadio","B_UavTerminal"};
		respawnweapons[] = {"sp_fwa_fal_factory_50_63","ItemMap","ItemCompass","ItemWatch","ItemRadio","B_UavTerminal"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "SpecialOperative";
		uavHacker = 1;
	};
	class ACM_b_sam_2035_men_AA: ACM_b_sam_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_AA.jpg";
		displayName = "MANPAD Operator";
		uniformClass = "acm_sam_clothes_m_1_1";
		linkedItems[] = {"acm_sam_m_vest2","acm_pasgt_esscover_back","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_sam_m_vest2","acm_pasgt_esscover_back","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "";
		magazines[] = {"sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","vn_sa7_mag"};
		respawnMagazines[] = {"sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer","vn_sa7_mag"};
		weapons[] = {"sp_fwa_fal_factory_50_64","vn_sa7","Throw","Put"};
		respawnweapons[] = {"sp_fwa_fal_factory_50_64","vn_sa7","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_AT_s"};
				speechPlural[] = {"veh_infantry_AT_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_AT_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_AT_p";
		nameSound = "veh_infantry_AT_s";
		icon = "iconManAT";
		role = "MissileSpecialist";
		camouflage = 1.5;
		cost = 130000;
		secondaryAmmoCoef = 0.5;
		threat[] = {0.8,0.1,1};
	};
	class ACM_b_sam_2035_men_gunner: ACM_b_sam_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_gunner.jpg";
		displayName = "Gunner 1";
		uniformClass = "acm_sam_clothes_m_1_2";
		linkedItems[] = {"vn_b_vest_usarmy_14","acm_pasgt_base","acm_sam_g_bandana","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_14","acm_pasgt_base","acm_sam_g_bandana","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "";
		weapons[] = {"sp_fwa_fal_factory_50_63","Throw","Put"};
		respawnweapons[] = {"sp_fwa_fal_factory_50_63","Throw","Put"};
	};
	class ACM_b_sam_2035_men_gunner2: ACM_b_sam_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_gunner2.jpg";
		displayName = "Gunner 2";
		uniformClass = "acm_sam_clothes_m_1_3";
		linkedItems[] = {"vn_b_vest_usarmy_14","acm_pasgt_base","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_14","acm_pasgt_base","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "";
		weapons[] = {"sp_fwa_fal_factory_50_63","Throw","Put"};
		respawnweapons[] = {"sp_fwa_fal_factory_50_63","Throw","Put"};
	};
	class ACM_b_sam_2035_men_officer: ACM_b_sam_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_officer.jpg";
		displayName = "Superintendent";
		uniformClass = "acm_sam_clothes_m_1_1";
		linkedItems[] = {"vn_b_vest_usarmy_09","acm_sam_headwear_beret_anselm","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_09","acm_sam_headwear_beret_anselm","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "";
		magazines[] = {"sp_fwa_13Rnd_9mm_HiPower","sp_fwa_13Rnd_9mm_HiPower","sp_fwa_13Rnd_9mm_HiPower","sp_fwa_13Rnd_9mm_HiPower","sp_fwa_13Rnd_9mm_HiPower","sp_fwa_13Rnd_9mm_HiPower","sp_fwa_13Rnd_9mm_HiPower"};
		respawnMagazines[] = {"sp_fwa_13Rnd_9mm_HiPower","sp_fwa_13Rnd_9mm_HiPower","sp_fwa_13Rnd_9mm_HiPower","sp_fwa_13Rnd_9mm_HiPower","sp_fwa_13Rnd_9mm_HiPower","sp_fwa_13Rnd_9mm_HiPower","sp_fwa_13Rnd_9mm_HiPower"};
		weapons[] = {"sp_fwa_l9a1_hipower","Binocular","Throw","Put"};
		respawnweapons[] = {"sp_fwa_l9a1_hipower","Binocular","Throw","Put"};
		identityTypes[] = {"LanguageENGB_F","Head_Euro"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_officer_s"};
				speechPlural[] = {"veh_infantry_officer_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_officer_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_officer_p";
		nameSound = "veh_infantry_officer_s";
		icon = "iconManOfficer";
		role = "Rifleman";
		camouflage = 1.6;
		cost = 250000;
	};
	class ACM_b_sam_2035_men_unarmed: ACM_b_sam_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_unarmed.jpg";
		displayName = "Rifleman (Unarmed)";
		backpack = "";
		weapons[] = {"Throw","Put"};
		respawnWeapons[] = {"Throw","Put"};
		magazines[] = {};
		respawnMagazines[] = {};
		role = "Unarmed";
		threat[] = {0.1,0.1,0.1};
	};
	class ACM_b_sam_2035_men_survivor: ACM_b_sam_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_survivor.jpg";
		displayName = "Survivor";
		uniformClass = "acm_sam_clothes_m_1_2";
		linkedItems[] = {"vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		backpack = "";
		weapons[] = {"Throw","Put"};
		respawnWeapons[] = {"Throw","Put"};
		magazines[] = {};
		respawnMagazines[] = {};
		role = "Unarmed";
		threat[] = {0.1,0.1,0.1};
	};
	class ACM_b_sam_2035_men_JetPilot: ACM_b_sam_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_JetPilot.jpg";
		displayName = "Fixed-Wing Pilot";
		uniformClass = "acm_sam_clothes_m_4_1";
		linkedItems[] = {"V_TacVest_oli","vn_b_helmet_aph6_02_01","vn_b_acc_ms22001_01","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"V_TacVest_oli","vn_b_helmet_aph6_02_01","vn_b_acc_ms22001_01","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "B_Parachute";
		magazines[] = {"30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","vn_m127_mag","vn_m127_mag","vn_m127_mag","B_IR_Grenade"};
		respawnMagazines[] = {"30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","30Rnd_45ACP_Mag_SMG_01","vn_m127_mag","vn_m127_mag","vn_m127_mag","B_IR_Grenade"};
		weapons[] = {"SMG_01_F","vn_m127","Throw","Put"};
		respawnweapons[] = {"SMG_01_F","vn_m127","Throw","Put"};
		identityTypes[] = {"LanguageENGB_F","Head_Euro"};
		ACE_GForceCoef = 0.55;
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Crewman";
		camouflage = 2;
		cost = 93000;
		engineer = 1;
	};
	class ACM_b_sam_2035_men_JetPilot_Co: ACM_b_sam_2035_men_JetPilot
	{
		scope = 1;
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_JetPilot_Co.jpg";
		displayName = "Fixed-Wing Copilot";
		linkedItems[] = {"V_TacVest_oli","vn_b_helmet_aph6_01_01","vn_b_acc_ms22001_02","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"V_TacVest_oli","vn_b_helmet_aph6_01_01","vn_b_acc_ms22001_02","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
	};
	class ACM_b_sam_2035_men_ParadeDress: ACM_b_sam_2035_men_survivor
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_ParadeDress.jpg";
		displayName = "Constable (Parade Dress)";
		uniformClass = "acm_sam_clothes01_6_1";
		linkedItems[] = {"acm_sam_headwear_paradecap","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"acm_sam_headwear_paradecap","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		backpack = "";
		weapons[] = {"Throw","Put"};
		respawnWeapons[] = {"Throw","Put"};
		magazines[] = {};
		respawnMagazines[] = {};
		role = "Unarmed";
		threat[] = {0.1,0.1,0.1};
		identityTypes[] = {"LanguageENGB_F","Head_Euro","Head_NATO"};
	};
	class ACM_b_sam_2035_men_ParadeDress_Vet: ACM_b_sam_2035_men_ParadeDress
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_men_ParadeDress_Vet.jpg";
		displayName = "Constable (Parade Dress, Veteran)";
		uniformClass = "acm_sam_clothes01_6_2";
		linkedItems[] = {"G_Aviator","acm_sam_headwear_paradecap","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
		respawnLinkedItems[] = {"G_Aviator","acm_sam_headwear_paradecap","vn_b_item_radio_urc10","vn_b_item_compass","ItemMap","vn_b_item_watch"};
	};
	class ACM_b_sam_2035_men_SF_Scout: ACM_b_sam_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_SF_Scout.jpg";
		displayName = "Recon Scout";
		uniformClass = "acm_sam_clothes_m_1_1";
		magazines[] = {"sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		respawnMagazines[] = {"sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		linkedItems[] = {"NVGoggles","V_CarrierRigKBT_01_light_Olive_F","acm_fast_anselm_base","acm_sam_g_bandana","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"NVGoggles","V_CarrierRigKBT_01_light_Olive_F","acm_fast_anselm_base","acm_sam_g_bandana","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "";
		weapons[] = {"acm_sac_m_trg20","Throw","Put"};
		respawnweapons[] = {"acm_sac_m_trg20","Throw","Put"};
		editorSubcategory = "EdSubcat_Personnel_SpecialForces";
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_SF_s"};
				speechPlural[] = {"veh_infantry_SF_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_SF_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_SF_p";
		nameSound = "veh_infantry_SF_s";
		role = "Rifleman";
		camouflage = 0.6;
		detectSkill = 18;
	};
	class ACM_b_sam_2035_men_SF_Scout_AT: ACM_b_sam_2035_men_SF_Scout
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_SF_Scout_AT.jpg";
		displayName = "Recon Scout (AT)";
		uniformClass = "acm_sam_clothes_m_1_1";
		magazines[] = {"sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag","NLAW_F"};
		respawnMagazines[] = {"sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag","NLAW_F"};
		linkedItems[] = {"NVGoggles","V_CarrierRigKBT_01_light_Olive_F","acm_fast_anselm_accessory","acm_sam_g_bandana","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"NVGoggles","V_CarrierRigKBT_01_light_Olive_F","acm_fast_anselm_accessory","acm_sam_g_bandana","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "";
		weapons[] = {"acm_sac_m_trg21","launch_NLAW_F","Throw","Put"};
		respawnweapons[] = {"acm_sac_m_trg21","launch_NLAW_F","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_AT_s"};
				speechPlural[] = {"veh_infantry_AT_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_AT_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_AT_p";
		nameSound = "veh_infantry_AT_s";
		icon = "iconManAT";
		role = "MissileSpecialist";
		camouflage = 0.6;
		cost = 130000;
		detectSkill = 18;
		secondaryAmmoCoef = 0.5;
		threat[] = {0.8,0.8,0.3};
	};
	class ACM_b_sam_2035_men_SF_TL: ACM_b_sam_2035_men_SF_Scout
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_SF_TL.jpg";
		displayName = "Recon Team Lead";
		uniformClass = "acm_sam_clothes_m_1_4";
		linkedItems[] = {"NVGoggles","V_CarrierRigKBT_01_light_Olive_F","acm_fast_anselm_accessory","NVGoggles","acm_sam_g_bandana","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"NVGoggles","V_CarrierRigKBT_01_light_Olive_F","acm_fast_anselm_accessory","NVGoggles","acm_sam_g_bandana","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "";
		weapons[] = {"acm_sac_m_trg21","Rangefinder","Throw","Put"};
		respawnweapons[] = {"acm_sac_m_trg21","Rangefinder","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_SF_s"};
				speechPlural[] = {"veh_infantry_SF_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_SF_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_SF_p";
		nameSound = "veh_infantry_SF_s";
		icon = "iconManLeader";
		role = "RadioOperator";
		camouflage = 0.6;
		cost = 250000;
		detectSkill = 18;
	};
	class ACM_b_sam_2035_men_SF_Grenadier: ACM_b_sam_2035_men_SF_Scout
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_SF_Grenadier.jpg";
		displayName = "Recon Grenadier";
		uniformClass = "acm_sam_clothes_m_1_1";
		magazines[] = {"sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","UGL_FlareWhite_F","UGL_FlareWhite_F","1Rnd_Smoke_Grenade_shell","1Rnd_Smoke_Grenade_shell","1Rnd_Smoke_Grenade_shell","1Rnd_Smoke_Grenade_shell"};
		respawnMagazines[] = {"sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","sp_fwa_30Rnd_556_Armalite_Ball","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","UGL_FlareWhite_F","UGL_FlareWhite_F","1Rnd_Smoke_Grenade_shell","1Rnd_Smoke_Grenade_shell","1Rnd_Smoke_Grenade_shell","1Rnd_Smoke_Grenade_shell"};
		linkedItems[] = {"NVGoggles","V_CarrierRigKBT_01_light_Olive_F","acm_fast_anselm_chops","acm_sam_g_bandana","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"NVGoggles","V_CarrierRigKBT_01_light_Olive_F","acm_fast_anselm_chops","acm_sam_g_bandana","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "";
		weapons[] = {"acm_sac_m_trg21_gl","Throw","Put"};
		respawnweapons[] = {"acm_sac_m_trg21_gl","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_SF_s"};
				speechPlural[] = {"veh_infantry_SF_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_SF_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_SF_p";
		nameSound = "veh_infantry_SF_s";
		role = "Grenadier";
		camouflage = 0.6;
		cost = 200000;
		detectSkill = 18;
	};
	class ACM_b_sam_2035_men_SF_Marksman: ACM_b_sam_2035_men_SF_Scout
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_SF_Marksman.jpg";
		displayName = "Recon Marksman";
		uniformClass = "acm_sam_clothes_m_1_2";
		magazines[] = {"30Rnd_65x39_caseless_black_mag","30Rnd_65x39_caseless_black_mag","30Rnd_65x39_caseless_black_mag","30Rnd_65x39_caseless_black_mag","30Rnd_65x39_caseless_black_mag","30Rnd_65x39_caseless_black_mag","30Rnd_65x39_caseless_black_mag","30Rnd_65x39_caseless_black_mag","30Rnd_65x39_caseless_black_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag","vn_m14_early_grenade_mag","vn_m14_early_grenade_mag"};
		respawnMagazines[] = {"30Rnd_65x39_caseless_black_mag","30Rnd_65x39_caseless_black_mag","30Rnd_65x39_caseless_black_mag","30Rnd_65x39_caseless_black_mag","30Rnd_65x39_caseless_black_mag","30Rnd_65x39_caseless_black_mag","30Rnd_65x39_caseless_black_mag","30Rnd_65x39_caseless_black_mag","30Rnd_65x39_caseless_black_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag","vn_m14_early_grenade_mag","vn_m14_early_grenade_mag"};
		linkedItems[] = {"NVGoggles","V_CarrierRigKBT_01_light_Olive_F","acm_fast_anselm_base","acm_sam_g_bandana","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"NVGoggles","V_CarrierRigKBT_01_light_Olive_F","acm_fast_anselm_base","acm_sam_g_bandana","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "";
		weapons[] = {"acm_sac_m_MXM","Throw","Put"};
		respawnweapons[] = {"acm_sac_m_MXM","Throw","Put"};
	};
	class ACM_b_sam_2035_men_SF_Medic: ACM_b_sam_2035_men_SF_Scout
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_SF_Medic.jpg";
		displayName = "Recon CLS";
		uniformClass = "acm_sam_clothes_m_1_2";
		linkedItems[] = {"NVGoggles","V_CarrierRigKBT_01_light_Olive_F","acm_fast_anselm_base","acm_sam_g_bandana","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"NVGoggles","V_CarrierRigKBT_01_light_Olive_F","acm_fast_anselm_base","acm_sam_g_bandana","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "acm_bag_sam_medic";
		weapons[] = {"acm_sac_m_trg21","Throw","Put"};
		respawnweapons[] = {"acm_sac_m_trg21","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_medic_s"};
				speechPlural[] = {"veh_infantry_medic_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_medic_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_medic_p";
		nameSound = "veh_infantry_medic_s";
		icon = "iconManMedic";
		picture = "pictureHeal";
		role = "CombatLifeSaver";
		attendant = 1;
		camouflage = 0.6;
		detectSkill = 18;
	};
	class ACM_b_sam_2035_men_SF_Demo: ACM_b_sam_2035_men_SF_Scout
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_SF_Demo.jpg";
		displayName = "Recon Demolitions";
		uniformClass = "acm_sam_clothes_m_1_4";
		linkedItems[] = {"NVGoggles","V_CarrierRigKBT_01_light_Olive_F","acm_fast_anselm_accessory","acm_sam_g_bandana","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"NVGoggles","V_CarrierRigKBT_01_light_Olive_F","acm_fast_anselm_accessory","acm_sam_g_bandana","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "acm_bag_sam_demo";
		weapons[] = {"acm_sac_m_trg20","Throw","Put"};
		respawnweapons[] = {"acm_sac_m_trg20","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_SF_s"};
				speechPlural[] = {"veh_infantry_SF_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_SF_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_SF_p";
		nameSound = "veh_infantry_SF_s";
		icon = "iconManEngineer";
		picture = "pictureRepair";
		role = "Sapper";
		canDeactivateMines = 1;
		camouflage = 0.6;
		detectSkill = 38;
	};
	class ACM_b_sam_2035_men_SF_Auto: ACM_b_sam_2035_men_SF_Scout
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_SF_Auto.jpg";
		displayName = "Recon Autorifleman";
		uniformClass = "acm_sam_clothes_m_1_3";
		linkedItems[] = {"NVGoggles","V_CarrierRigKBT_01_light_Olive_F","acm_fast_anselm_accessory","acm_sam_g_bandana","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"NVGoggles","V_CarrierRigKBT_01_light_Olive_F","acm_fast_anselm_accessory","acm_sam_g_bandana","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "acm_bag_sam_2035_MG";
		weapons[] = {"acm_sac_m_MX_SW","Throw","Put"};
		respawnweapons[] = {"acm_sac_m_MX_SW","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_MG_s"};
				speechPlural[] = {"veh_infantry_MG_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_MG_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_MG_p";
		nameSound = "veh_infantry_MG_s";
		icon = "iconManMG";
		role = "MachineGunner";
		cost = 220000;
	};
	class ACM_b_sam_2035_men_SF_CT: ACM_b_sam_2035_men_SF_Scout
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_SF_CT.jpg";
		displayName = "Counter-Terrorism Expert";
		uniformClass = "acm_sam_clothes_m_1_3";
		linkedItems[] = {"acm_fast_anselm_visor_nvg_down","acm_sam_m_vest3","acm_fast_anselm_accessory","acm_sam_g_bandana","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_fast_anselm_visor_nvg_down","acm_sam_m_vest3","acm_fast_anselm_accessory","acm_sam_g_bandana","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "";
		weapons[] = {"acm_sac_m_MXC","Throw","Put"};
		respawnweapons[] = {"acm_sac_m_MXC","Throw","Put"};
		magazines[] = {"30Rnd_65x39_caseless_black_mag","30Rnd_65x39_caseless_black_mag","30Rnd_65x39_caseless_black_mag","30Rnd_65x39_caseless_black_mag","30Rnd_65x39_caseless_black_mag","30Rnd_65x39_caseless_black_mag","30Rnd_65x39_caseless_black_mag","30Rnd_65x39_caseless_black_mag","30Rnd_65x39_caseless_black_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		respawnMagazines[] = {"30Rnd_65x39_caseless_black_mag","30Rnd_65x39_caseless_black_mag","30Rnd_65x39_caseless_black_mag","30Rnd_65x39_caseless_black_mag","30Rnd_65x39_caseless_black_mag","30Rnd_65x39_caseless_black_mag","30Rnd_65x39_caseless_black_mag","30Rnd_65x39_caseless_black_mag","30Rnd_65x39_caseless_black_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_SF_s"};
				speechPlural[] = {"veh_infantry_SF_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_SF_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_SF_p";
		nameSound = "veh_infantry_SF_s";
		role = "Rifleman";
		camouflage = 0.6;
		detectSkill = 18;
	};
	class ACM_b_sam_2035_men_CR_Rifleman: ACM_b_sam_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_CR_Rifleman.jpg";
		displayName = "Reserve. Rifleman 1";
		uniformClass = "acm_sam_clothes_m_1_2";
		magazines[] = {"sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		respawnMagazines[] = {"sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		linkedItems[] = {"V_CarrierRigKBT_01_Olive_F","ACM_Helmet_Mk5_Cover_multi","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"V_CarrierRigKBT_01_Olive_F","ACM_Helmet_Mk5_Cover_multi","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "ACM_vn_backpack_seal_01";
		weapons[] = {"sp_fwa_enfield_l8_walnut","Throw","Put"};
		respawnweapons[] = {"sp_fwa_enfield_l8_walnut","Throw","Put"};
		editorSubcategory = "ACM_SAM_Res";
		identityTypes[] = {"LanguageENGB_F","Head_NATO","Head_Euro"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Rifleman";
		accuracy = 2.3;
		camouflage = 1.4;
		minFireTime = 7;
	};
	class ACM_b_sam_2035_men_CR_Rifleman_AT: ACM_b_sam_2035_men_CR_Rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_CR_Rifleman_AT.jpg";
		displayName = "Reserve. Rifleman (AT)";
		uniformClass = "acm_sam_clothes_m_1_1";
		magazines[] = {"sp_fwa_20Rnd_556_Ruger_Mini14","sp_fwa_20Rnd_556_Ruger_Mini14","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		respawnMagazines[] = {"sp_fwa_20Rnd_556_Ruger_Mini14","sp_fwa_20Rnd_556_Ruger_Mini14","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		linkedItems[] = {"V_CarrierRigKBT_01_Olive_F","ACM_Helmet_Mk5_Cover_Net_Multi","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"V_CarrierRigKBT_01_Olive_F","ACM_Helmet_Mk5_Cover_Net_Multi","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "acm_bag_sam_cr_ruger";
		weapons[] = {"sp_fwa_ruger_mini14_ac556","launch_NLAW_F","Throw","Put"};
		respawnweapons[] = {"sp_fwa_ruger_mini14_ac556","launch_NLAW_F","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_AT_s"};
				speechPlural[] = {"veh_infantry_AT_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_AT_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_AT_p";
		nameSound = "veh_infantry_AT_s";
		icon = "iconManAT";
		role = "MissileSpecialist";
		cost = 130000;
		secondaryAmmoCoef = 0.5;
		threat[] = {0.8,0.8,0.3};
	};
	class ACM_b_sam_2035_men_CR_Rifleman_Garand: ACM_b_sam_2035_men_CR_Rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_CR_Rifleman_Garand.jpg";
		displayName = "Reserve. Rifleman 2";
		uniformClass = "acm_sam_clothes_m_1_3";
		magazines[] = {"vn_m1_garand_t_mag","vn_m1_garand_t_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		respawnMagazines[] = {"vn_m1_garand_t_mag","vn_m1_garand_t_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		linkedItems[] = {"V_CarrierRigKBT_01_Olive_F","ACM_Helmet_Mk5_Nostrap","ACM_Misc_Clothband_Blue","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"V_CarrierRigKBT_01_Olive_F","ACM_Helmet_Mk5_Nostrap","ACM_Misc_Clothband_Blue","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "acm_bag_sam_cr_garand";
		weapons[] = {"vn_m1_garand_gl","Throw","Put"};
		respawnweapons[] = {"vn_m1_garand_gl","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Rifleman";
		accuracy = 2.3;
		camouflage = 1.4;
		minFireTime = 7;
	};
	class ACM_b_sam_2035_men_CR_Rifleman_FN49: ACM_b_sam_2035_men_CR_Rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_CR_Rifleman_FN49.jpg";
		displayName = "Reserve. Rifleman 3";
		uniformClass = "acm_sam_clothes_m_1_1";
		magazines[] = {"sp_fwa_20Rnd_762_FN49_tracer","sp_fwa_20Rnd_762_FN49_tracer","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		respawnMagazines[] = {"sp_fwa_20Rnd_762_FN49_tracer","sp_fwa_20Rnd_762_FN49_tracer","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		linkedItems[] = {"V_CarrierRigKBT_01_Olive_F","ACM_Helmet_Mk5_Cover_multi","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"V_CarrierRigKBT_01_Olive_F","ACM_Helmet_Mk5_Cover_multi","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "acm_bag_sam_cr_FN49";
		weapons[] = {"sp_fwa_fn49_arg","Throw","Put"};
		respawnweapons[] = {"sp_fwa_fn49_arg","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Rifleman";
		accuracy = 2.3;
		camouflage = 1.4;
		minFireTime = 7;
	};
	class ACM_b_sam_2035_men_CR_Rifleman_AK: ACM_b_sam_2035_men_CR_Rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_CR_Rifleman_AK.jpg";
		displayName = "Reserve. Rifleman 4";
		uniformClass = "acm_sam_clothes_m_1_2";
		magazines[] = {"vn_type56_mag","vn_type56_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		respawnMagazines[] = {"vn_type56_mag","vn_type56_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		linkedItems[] = {"V_CarrierRigKBT_01_Olive_F","ACM_Helmet_Mk5_Cover_Net_Multi","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"V_CarrierRigKBT_01_Olive_F","ACM_Helmet_Mk5_Cover_Net_Multi","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "acm_bag_sam_cr_AK";
		weapons[] = {"vn_type56","Throw","Put"};
		respawnweapons[] = {"vn_type56","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Rifleman";
		accuracy = 2.3;
		camouflage = 1.4;
		minFireTime = 7;
	};
	class ACM_b_sam_2035_men_CR_Rifleman_SKS: ACM_b_sam_2035_men_CR_Rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_CR_Rifleman_SKS.jpg";
		displayName = "Reserve. Rifleman 5";
		uniformClass = "acm_sam_clothes_m_1_4";
		magazines[] = {"vn_sks_mag","vn_sks_mag","vn_sks_mag","vn_sks_mag","vn_sks_mag","vn_sks_mag","vn_sks_mag","vn_sks_mag","vn_sks_mag","vn_sks_mag","vn_sks_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		respawnMagazines[] = {"vn_sks_mag","vn_sks_mag","vn_sks_mag","vn_sks_mag","vn_sks_mag","vn_sks_mag","vn_sks_mag","vn_sks_mag","vn_sks_mag","vn_sks_mag","vn_sks_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		linkedItems[] = {"vn_b_vest_seal_05","acm_pasgt_nocover","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"vn_b_vest_seal_05","acm_pasgt_nocover","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "";
		weapons[] = {"vn_sks","Throw","Put"};
		respawnweapons[] = {"vn_sks","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Rifleman";
		accuracy = 2.3;
		camouflage = 1.4;
		minFireTime = 7;
	};
	class ACM_b_sam_2035_men_CR_TL: ACM_b_sam_2035_men_CR_Rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_CR_TL.jpg";
		displayName = "Reserve. Squad Lead";
		uniformClass = "acm_sam_clothes_m_1_4";
		magazines[] = {"sp_fwa_30Rnd_556_Armalite","sp_fwa_30Rnd_556_Armalite","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		respawnMagazines[] = {"sp_fwa_30Rnd_556_Armalite","sp_fwa_30Rnd_556_Armalite","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		linkedItems[] = {"V_CarrierRigKBT_01_Olive_F","acm_pasgt_nocover","acm_sam_g_bandana","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"V_CarrierRigKBT_01_Olive_F","acm_pasgt_nocover","acm_sam_g_bandana","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "acm_bag_sam_cr_AR";
		weapons[] = {"sp_fwa_651_CAR15","vn_mk21_binocs","vn_m127","Throw","Put"};
		respawnweapons[] = {"sp_fwa_651_CAR15","vn_mk21_binocs","vn_m127","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		icon = "iconManLeader";
		role = "RadioOperator";
		cost = 250000;
	};
	class ACM_b_sam_2035_men_CR_AR: ACM_b_sam_2035_men_CR_Rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_CR_AR.jpg";
		displayName = "Reserve. Autorifleman";
		uniformClass = "acm_sam_clothes_m_1_1";
		magazines[] = {"sp_fwa_30Rnd_Curved_762_FAL_Metric","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		respawnMagazines[] = {"sp_fwa_30Rnd_Curved_762_FAL_Metric","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		linkedItems[] = {"vn_b_vest_usarmy_03","acm_sam_headwear_boonie_Fold_m","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_03","acm_sam_headwear_boonie_Fold_m","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "acm_bag_sam_hmg";
		weapons[] = {"sp_fwa_bren_l4_lmg","Throw","Put"};
		respawnweapons[] = {"sp_fwa_bren_l4_lmg","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_MG_s"};
				speechPlural[] = {"veh_infantry_MG_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_MG_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_MG_p";
		nameSound = "veh_infantry_MG_s";
		icon = "iconManMG";
		role = "MachineGunner";
		cost = 220000;
	};
	class ACM_b_sam_2035_men_CR_MR: ACM_b_sam_2035_men_CR_Rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_CR_MR.jpg";
		displayName = "Reserve. Marksman";
		uniformClass = "acm_sam_clothes_m_1_3";
		magazines[] = {"vn_m38_mag","vn_m38_mag","vn_m38_mag","vn_m38_mag","vn_m38_mag","vn_m38_mag","vn_m38_mag","vn_m38_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		respawnMagazines[] = {"vn_m38_mag","vn_m38_mag","vn_m38_mag","vn_m38_mag","vn_m38_mag","vn_m38_mag","vn_m38_mag","vn_m38_mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		linkedItems[] = {"vn_b_vest_usarmy_02","acm_sam_headwear_boonie","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_02","acm_sam_headwear_boonie","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "";
		weapons[] = {"acm_sac_m_cr_m19130","Throw","Put"};
		respawnweapons[] = {"acm_sac_m_cr_m19130","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_sniper_s"};
				speechPlural[] = {"veh_infantry_sniper_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_sniper_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_sniper_p";
		nameSound = "veh_infantry_sniper_s";
		role = "Marksman";
		cost = 250000;
	};
	class ACM_b_sam_2035_men_CR_CLS: ACM_b_sam_2035_men_CR_Rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_CR_CLS.jpg";
		displayName = "Reserve. CLS";
		uniformClass = "acm_sam_clothes_m_1_1";
		magazines[] = {"sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		respawnMagazines[] = {"sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","sp_fwa_20Rnd_762_FAL_Metric","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		linkedItems[] = {"V_TacVest_oli","ACM_Helmet_Mk5_Scrim2","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"V_TacVest_oli","ACM_Helmet_Mk5_Scrim2","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "acm_bag_sam_medic";
		weapons[] = {"sp_fwa_fal_l1a1_wood","Throw","Put"};
		respawnweapons[] = {"sp_fwa_fal_l1a1_wood","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_medic_s"};
				speechPlural[] = {"veh_infantry_medic_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_medic_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_medic_p";
		nameSound = "veh_infantry_medic_s";
		icon = "iconManMedic";
		picture = "pictureHeal";
		role = "CombatLifeSaver";
		attendant = 1;
	};
	class ACM_b_sam_2035_men_CR_RTO: ACM_b_sam_2035_men_CR_Rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_CR_RTO.jpg";
		displayName = "Reserve. RTO";
		uniformClass = "acm_sam_clothes_m_1_2";
		magazines[] = {"sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		respawnMagazines[] = {"sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","sp_fwa_10Rnd_762_L42","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		linkedItems[] = {"V_CarrierRigKBT_01_Olive_F","ACM_Helmet_Mk5_Cover_Net_Multi","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"V_CarrierRigKBT_01_Olive_F","ACM_Helmet_Mk5_Cover_Net_Multi","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "vn_b_pack_lw_06";
		weapons[] = {"sp_fwa_enfield_l42_walnut","Throw","Put"};
		respawnweapons[] = {"sp_fwa_enfield_l42_walnut","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		icon = "iconManLeader";
		role = "Grenadier";
		cost = 250000;
	};
	class ACM_b_sam_2035_men_CR_SUB: ACM_b_sam_2035_men_CR_Rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_b_sam_2035_men_CR_SUB.jpg";
		displayName = "Reserve. Submachinegunner";
		uniformClass = "acm_sam_clothes01_3";
		magazines[] = {"sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		respawnMagazines[] = {"sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","sp_fwa_32Rnd_9x19_L2A3_Sterling","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		linkedItems[] = {"acm_sam_m_vest1","ACM_Helmet_Mk5_Cover_multi","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_sam_m_vest1","ACM_Helmet_Mk5_Cover_multi","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "";
		weapons[] = {"sp_fwa_smg_sterling","Throw","Put"};
		respawnweapons[] = {"sp_fwa_smg_sterling","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Rifleman";
		accuracy = 2.3;
		camouflage = 1.4;
		minFireTime = 7;
	};
	class ACM_vn_backpack_seal_01;
	class ACM_vn_backpack_seal_04;
	class ACM_vn_backpack_seal_05;
	class acm_bag_sam_cr_ruger: ACM_vn_backpack_seal_04
	{
		ScopeArsenal = 1;
		scope = 1;
		class TransportMagazines
		{
			class _xx_sp_fwa_20Rnd_556_Ruger_Mini14
			{
				magazine = "sp_fwa_20Rnd_556_Ruger_Mini14";
				count = 9;
			};
			class _xx_NLAW_F
			{
				magazine = "NLAW_F";
				count = 1;
			};
		};
	};
	class acm_bag_sam_cr_garand: ACM_vn_backpack_seal_05
	{
		ScopeArsenal = 1;
		scope = 1;
		class TransportMagazines
		{
			class _xx_vn_m1_garand_t_mag
			{
				magazine = "vn_m1_garand_t_mag";
				count = 20;
			};
			class _xx_vn_22mm_m1a2_frag_mag
			{
				magazine = "vn_22mm_m1a2_frag_mag";
				count = 5;
			};
			class _xx_vn_22mm_m9_heat_mag
			{
				magazine = "vn_22mm_m9_heat_mag";
				count = 2;
			};
		};
	};
	class acm_bag_sam_cr_FN49: ACM_vn_backpack_seal_01
	{
		ScopeArsenal = 1;
		scope = 1;
		class TransportMagazines
		{
			class _xx_sp_fwa_20Rnd_762_FN49_tracer
			{
				magazine = "sp_fwa_20Rnd_762_FN49_tracer";
				count = 9;
			};
		};
	};
	class acm_bag_sam_cr_AK: ACM_vn_backpack_seal_01
	{
		ScopeArsenal = 1;
		scope = 1;
		class TransportMagazines
		{
			class _xx_vn_type56_mag
			{
				magazine = "vn_type56_mag";
				count = 9;
			};
		};
	};
	class acm_bag_sam_cr_AR: ACM_vn_backpack_seal_05
	{
		ScopeArsenal = 1;
		scope = 1;
		class TransportMagazines
		{
			class _xx_sp_fwa_30Rnd_556_Armalite
			{
				magazine = "sp_fwa_30Rnd_556_Armalite";
				count = 9;
			};
			class _xx_vn_m127_mag
			{
				magazine = "vn_m127_mag";
				count = 9;
			};
		};
	};
	class ACM_o_alci_2035_men_rifleman: B_Survivor_F
	{
		faction = "ACM_O_ATIU_2035";
		side = 0;
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_2035_men_rifleman.jpg";
		displayName = "Rifleman";
		nakedUniform = "vn_b_uniform_basecharacter_01";
		uniformClass = "acm_sam_clothes_m_2_1";
		items[] = {"vn_b_item_firstaidkit","vn_b_item_firstaidkit"};
		respawnItems[] = {"vn_b_item_firstaidkit","vn_b_item_firstaidkit"};
		magazines[] = {"sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		respawnMagazines[] = {"sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		linkedItems[] = {"acm_alc_vest_CarrierLite","H_HelmetAggressor_F","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_alc_vest_CarrierLite","H_HelmetAggressor_F","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		weapons[] = {"sp_fwa_ar18","Throw","Put"};
		respawnweapons[] = {"sp_fwa_ar18","Throw","Put"};
		identityTypes[] = {"LanguageGRE_F","vn_b_camo_us","Head_Euro"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Rifleman";
		accuracy = 2.3;
		camouflage = 1.4;
		minFireTime = 7;
	};
	class ACM_o_alci_2035_men_rifleman_2: ACM_o_alci_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_2035_men_rifleman_2.jpg";
		displayName = "Rifleman (CQB)";
		uniformClass = "acm_sam_clothes_m_2_2";
		magazines[] = {"sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		respawnMagazines[] = {"sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		linkedItems[] = {"acm_alc_vest_CarrierLite","acm_alc_helmet_avenger","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_alc_vest_CarrierLite","acm_alc_helmet_avenger","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		weapons[] = {"sp_fwa_ar18_carbine","Throw","Put"};
		respawnweapons[] = {"sp_fwa_ar18_carbine","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Rifleman";
		accuracy = 2.3;
		camouflage = 1.4;
		minFireTime = 7;
	};
	class ACM_o_alci_2035_men_rifleman_3: ACM_o_alci_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_2035_men_rifleman_3.jpg";
		displayName = "Rifleman 3";
		uniformClass = "acm_sam_clothes_m_2_2";
		magazines[] = {"sp_fwa_30Rnd_556_Armalite","sp_fwa_30Rnd_556_Armalite","sp_fwa_30Rnd_556_Armalite","sp_fwa_30Rnd_556_Armalite","sp_fwa_30Rnd_556_Armalite","sp_fwa_30Rnd_556_Armalite","sp_fwa_30Rnd_556_Armalite","sp_fwa_30Rnd_556_Armalite","sp_fwa_30Rnd_556_Armalite","sp_fwa_30Rnd_556_Armalite","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		respawnMagazines[] = {"sp_fwa_30Rnd_556_Armalite","sp_fwa_30Rnd_556_Armalite","sp_fwa_30Rnd_556_Armalite","sp_fwa_30Rnd_556_Armalite","sp_fwa_30Rnd_556_Armalite","sp_fwa_30Rnd_556_Armalite","sp_fwa_30Rnd_556_Armalite","sp_fwa_30Rnd_556_Armalite","sp_fwa_30Rnd_556_Armalite","sp_fwa_30Rnd_556_Armalite","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		linkedItems[] = {"acm_alc_vest_Carrier","acm_alc_helmet_m1","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_alc_vest_Carrier","acm_alc_helmet_m1","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		weapons[] = {"sp_fwa_ar15_603_m16a1_a2","Throw","Put"};
		respawnweapons[] = {"sp_fwa_ar15_603_m16a1_a2","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Rifleman";
		accuracy = 2.3;
		camouflage = 1.4;
		minFireTime = 7;
	};
	class ACM_o_alci_2035_men_rifleman_4: ACM_o_alci_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_2035_men_rifleman_4.jpg";
		displayName = "Rifleman 4";
		uniformClass = "acm_sam_clothes_m_2_4";
		magazines[] = {"sp_fwa_20rnd_762_bm59","sp_fwa_20rnd_762_bm59","sp_fwa_20rnd_762_bm59","sp_fwa_20rnd_762_bm59","sp_fwa_20rnd_762_bm59","sp_fwa_20rnd_762_bm59","sp_fwa_20rnd_762_bm59","sp_fwa_20rnd_762_bm59","sp_fwa_20rnd_762_bm59","sp_fwa_20rnd_762_bm59","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		respawnMagazines[] = {"sp_fwa_20rnd_762_bm59","sp_fwa_20rnd_762_bm59","sp_fwa_20rnd_762_bm59","sp_fwa_20rnd_762_bm59","sp_fwa_20rnd_762_bm59","sp_fwa_20rnd_762_bm59","sp_fwa_20rnd_762_bm59","sp_fwa_20rnd_762_bm59","sp_fwa_20rnd_762_bm59","sp_fwa_20rnd_762_bm59","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag"};
		linkedItems[] = {"acm_alc_vest_CarrierLite","acm_alc_helmet_m1_3","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_alc_vest_CarrierLite","acm_alc_helmet_m1_3","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		weapons[] = {"sp_fwa_bm59_mk3_alpine","Throw","Put"};
		respawnweapons[] = {"sp_fwa_bm59_mk3_alpine","Throw","Put"};
		backpack = "acm_bag_AL_M_rifleman3";
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Rifleman";
		accuracy = 2.3;
		camouflage = 1.4;
		minFireTime = 7;
	};
	class ACM_o_alci_2035_men_rifleman_light: ACM_o_alci_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_2035_men_rifleman_light.jpg";
		displayName = "Rifleman (Light)";
		uniformClass = "acm_sam_clothes_m_2_1";
		linkedItems[] = {"V_TacVest_oli","acm_alc_headwear_boonie_m","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"V_TacVest_oli","acm_alc_headwear_boonie_m","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Rifleman";
		accuracy = 2.3;
		camouflage = 1.4;
		minFireTime = 7;
	};
	class ACM_o_alci_2035_men_rifleman_AT: ACM_o_alci_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_2035_men_rifleman_AT.jpg";
		displayName = "Rifleman (AT)";
		uniformClass = "acm_sam_clothes_m_2_2";
		magazines[] = {"sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag","vn_m72_mag"};
		respawnMagazines[] = {"sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag","vn_m72_mag"};
		linkedItems[] = {"acm_alc_vest_CarrierLite","H_HelmetAggressor_F","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_alc_vest_CarrierLite","H_HelmetAggressor_F","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		weapons[] = {"sp_fwa_ar18","vn_m72","Throw","Put"};
		respawnweapons[] = {"sp_fwa_ar18","vn_m72","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_AT_s"};
				speechPlural[] = {"veh_infantry_AT_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_AT_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_AT_p";
		nameSound = "veh_infantry_AT_s";
		icon = "iconManAT";
		role = "MissileSpecialist";
		cost = 130000;
		secondaryAmmoCoef = 0.5;
		threat[] = {0.8,0.8,0.3};
	};
	class ACM_o_alci_2035_men_SL: ACM_o_alci_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_2035_men_SL.jpg";
		displayName = "Squad Lead";
		uniformClass = "acm_sam_clothes_m_2_3";
		magazines[] = {"sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag","vn_m127_mag","vn_m127_mag","vn_m127_mag"};
		respawnMagazines[] = {"sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag","vn_m127_mag","vn_m127_mag","vn_m127_mag"};
		linkedItems[] = {"acm_alc_vest_Carrier","acm_alc_helmet_avenger","acm_alc_g_bandana","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_alc_vest_Carrier","acm_alc_helmet_avenger","acm_alc_g_bandana","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		weapons[] = {"sp_fwa_ar18","Rangefinder","vn_m127","Throw","Put"};
		respawnweapons[] = {"sp_fwa_ar18","Rangefinder","vn_m127","Throw","Put"};
		backpack = "vn_b_pack_03";
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		icon = "iconManLeader";
		role = "RadioOperator";
		cost = 250000;
	};
	class ACM_o_alci_2035_men_grenadier: ACM_o_alci_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_2035_men_grenadier.jpg";
		displayName = "Grenadier";
		uniformClass = "acm_sam_clothes_m_2_2";
		magazines[] = {"sp_fwa_20Rnd_556_Armalite_Tracer","sp_fwa_20Rnd_556_Armalite_Tracer","sp_fwa_20Rnd_556_Armalite_Tracer","sp_fwa_20Rnd_556_Armalite_Tracer","sp_fwa_20Rnd_556_Armalite_Tracer","sp_fwa_20Rnd_556_Armalite_Tracer","sp_fwa_20Rnd_556_Armalite_Tracer","sp_fwa_20Rnd_556_Armalite_Tracer","sp_fwa_20Rnd_556_Armalite_Tracer","sp_fwa_20Rnd_556_Armalite_Tracer","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","UGL_FlareWhite_F","UGL_FlareWhite_F","UGL_FlareWhite_F","1Rnd_Smoke_Grenade_shell","1Rnd_Smoke_Grenade_shell","1Rnd_Smoke_Grenade_shell"};
		respawnMagazines[] = {"sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","UGL_FlareWhite_F","UGL_FlareWhite_F","UGL_FlareWhite_F","1Rnd_Smoke_Grenade_shell","1Rnd_Smoke_Grenade_shell","1Rnd_Smoke_Grenade_shell"};
		linkedItems[] = {"acm_alc_vest_Carrier","acm_alc_helmet_avenger","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_alc_vest_Carrier","acm_alc_helmet_avenger","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		weapons[] = {"acm_alc_m_sp_m16_m203","Throw","Put"};
		respawnweapons[] = {"acm_alc_m_sp_m16_m203","Throw","Put"};
		backpack = "vn_o_pack_05";
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Grenadier";
		cost = 200000;
	};
	class ACM_o_alci_2035_men_marksman: ACM_o_alci_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_2035_men_marksman.jpg";
		displayName = "Marksman";
		uniformClass = "acm_sam_clothes_m_2_2";
		magazines[] = {"sp_fwa_20rnd_762_bm59","sp_fwa_20rnd_762_bm59","sp_fwa_20rnd_762_bm59","sp_fwa_20rnd_762_bm59","sp_fwa_20rnd_762_bm59","sp_fwa_20rnd_762_bm59","sp_fwa_20rnd_762_bm59","sp_fwa_20rnd_762_bm59","sp_fwa_20rnd_762_bm59","sp_fwa_20rnd_762_bm59","sp_fwa_1rnd_riflegrenade_mas_ap","sp_fwa_1rnd_riflegrenade_mas_ap","sp_fwa_1rnd_riflegrenade_m9a1_at","sp_fwa_1rnd_riflegrenade_m9a1_at"};
		respawnMagazines[] = {"sp_fwa_20rnd_762_bm59","sp_fwa_20rnd_762_bm59","sp_fwa_20rnd_762_bm59","sp_fwa_20rnd_762_bm59","sp_fwa_20rnd_762_bm59","sp_fwa_20rnd_762_bm59","sp_fwa_20rnd_762_bm59","sp_fwa_20rnd_762_bm59","sp_fwa_20rnd_762_bm59","sp_fwa_20rnd_762_bm59","sp_fwa_1rnd_riflegrenade_mas_ap","sp_fwa_1rnd_riflegrenade_mas_ap","sp_fwa_1rnd_riflegrenade_m9a1_at","sp_fwa_1rnd_riflegrenade_m9a1_at"};
		linkedItems[] = {"acm_alc_vest_CarrierLite","acm_alc_headwear_boonie_m","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_alc_vest_CarrierLite","acm_alc_headwear_boonie_m","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		weapons[] = {"acm_alc_m_sp_bm59","Throw","Put"};
		respawnweapons[] = {"acm_alc_m_sp_bm59","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_sniper_s"};
				speechPlural[] = {"veh_infantry_sniper_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_sniper_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_sniper_p";
		nameSound = "veh_infantry_sniper_s";
		role = "Marksman";
		cost = 250000;
	};
	class ACM_o_alci_2035_men_AT: ACM_o_alci_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_2035_men_AT.jpg";
		displayName = "Anti-Tank";
		uniformClass = "acm_sam_clothes_m_2_1";
		magazines[] = {"sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer"};
		respawnMagazines[] = {"sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer"};
		linkedItems[] = {"acm_alc_vest_CarrierLite","acm_alc_helmet_avenger","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_alc_vest_CarrierLite","acm_alc_helmet_avenger","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		weapons[] = {"sp_fwa_ar18","vn_rpg7","Throw","Put"};
		respawnweapons[] = {"sp_fwa_ar18","vn_rpg7","Throw","Put"};
		backpack = "acm_bag_AL_M_AT";
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_AT_s"};
				speechPlural[] = {"veh_infantry_AT_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_AT_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_AT_p";
		nameSound = "veh_infantry_AT_s";
		icon = "iconManAT";
		role = "MissileSpecialist";
		camouflage = 1.5;
		cost = 130000;
		secondaryAmmoCoef = 0.5;
		threat[] = {0.8,0.8,0.3};
	};
	class ACM_o_alci_2035_men_MG: ACM_o_alci_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_2035_men_MG.jpg";
		displayName = "Machinegunner";
		uniformClass = "acm_sam_clothes_m_2_3";
		magazines[] = {"sp_fwa_100Rnd_762_mag"};
		respawnMagazines[] = {"sp_fwa_100Rnd_762_mag"};
		linkedItems[] = {"acm_alc_vest_CarrierLite","H_HelmetAggressor_F","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_alc_vest_CarrierLite","H_HelmetAggressor_F","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		weapons[] = {"sp_fwa_mag58","Throw","Put"};
		respawnweapons[] = {"sp_fwa_mag58","Throw","Put"};
		backpack = "acm_bag_AL_M_MG";
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_MG_s"};
				speechPlural[] = {"veh_infantry_MG_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_MG_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_MG_p";
		nameSound = "veh_infantry_MG_s";
		icon = "iconManMG";
		role = "MachineGunner";
		cost = 220000;
	};
	class ACM_o_alci_2035_men_Sapper: ACM_o_alci_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_2035_men_Sapper.jpg";
		displayName = "Sapper";
		uniformClass = "acm_sam_clothes_m_2_4";
		linkedItems[] = {"acm_alc_vest_CarrierLite","H_HelmetAggressor_F","acm_alc_g_bandana","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_alc_vest_CarrierLite","H_HelmetAggressor_F","acm_alc_g_bandana","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		weapons[] = {"sp_fwa_ar18","Throw","Put"};
		respawnweapons[] = {"sp_fwa_ar18","Throw","Put"};
		backpack = "acm_bag_AL_M_demo";
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		icon = "iconManEngineer";
		picture = "pictureRepair";
		role = "Sapper";
		canDeactivateMines = 1;
		cost = 93000;
		detectSkill = 38;
		engineer = 1;
	};
	class ACM_o_alci_2035_men_RTO: ACM_o_alci_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_2035_men_RTO.jpg";
		displayName = "RTO";
		uniformClass = "acm_sam_clothes_m_2_1";
		linkedItems[] = {"acm_alc_vest_Carrier","acm_alc_helmet_avenger","acm_alc_g_bandana","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_alc_vest_Carrier","acm_alc_helmet_avenger","acm_alc_g_bandana","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		weapons[] = {"sp_fwa_ar18","Throw","Put"};
		respawnweapons[] = {"sp_fwa_ar18","Throw","Put"};
		backpack = "vn_b_pack_prc77_01";
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		icon = "iconManLeader";
		role = "Grenadier";
		cost = 250000;
	};
	class ACM_o_alci_2035_men_Medic: ACM_o_alci_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_2035_men_Medic.jpg";
		displayName = "Combat Life Saver";
		uniformClass = "acm_sam_clothes_m_2_2";
		linkedItems[] = {"acm_alc_vest_Carrier","acm_alc_helmet_avenger","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_alc_vest_Carrier","acm_alc_helmet_avenger","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		weapons[] = {"sp_fwa_ar18","Throw","Put"};
		respawnweapons[] = {"sp_fwa_ar18","Throw","Put"};
		backpack = "acm_bag_sam_medic";
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_medic_s"};
				speechPlural[] = {"veh_infantry_medic_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_medic_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_medic_p";
		nameSound = "veh_infantry_medic_s";
		icon = "iconManMedic";
		picture = "pictureHeal";
		role = "CombatLifeSaver";
		attendant = 1;
	};
	class ACM_o_alci_2035_men_Crewman: ACM_o_alci_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_2035_men_Crewman.jpg";
		displayName = "Crewman";
		uniformClass = "acm_sam_clothes_m_2_1";
		linkedItems[] = {"vn_b_vest_usarmy_14","vn_o_helmet_tsh3_01","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_14","vn_o_helmet_tsh3_01","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		weapons[] = {"sp_fwa_ar18_carbine","Throw","Put"};
		respawnweapons[] = {"sp_fwa_ar18_carbine","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Crewman";
		camouflage = 2;
		cost = 93000;
		engineer = 1;
	};
	class ACM_o_alci_2035_men_Gunner: ACM_o_alci_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_2035_men_Gunner.jpg";
		displayName = "Gunner 1";
		uniformClass = "acm_sam_clothes_m_2_4";
		linkedItems[] = {"vn_b_vest_usarmy_14","acm_alc_helmet_m1_4","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"vn_b_vest_usarmy_14","acm_alc_helmet_m1_4","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		weapons[] = {"sp_fwa_ar18_carbine","Throw","Put"};
		respawnweapons[] = {"sp_fwa_ar18_carbine","Throw","Put"};
	};
	class ACM_o_alci_2035_men_AA: ACM_o_alci_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_2035_men_AA.jpg";
		displayName = "MANPAD Operator";
		uniformClass = "acm_sam_clothes_m_2_2";
		magazines[] = {"sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","vn_sa7_mag"};
		respawnMagazines[] = {"sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","sp_fwa_20Rnd_556_Ar18_Tracer","vn_sa7_mag"};
		linkedItems[] = {"acm_alc_vest_CarrierLite","H_HelmetAggressor_F","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_alc_vest_CarrierLite","H_HelmetAggressor_F","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		weapons[] = {"sp_fwa_ar18","vn_sa7b","Throw","Put"};
		respawnweapons[] = {"sp_fwa_ar18","vn_sa7b","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_AT_s"};
				speechPlural[] = {"veh_infantry_AT_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_AT_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_AT_p";
		nameSound = "veh_infantry_AT_s";
		icon = "iconManAT";
		role = "MissileSpecialist";
		camouflage = 1.5;
		cost = 130000;
		secondaryAmmoCoef = 0.5;
		threat[] = {0.8,0.1,1};
	};
	class ACM_o_alci_2035_men_Officer: ACM_o_alci_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_2035_men_Officer.jpg";
		displayName = "Officer";
		uniformClass = "acm_sam_clothes_m_2_1";
		magazines[] = {"vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag"};
		respawnMagazines[] = {"vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag"};
		linkedItems[] = {"vn_o_vest_vc_05","acm_alc_helmet_m1","G_Aviator","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"vn_o_vest_vc_05","acm_alc_helmet_m1","G_Aviator","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		weapons[] = {"vn_m1911","Binocular","Throw","Put"};
		respawnweapons[] = {"vn_m1911","Binocular","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_officer_s"};
				speechPlural[] = {"veh_infantry_officer_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_officer_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_officer_p";
		nameSound = "veh_infantry_officer_s";
		icon = "iconManOfficer";
		role = "Rifleman";
		camouflage = 1.6;
		cost = 250000;
	};
	class ACM_o_alci_2035_men_UAV: ACM_o_alci_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_2035_men_UAV.jpg";
		displayName = "UAV Specialist";
		uniformClass = "acm_sam_clothes_m_2_2";
		linkedItems[] = {"acm_alc_vest_Carrier","H_HeadSet_black_F","G_Goggles_VR","ItemMap","ItemCompass","ItemWatch","ItemRadio","O_UavTerminal"};
		respawnLinkedItems[] = {"acm_alc_vest_Carrier","H_HeadSet_black_F","G_Goggles_VR","ItemMap","ItemCompass","ItemWatch","ItemRadio","O_UavTerminal"};
		weapons[] = {"sp_fwa_ar18_carbine","Throw","Put"};
		respawnweapons[] = {"sp_fwa_ar18_carbine","Throw","Put"};
		backpack = "O_UAV_01_backpack_F";
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "SpecialOperative";
		uavHacker = 1;
	};
	class ACM_o_alci_2035_men_unarmed: ACM_o_alci_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_2035_men_unarmed.jpg";
		displayName = "Rifleman (Unarmed)";
		backpack = "";
		weapons[] = {"Throw","Put"};
		respawnWeapons[] = {"Throw","Put"};
		magazines[] = {};
		respawnMagazines[] = {};
		role = "Unarmed";
		threat[] = {0.1,0.1,0.1};
	};
	class ACM_o_alci_2035_men_survivor: ACM_o_alci_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_2035_men_survivor.jpg";
		displayName = "Survivor";
		uniformClass = "acm_sam_clothes_m_2_2";
		linkedItems[] = {"ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "";
		weapons[] = {"Throw","Put"};
		respawnWeapons[] = {"Throw","Put"};
		magazines[] = {};
		respawnMagazines[] = {};
		role = "Unarmed";
		threat[] = {0.1,0.1,0.1};
	};
	class ACM_o_alci_2035_men_JetPilot: ACM_o_alci_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_2035_men_Officer.jpg";
		displayName = "Fixed-Wing Pilot";
		uniformClass = "acm_sam_clothes_m_2_5";
		backpack = "vn_i_pack_parachute_01";
		magazines[] = {"vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m127_mag","vn_m127_mag","vn_m127_mag","O_IR_Grenade"};
		respawnMagazines[] = {"vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m1911_mag","vn_m127_mag","vn_m127_mag","vn_m127_mag","O_IR_Grenade"};
		linkedItems[] = {"vn_b_vest_aircrew_05","vn_o_helmet_zsh3_01","vn_o_acc_km32_01","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"vn_b_vest_aircrew_05","vn_o_helmet_zsh3_01","vn_o_acc_km32_01","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		weapons[] = {"vn_m1911","vn_m127","Throw","Put"};
		respawnweapons[] = {"vn_m1911","vn_m127","Throw","Put"};
		identityTypes[] = {"LanguageGRE_F","Head_NATO"};
		ACE_GForceCoef = 0.55;
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_s"};
				speechPlural[] = {"veh_infantry_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_p";
		nameSound = "veh_infantry_s";
		role = "Crewman";
		camouflage = 2;
		cost = 93000;
		engineer = 1;
	};
	class ACM_o_alci_2035_SF_Scout: ACM_o_alci_2035_men_rifleman
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_2035_SF_Scout.jpg";
		displayName = "Recon Scout";
		uniformClass = "acm_sam_clothes_m_3_1";
		magazines[] = {"30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag","vn_mk22_mag","vn_mk22_mag","vn_mk22_mag"};
		respawnMagazines[] = {"30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag","vn_mk22_mag","vn_mk22_mag","vn_mk22_mag"};
		linkedItems[] = {"acm_alc_vest_Smersh_Radio","acm_alc_helmet_avenger","acm_alc_g_stealth","O_NVGoggles_grn_F","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_alc_vest_Smersh_Radio","acm_alc_helmet_avenger","acm_alc_g_stealth","O_NVGoggles_grn_F","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "";
		weapons[] = {"acm_alc_m_sf_kat_c","vn_mk22","Throw","Put"};
		respawnweapons[] = {"acm_alc_m_sf_kat_c","vn_mk22","Throw","Put"};
		editorSubcategory = "EdSubcat_Personnel_SpecialForces";
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_SF_s"};
				speechPlural[] = {"veh_infantry_SF_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_SF_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_SF_p";
		nameSound = "veh_infantry_SF_s";
		role = "Rifleman";
		camouflage = 0.6;
		detectSkill = 18;
	};
	class ACM_o_alci_2035_SF_Scout_AT: ACM_o_alci_2035_SF_Scout
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_2035_SF_Scout_AT.jpg";
		displayName = "Recon Scout (AT)";
		magazines[] = {"30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag","vn_mk22_mag","vn_mk22_mag","vn_mk22_mag"};
		respawnMagazines[] = {"30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag","vn_mk22_mag","vn_mk22_mag","vn_mk22_mag"};
		linkedItems[] = {"acm_alc_vest_Smersh_NoRadio","acm_alc_helmet_avenger","acm_alc_g_stealth","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_alc_vest_Smersh_NoRadio","acm_alc_helmet_avenger","acm_alc_g_stealth","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "acm_bag_AL_M_AT_SF";
		weapons[] = {"acm_alc_m_sf_kat_c","vn_rpg7","Throw","Put"};
		respawnweapons[] = {"acm_alc_m_sf_kat_c","vn_rpg7","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_AT_s"};
				speechPlural[] = {"veh_infantry_AT_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_AT_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_AT_p";
		nameSound = "veh_infantry_AT_s";
		icon = "iconManAT";
		role = "MissileSpecialist";
		camouflage = 0.6;
		cost = 130000;
		detectSkill = 18;
		secondaryAmmoCoef = 0.5;
		threat[] = {0.8,0.8,0.3};
	};
	class ACM_o_alci_2035_SF_Grenadier: ACM_o_alci_2035_SF_Scout
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_2035_SF_Grenadier.jpg";
		displayName = "Recon Grenadier";
		magazines[] = {"30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","vn_mk22_mag","vn_mk22_mag","vn_mk22_mag","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","1Rnd_Smoke_Grenade_shell","1Rnd_Smoke_Grenade_shell","1Rnd_SmokeRed_Grenade_shell","1Rnd_SmokeRed_Grenade_shell"};
		respawnMagazines[] = {"30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","vn_mk22_mag","vn_mk22_mag","vn_mk22_mag","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","1Rnd_HE_Grenade_shell","1Rnd_Smoke_Grenade_shell","1Rnd_Smoke_Grenade_shell","1Rnd_SmokeRed_Grenade_shell","1Rnd_SmokeRed_Grenade_shell"};
		linkedItems[] = {"acm_alc_vest_Smersh_NoRadio","acm_alc_helmet_avenger","acm_alc_g_stealth","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_alc_vest_Smersh_NoRadio","acm_alc_helmet_avenger","acm_alc_g_stealth","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "vn_b_pack_02";
		weapons[] = {"acm_alc_m_sf_kat_GL","vn_mk22","Throw","Put"};
		respawnweapons[] = {"acm_alc_m_sf_kat_GL","vn_mk22","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_SF_s"};
				speechPlural[] = {"veh_infantry_SF_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_SF_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_SF_p";
		nameSound = "veh_infantry_SF_s";
		role = "Grenadier";
		camouflage = 0.6;
		cost = 200000;
		detectSkill = 18;
	};
	class ACM_o_alci_2035_SF_SL: ACM_o_alci_2035_SF_Scout
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_2035_SF_SL.jpg";
		displayName = "Recon Team Lead";
		magazines[] = {"30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag","vn_mk22_mag","vn_mk22_mag","vn_mk22_mag"};
		respawnMagazines[] = {"30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","30Rnd_65x39_caseless_green","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag","vn_mk22_mag","vn_mk22_mag","vn_mk22_mag"};
		linkedItems[] = {"acm_alc_vest_Smersh_Radio","acm_alc_helmet_avenger","acm_alc_g_stealth","O_NVGoggles_grn_F","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_alc_vest_Smersh_Radio","acm_alc_helmet_avenger","acm_alc_g_stealth","O_NVGoggles_grn_F","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		backpack = "vn_b_pack_03";
		weapons[] = {"acm_alc_m_sf_kat_TL","vn_mk22","Rangefinder","Throw","Put"};
		respawnweapons[] = {"acm_alc_m_sf_kat_TL","vn_mk22","Rangefinder","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_SF_s"};
				speechPlural[] = {"veh_infantry_SF_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_SF_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_SF_p";
		nameSound = "veh_infantry_SF_s";
		icon = "iconManLeader";
		role = "RadioOperator";
		camouflage = 0.6;
		cost = 250000;
		detectSkill = 18;
	};
	class ACM_o_alci_2035_SF_MR: ACM_o_alci_2035_SF_Scout
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_2035_SF_MR.jpg";
		displayName = "Recon Marksman";
		magazines[] = {"10Rnd_93x64_DMR_05_Mag","10Rnd_93x64_DMR_05_Mag","10Rnd_93x64_DMR_05_Mag","10Rnd_93x64_DMR_05_Mag","10Rnd_93x64_DMR_05_Mag","10Rnd_93x64_DMR_05_Mag","10Rnd_93x64_DMR_05_Mag","10Rnd_93x64_DMR_05_Mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag","vn_mk22_mag","vn_mk22_mag","vn_mk22_mag"};
		respawnMagazines[] = {"10Rnd_93x64_DMR_05_Mag","10Rnd_93x64_DMR_05_Mag","10Rnd_93x64_DMR_05_Mag","10Rnd_93x64_DMR_05_Mag","10Rnd_93x64_DMR_05_Mag","10Rnd_93x64_DMR_05_Mag","10Rnd_93x64_DMR_05_Mag","10Rnd_93x64_DMR_05_Mag","vn_m61_grenade_mag","vn_m61_grenade_mag","vn_m18_white_mag","vn_m18_white_mag","vn_mk22_mag","vn_mk22_mag","vn_mk22_mag"};
		linkedItems[] = {"acm_alc_vest_Smersh_NoRadio","acm_alc_headwear_boonie_m","acm_alc_g_bandana","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_alc_vest_Smersh_NoRadio","acm_alc_headwear_boonie_m","acm_alc_g_bandana","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		weapons[] = {"acm_alc_m_sf_DMR_05","vn_mk22","Rangefinder","Throw","Put"};
		respawnweapons[] = {"acm_alc_m_sf_DMR_05","vn_mk22","Rangefinder","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_sniper_s"};
				speechPlural[] = {"veh_infantry_sniper_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_sniper_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_sniper_p";
		nameSound = "veh_infantry_sniper_s";
		role = "Marksman";
		camouflage = 0.6;
		cost = 250000;
		detectSkill = 18;
	};
	class ACM_o_alci_2035_SF_AR: ACM_o_alci_2035_SF_Scout
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_2035_SF_AR.jpg";
		displayName = "Recon Autorifleman";
		magazines[] = {"200Rnd_556x45_Box_F","200Rnd_556x45_Box_F","200Rnd_556x45_Box_F","200Rnd_556x45_Box_F"};
		respawnMagazines[] = {"200Rnd_556x45_Box_F","200Rnd_556x45_Box_F","200Rnd_556x45_Box_F","200Rnd_556x45_Box_F"};
		linkedItems[] = {"acm_alc_vest_Smersh_NoRadio","acm_alc_helmet_avenger","acm_alc_g_stealth","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_alc_vest_Smersh_NoRadio","acm_alc_helmet_avenger","acm_alc_g_stealth","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		weapons[] = {"acm_alc_m_sf_LMG_03_F","Throw","Put"};
		respawnweapons[] = {"acm_alc_m_sf_LMG_03_F","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_MG_s"};
				speechPlural[] = {"veh_infantry_MG_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_MG_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_MG_p";
		nameSound = "veh_infantry_MG_s";
		icon = "iconManMG";
		role = "MachineGunner";
		camouflage = 0.6;
		cost = 220000;
		detectSkill = 38;
	};
	class ACM_o_alci_2035_SF_Demo: ACM_o_alci_2035_SF_Scout
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_2035_SF_Demo.jpg";
		displayName = "Recon Sapper";
		items[] = {"FirstAidKit","FirstAidKit","vn_b_item_trapkit"};
		linkedItems[] = {"acm_alc_vest_Smersh_NoRadio","acm_alc_g_stealth","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_alc_vest_Smersh_NoRadio","acm_alc_g_stealth","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		weapons[] = {"acm_alc_m_sf_kat_c","vn_mk22","Throw","Put"};
		respawnweapons[] = {"acm_alc_m_sf_kat_c","vn_mk22","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_SF_s"};
				speechPlural[] = {"veh_infantry_SF_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_SF_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_SF_p";
		nameSound = "veh_infantry_SF_s";
		icon = "iconManEngineer";
		picture = "pictureRepair";
		role = "Sapper";
		canDeactivateMines = 1;
		camouflage = 0.6;
		detectSkill = 38;
	};
	class ACM_o_alci_2035_SF_CLS: ACM_o_alci_2035_SF_Scout
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_2035_SF_CLS.jpg";
		displayName = "Recon CLS";
		linkedItems[] = {"acm_alc_vest_Smersh_Radio","H_HelmetAggressor_F","acm_alc_g_stealth","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"acm_alc_vest_Smersh_Radio","H_HelmetAggressor_F","acm_alc_g_stealth","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		weapons[] = {"acm_alc_m_sf_kat_c","vn_mk22","Throw","Put"};
		respawnweapons[] = {"acm_alc_m_sf_kat_c","vn_mk22","Throw","Put"};
		backpack = "acm_bag_sam_medic";
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_medic_s"};
				speechPlural[] = {"veh_infantry_medic_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_medic_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_medic_p";
		nameSound = "veh_infantry_medic_s";
		icon = "iconManMedic";
		picture = "pictureHeal";
		role = "CombatLifeSaver";
		attendant = 1;
		camouflage = 0.6;
		detectSkill = 18;
	};
	class ACM_o_alci_2035_SF_IS: ACM_o_alci_2035_SF_Scout
	{
		editorPreview = "\acm_saintanselm\ui\ACM_o_alci_2035_SF_IS.jpg";
		displayName = "Infiltration Specialist";
		backpack = "vn_b_pack_pfield_02";
		magazines[] = {"10Rnd_127x54_Mag","10Rnd_127x54_Mag","10Rnd_127x54_Mag","10Rnd_127x54_Mag","10Rnd_127x54_Mag","10Rnd_127x54_Mag","10Rnd_127x54_Mag","10Rnd_127x54_Mag","10Rnd_127x54_Mag","vn_molotov_grenade_mag","vn_molotov_grenade_mag","vn_m18_white_mag","vn_m18_white_mag","vn_mk22_mag","vn_mk22_mag","vn_mk22_mag","vn_mk22_mag","vn_mk22_mag"};
		respawnMagazines[] = {"10Rnd_127x54_Mag","10Rnd_127x54_Mag","10Rnd_127x54_Mag","10Rnd_127x54_Mag","10Rnd_127x54_Mag","10Rnd_127x54_Mag","10Rnd_127x54_Mag","10Rnd_127x54_Mag","10Rnd_127x54_Mag","vn_molotov_grenade_mag","vn_molotov_grenade_mag","vn_m18_white_mag","vn_m18_white_mag","vn_mk22_mag","vn_mk22_mag","vn_mk22_mag","vn_mk22_mag","vn_mk22_mag"};
		linkedItems[] = {"vn_b_vest_sog_04","acm_alc_helmet_avenger","acm_alc_g_stealth","O_NVGoggles_grn_F","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		respawnLinkedItems[] = {"vn_b_vest_sog_04","acm_alc_helmet_avenger","acm_alc_g_stealth","O_NVGoggles_grn_F","ItemGPS","ItemMap","ItemCompass","ItemWatch","ItemRadio"};
		weapons[] = {"srifle_DMR_04_ACO_F","vn_mk22","Rangefinder","Throw","Put"};
		respawnweapons[] = {"srifle_DMR_04_ACO_F","vn_mk22","Rangefinder","Throw","Put"};
		class SpeechVariants
		{
			class Default
			{
				speechSingular[] = {"veh_infantry_sniper_s"};
				speechPlural[] = {"veh_infantry_sniper_p"};
			};
		};
		textSingular = "$STR_A3_nameSound_veh_infantry_sniper_s";
		textPlural = "$STR_A3_nameSound_veh_infantry_sniper_p";
		nameSound = "veh_infantry_sniper_s";
		role = "Marksman";
		camouflage = 0.6;
		cost = 250000;
		detectSkill = 18;
	};
	class Box_NATO_Ammo_F;
	class Box_NATO_Wps_F;
	class Box_NATO_WpsLaunch_F;
	class Box_NATO_Uniforms_F;
	class Box_NATO_Support_F;
	class B_SupplyCrate_F;
	class ACM_B_SAC_2035_AmmoBox: Box_NATO_Ammo_F
	{
		author = "ALiVE ORBAT CREATOR";
		scope = 2;
		displayName = "Saint Anselm Constabulary (2035) Ammo Box";
		class TransportMagazines
		{
			class _xx_sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer
			{
				magazine = "sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer";
				count = 50;
			};
			class _xx_vn_m61_grenade_mag
			{
				magazine = "vn_m61_grenade_mag";
				count = 50;
			};
			class _xx_vn_m18_white_mag
			{
				magazine = "vn_m18_white_mag";
				count = 50;
			};
			class _xx_vn_m127_mag
			{
				magazine = "vn_m127_mag";
				count = 50;
			};
			class _xx_20Rnd_762x51_Mag
			{
				magazine = "20Rnd_762x51_Mag";
				count = 50;
			};
			class _xx_sp_fwa_1rnd_riflegrenade_mas_ap
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_ap";
				count = 50;
			};
			class _xx_sp_fwa_1rnd_riflegrenade_mas_wp
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_wp";
				count = 50;
			};
			class _xx_sp_fwa_1rnd_riflegrenade_mas_at_l
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_at_l";
				count = 50;
			};
			class _xx_30Rnd_45ACP_Mag_SMG_01
			{
				magazine = "30Rnd_45ACP_Mag_SMG_01";
				count = 50;
			};
			class _xx_sp_fwa_20Rnd_9mm_HiPower
			{
				magazine = "sp_fwa_20Rnd_9mm_HiPower";
				count = 50;
			};
			class _xx_vn_m67_grenade_mag
			{
				magazine = "vn_m67_grenade_mag";
				count = 50;
			};
			class _xx_vn_m60_100_mag
			{
				magazine = "vn_m60_100_mag";
				count = 50;
			};
			class _xx_vn_m18_yellow_mag
			{
				magazine = "vn_m18_yellow_mag";
				count = 50;
			};
			class _xx_vn_mine_m14_mag
			{
				magazine = "vn_mine_m14_mag";
				count = 50;
			};
			class _xx_MRAWS_HEAT_F
			{
				magazine = "MRAWS_HEAT_F";
				count = 50;
			};
			class _xx_vn_mine_m112_remote_mag
			{
				magazine = "vn_mine_m112_remote_mag";
				count = 50;
			};
			class _xx_vn_mine_tripwire_m49_02_mag
			{
				magazine = "vn_mine_tripwire_m49_02_mag";
				count = 50;
			};
			class _xx_vn_mine_m18_x3_range_mag
			{
				magazine = "vn_mine_m18_x3_range_mag";
				count = 50;
			};
			class _xx_vn_mine_satchel_remote_02_mag
			{
				magazine = "vn_mine_satchel_remote_02_mag";
				count = 50;
			};
			class _xx_vn_mine_tm57_mag
			{
				magazine = "vn_mine_tm57_mag";
				count = 50;
			};
			class _xx_sp_fwa_13Rnd_9mm_HiPower
			{
				magazine = "sp_fwa_13Rnd_9mm_HiPower";
				count = 50;
			};
			class _xx_sp_fwa_30Rnd_556_Armalite_Ball
			{
				magazine = "sp_fwa_30Rnd_556_Armalite_Ball";
				count = 50;
			};
			class _xx_1Rnd_HE_Grenade_shell
			{
				magazine = "1Rnd_HE_Grenade_shell";
				count = 50;
			};
			class _xx_UGL_FlareWhite_F
			{
				magazine = "UGL_FlareWhite_F";
				count = 50;
			};
			class _xx_1Rnd_Smoke_Grenade_shell
			{
				magazine = "1Rnd_Smoke_Grenade_shell";
				count = 50;
			};
			class _xx_30Rnd_65x39_caseless_black_mag
			{
				magazine = "30Rnd_65x39_caseless_black_mag";
				count = 50;
			};
			class _xx_vn_m14_early_grenade_mag
			{
				magazine = "vn_m14_early_grenade_mag";
				count = 50;
			};
			class _xx_100Rnd_65x39_caseless_black_mag
			{
				magazine = "100Rnd_65x39_caseless_black_mag";
				count = 50;
			};
			class _xx_sp_fwa_10Rnd_762_L42
			{
				magazine = "sp_fwa_10Rnd_762_L42";
				count = 50;
			};
			class _xx_sp_fwa_20Rnd_556_Ruger_Mini14
			{
				magazine = "sp_fwa_20Rnd_556_Ruger_Mini14";
				count = 50;
			};
			class _xx_sp_fwa_8Rnd_3006_Garand
			{
				magazine = "sp_fwa_8Rnd_3006_Garand";
				count = 50;
			};
			class _xx_sp_fwa_20Rnd_762_FN49_tracer
			{
				magazine = "sp_fwa_20Rnd_762_FN49_tracer";
				count = 50;
			};
			class _xx_vn_type56_mag
			{
				magazine = "vn_type56_mag";
				count = 50;
			};
			class _xx_vn_sks_mag
			{
				magazine = "vn_sks_mag";
				count = 50;
			};
			class _xx_sp_fwa_30Rnd_556_Armalite
			{
				magazine = "sp_fwa_30Rnd_556_Armalite";
				count = 50;
			};
			class _xx_sp_fwa_30Rnd_Curved_762_FAL_Metric
			{
				magazine = "sp_fwa_30Rnd_Curved_762_FAL_Metric";
				count = 50;
			};
			class _xx_vn_m38_mag
			{
				magazine = "vn_m38_mag";
				count = 50;
			};
			class _xx_sp_fwa_20Rnd_762_FAL_Metric
			{
				magazine = "sp_fwa_20Rnd_762_FAL_Metric";
				count = 50;
			};
			class _xx_sp_fwa_32Rnd_9x19_L2A3_Sterling
			{
				magazine = "sp_fwa_32Rnd_9x19_L2A3_Sterling";
				count = 50;
			};
		};
		class TransportWeapons{};
		class TransportItems{};
	};
	class ACM_B_SAC_2035_WeaponsBox: Box_NATO_Wps_F
	{
		author = "ALiVE ORBAT CREATOR";
		scope = 2;
		displayName = "Saint Anselm Constabulary (2035) Weapons Box";
		class TransportMagazines
		{
			class _xx_sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer
			{
				magazine = "sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer";
				count = 50;
			};
			class _xx_20Rnd_762x51_Mag
			{
				magazine = "20Rnd_762x51_Mag";
				count = 50;
			};
			class _xx_sp_fwa_1rnd_riflegrenade_mas_at_l
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_at_l";
				count = 50;
			};
			class _xx_30Rnd_45ACP_Mag_SMG_01
			{
				magazine = "30Rnd_45ACP_Mag_SMG_01";
				count = 50;
			};
			class _xx_vn_m60_100_mag
			{
				magazine = "vn_m60_100_mag";
				count = 50;
			};
			class _xx_sp_fwa_20Rnd_9mm_HiPower
			{
				magazine = "sp_fwa_20Rnd_9mm_HiPower";
				count = 50;
			};
			class _xx_sp_fwa_13Rnd_9mm_HiPower
			{
				magazine = "sp_fwa_13Rnd_9mm_HiPower";
				count = 50;
			};
			class _xx_sp_fwa_30Rnd_556_Armalite_Ball
			{
				magazine = "sp_fwa_30Rnd_556_Armalite_Ball";
				count = 50;
			};
			class _xx_1Rnd_HE_Grenade_shell
			{
				magazine = "1Rnd_HE_Grenade_shell";
				count = 50;
			};
			class _xx_30Rnd_65x39_caseless_black_mag
			{
				magazine = "30Rnd_65x39_caseless_black_mag";
				count = 50;
			};
			class _xx_100Rnd_65x39_caseless_black_mag
			{
				magazine = "100Rnd_65x39_caseless_black_mag";
				count = 50;
			};
			class _xx_sp_fwa_10Rnd_762_L42
			{
				magazine = "sp_fwa_10Rnd_762_L42";
				count = 50;
			};
			class _xx_sp_fwa_20Rnd_556_Ruger_Mini14
			{
				magazine = "sp_fwa_20Rnd_556_Ruger_Mini14";
				count = 50;
			};
			class _xx_sp_fwa_8Rnd_3006_Garand
			{
				magazine = "sp_fwa_8Rnd_3006_Garand";
				count = 50;
			};
			class _xx_sp_fwa_20Rnd_762_FN49_tracer
			{
				magazine = "sp_fwa_20Rnd_762_FN49_tracer";
				count = 50;
			};
			class _xx_vn_type56_mag
			{
				magazine = "vn_type56_mag";
				count = 50;
			};
			class _xx_vn_sks_mag
			{
				magazine = "vn_sks_mag";
				count = 50;
			};
			class _xx_sp_fwa_30Rnd_556_Armalite
			{
				magazine = "sp_fwa_30Rnd_556_Armalite";
				count = 50;
			};
			class _xx_sp_fwa_30Rnd_Curved_762_FAL_Metric
			{
				magazine = "sp_fwa_30Rnd_Curved_762_FAL_Metric";
				count = 50;
			};
			class _xx_vn_m38_mag
			{
				magazine = "vn_m38_mag";
				count = 50;
			};
			class _xx_sp_fwa_20Rnd_762_FAL_Metric
			{
				magazine = "sp_fwa_20Rnd_762_FAL_Metric";
				count = 50;
			};
			class _xx_sp_fwa_32Rnd_9x19_L2A3_Sterling
			{
				magazine = "sp_fwa_32Rnd_9x19_L2A3_Sterling";
				count = 50;
			};
		};
		class TransportWeapons
		{
			class _xx_sp_fwa_fal_factory_50_64
			{
				weapon = "sp_fwa_fal_factory_50_64";
				count = 10;
			};
			class _xx_sp_fwa_fal_factory_50_63
			{
				weapon = "sp_fwa_fal_factory_50_63";
				count = 10;
			};
			class _xx_acm_sac_m_sp_fal64_scope
			{
				weapon = "acm_sac_m_sp_fal64_scope";
				count = 10;
			};
			class _xx_arifle_SPAR_03_blk_MOS_Pointer_Bipod_F
			{
				weapon = "arifle_SPAR_03_blk_MOS_Pointer_Bipod_F";
				count = 10;
			};
			class _xx_SMG_01_F
			{
				weapon = "SMG_01_F";
				count = 10;
			};
			class _xx_vn_m60
			{
				weapon = "vn_m60";
				count = 10;
			};
			class _xx_sp_fwa_l9a1_hipower
			{
				weapon = "sp_fwa_l9a1_hipower";
				count = 10;
			};
			class _xx_acm_sac_m_trg20
			{
				weapon = "acm_sac_m_trg20";
				count = 10;
			};
			class _xx_acm_sac_m_trg21
			{
				weapon = "acm_sac_m_trg21";
				count = 10;
			};
			class _xx_acm_sac_m_trg21_gl
			{
				weapon = "acm_sac_m_trg21_gl";
				count = 10;
			};
			class _xx_acm_sac_m_MXM
			{
				weapon = "acm_sac_m_MXM";
				count = 10;
			};
			class _xx_acm_sac_m_MX_SW
			{
				weapon = "acm_sac_m_MX_SW";
				count = 10;
			};
			class _xx_sp_fwa_enfield_l8_walnut
			{
				weapon = "sp_fwa_enfield_l8_walnut";
				count = 10;
			};
			class _xx_sp_fwa_ruger_mini14_ac556
			{
				weapon = "sp_fwa_ruger_mini14_ac556";
				count = 10;
			};
			class _xx_sp_fwa_m1_garand
			{
				weapon = "sp_fwa_m1_garand";
				count = 10;
			};
			class _xx_sp_fwa_fn49_arg
			{
				weapon = "sp_fwa_fn49_arg";
				count = 10;
			};
			class _xx_vn_type56
			{
				weapon = "vn_type56";
				count = 10;
			};
			class _xx_vn_sks
			{
				weapon = "vn_sks";
				count = 10;
			};
			class _xx_sp_fwa_651_CAR15
			{
				weapon = "sp_fwa_651_CAR15";
				count = 10;
			};
			class _xx_sp_fwa_bren_l4_lmg
			{
				weapon = "sp_fwa_bren_l4_lmg";
				count = 10;
			};
			class _xx_acm_sac_m_cr_m19130
			{
				weapon = "acm_sac_m_cr_m19130";
				count = 10;
			};
			class _xx_sp_fwa_fal_l1a1_wood
			{
				weapon = "sp_fwa_fal_l1a1_wood";
				count = 10;
			};
			class _xx_sp_fwa_enfield_l42_walnut
			{
				weapon = "sp_fwa_enfield_l42_walnut";
				count = 10;
			};
			class _xx_sp_fwa_smg_sterling
			{
				weapon = "sp_fwa_smg_sterling";
				count = 10;
			};
		};
		class TransportItems
		{
			class _xx_sp_fwa_scope_fal_fn_factory
			{
				name = "sp_fwa_scope_fal_fn_factory";
				count = 10;
			};
			class _xx_sp_fwa_acc_bipod_fal
			{
				name = "sp_fwa_acc_bipod_fal";
				count = 10;
			};
			class _xx_acc_pointer_IR
			{
				name = "acc_pointer_IR";
				count = 10;
			};
			class _xx_optic_SOS
			{
				name = "optic_SOS";
				count = 10;
			};
			class _xx_bipod_01_F_blk
			{
				name = "bipod_01_F_blk";
				count = 10;
			};
			class _xx_muzzle_snds_M
			{
				name = "muzzle_snds_M";
				count = 10;
			};
			class _xx_optic_Hamr
			{
				name = "optic_Hamr";
				count = 10;
			};
			class _xx_muzzle_snds_65_TI_blk_F
			{
				name = "muzzle_snds_65_TI_blk_F";
				count = 10;
			};
			class _xx_vn_o_3x_m9130
			{
				name = "vn_o_3x_m9130";
				count = 10;
			};
			class _xx_vn_b_camo_m9130
			{
				name = "vn_b_camo_m9130";
				count = 10;
			};
		};
	};
	class ACM_B_SAC_2035_LaunchersBox: Box_NATO_WpsLaunch_F
	{
		author = "ALiVE ORBAT CREATOR";
		scope = 2;
		displayName = "Saint Anselm Constabulary (2035) Launchers Box";
		class TransportMagazines
		{
			class _xx_NLAW_F
			{
				magazine = "NLAW_F";
				count = 5;
			};
			class _xx_vn_m127_mag
			{
				magazine = "vn_m127_mag";
				count = 5;
			};
			class _xx_MRAWS_HEAT_F
			{
				magazine = "MRAWS_HEAT_F";
				count = 5;
			};
			class _xx_vn_sa7_mag
			{
				magazine = "vn_sa7_mag";
				count = 5;
			};
		};
		class TransportWeapons
		{
			class _xx_launch_NLAW_F
			{
				weapon = "launch_NLAW_F";
				count = 5;
			};
			class _xx_vn_m127
			{
				weapon = "vn_m127";
				count = 5;
			};
			class _xx_sp_fwa_m2_carlGustav_no78
			{
				weapon = "sp_fwa_m2_carlGustav_no78";
				count = 5;
			};
			class _xx_vn_sa7
			{
				weapon = "vn_sa7";
				count = 5;
			};
		};
		class TransportItems{};
	};
	class ACM_B_SAC_2035_UniformBox: Box_NATO_Uniforms_F
	{
		author = "ALiVE ORBAT CREATOR";
		scope = 2;
		displayName = "Saint Anselm Constabulary (2035) Uniform Box";
		class TransportWeapons{};
		class TransportMagazines{};
		class TransportItems
		{
			class _xx_acm_sam_clothes_m_1_1
			{
				name = "acm_sam_clothes_m_1_1";
				count = 15;
			};
			class _xx_acm_sam_clothes_m_1_2
			{
				name = "acm_sam_clothes_m_1_2";
				count = 15;
			};
			class _xx_acm_sam_clothes_m_1_4
			{
				name = "acm_sam_clothes_m_1_4";
				count = 15;
			};
			class _xx_acm_sam_clothes_m_1_3
			{
				name = "acm_sam_clothes_m_1_3";
				count = 15;
			};
			class _xx_acm_sam_clothes01_3
			{
				name = "acm_sam_clothes01_3";
				count = 15;
			};
		};
	};
	class ACM_B_SAC_2035_SupportBox: Box_NATO_Support_F
	{
		author = "ALiVE ORBAT CREATOR";
		scope = 2;
		displayName = "Saint Anselm Constabulary (2035) Support Box";
		class TransportWeapons{};
		class TransportMagazines{};
		class TransportItems
		{
			class _xx_acm_sam_m_vest2
			{
				name = "acm_sam_m_vest2";
				count = 10;
			};
			class _xx_acm_pasgt_base
			{
				name = "acm_pasgt_base";
				count = 10;
			};
			class _xx_vn_b_pack_lw_01
			{
				name = "vn_b_pack_lw_01";
				count = 10;
			};
			class _xx_ItemMap
			{
				name = "ItemMap";
				count = 10;
			};
			class _xx_ItemCompass
			{
				name = "ItemCompass";
				count = 10;
			};
			class _xx_ItemWatch
			{
				name = "ItemWatch";
				count = 10;
			};
			class _xx_ItemRadio
			{
				name = "ItemRadio";
				count = 10;
			};
			class _xx_ItemGPS
			{
				name = "ItemGPS";
				count = 10;
			};
			class _xx_acm_sam_m_vest1
			{
				name = "acm_sam_m_vest1";
				count = 10;
			};
			class _xx_acm_pasgt_esscover_front
			{
				name = "acm_pasgt_esscover_front";
				count = 10;
			};
			class _xx_acm_pasgt_scrim
			{
				name = "acm_pasgt_scrim";
				count = 10;
			};
			class _xx_acm_sam_g_bandana
			{
				name = "acm_sam_g_bandana";
				count = 10;
			};
			class _xx_vn_b_vest_seal_05
			{
				name = "vn_b_vest_seal_05";
				count = 10;
			};
			class _xx_acm_pasgt_nocover
			{
				name = "acm_pasgt_nocover";
				count = 10;
			};
			class _xx_Rangefinder
			{
				name = "Rangefinder";
				count = 10;
			};
			class _xx_acm_pasgt_esscover_back
			{
				name = "acm_pasgt_esscover_back";
				count = 10;
			};
			class _xx_vn_b_pack_trp_04_02
			{
				name = "vn_b_pack_trp_04_02";
				count = 10;
			};
			class _xx_vn_b_pack_lw_05
			{
				name = "vn_b_pack_lw_05";
				count = 10;
			};
			class _xx_acm_pasgt_goggles
			{
				name = "acm_pasgt_goggles";
				count = 10;
			};
			class _xx_acm_bag_sam_grenadier
			{
				name = "acm_bag_sam_grenadier";
				count = 10;
			};
			class _xx_acm_sam_m_vest3
			{
				name = "acm_sam_m_vest3";
				count = 10;
			};
			class _xx_vn_b_pack_lw_02_m60_pl
			{
				name = "vn_b_pack_lw_02_m60_pl";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_13
			{
				name = "vn_b_vest_usarmy_13";
				count = 10;
			};
			class _xx_vn_b_helmet_t56_02_01
			{
				name = "vn_b_helmet_t56_02_01";
				count = 10;
			};
			class _xx_acm_bag_sam_medic
			{
				name = "acm_bag_sam_medic";
				count = 10;
			};
			class _xx_vn_b_pack_lw_06
			{
				name = "vn_b_pack_lw_06";
				count = 10;
			};
			class _xx_H_HeadSet_black_F
			{
				name = "H_HeadSet_black_F";
				count = 10;
			};
			class _xx_acm_bag_sam_2035_AT
			{
				name = "acm_bag_sam_2035_AT";
				count = 10;
			};
			class _xx_acm_bag_sam_demo
			{
				name = "acm_bag_sam_demo";
				count = 10;
			};
			class _xx_acm_sam_headwear_beret_anselm
			{
				name = "acm_sam_headwear_beret_anselm";
				count = 10;
			};
			class _xx_G_Goggles_VR
			{
				name = "G_Goggles_VR";
				count = 10;
			};
			class _xx_B_UAV_01_backpack_F
			{
				name = "B_UAV_01_backpack_F";
				count = 10;
			};
			class _xx_B_UGV_02_Demining_backpack_F
			{
				name = "B_UGV_02_Demining_backpack_F";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_14
			{
				name = "vn_b_vest_usarmy_14";
				count = 10;
			};
			class _xx_Binocular
			{
				name = "Binocular";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_09
			{
				name = "vn_b_vest_usarmy_09";
				count = 10;
			};
			class _xx_vn_b_item_compass
			{
				name = "vn_b_item_compass";
				count = 10;
			};
			class _xx_vn_b_item_watch
			{
				name = "vn_b_item_watch";
				count = 10;
			};
			class _xx_vn_b_item_radio_urc10
			{
				name = "vn_b_item_radio_urc10";
				count = 10;
			};
			class _xx_V_CarrierRigKBT_01_light_Olive_F
			{
				name = "V_CarrierRigKBT_01_light_Olive_F";
				count = 10;
			};
			class _xx_acm_fast_anselm_base
			{
				name = "acm_fast_anselm_base";
				count = 10;
			};
			class _xx_NVGoggles
			{
				name = "NVGoggles";
				count = 10;
			};
			class _xx_acm_fast_anselm_accessory
			{
				name = "acm_fast_anselm_accessory";
				count = 10;
			};
			class _xx_acm_fast_anselm_chops
			{
				name = "acm_fast_anselm_chops";
				count = 10;
			};
			class _xx_acm_bag_sam_2035_MG
			{
				name = "acm_bag_sam_2035_MG";
				count = 10;
			};
			class _xx_V_CarrierRigKBT_01_Olive_F
			{
				name = "V_CarrierRigKBT_01_Olive_F";
				count = 10;
			};
			class _xx_ACM_Helmet_Mk5_Cover_multi
			{
				name = "ACM_Helmet_Mk5_Cover_multi";
				count = 10;
			};
			class _xx_ACM_vn_backpack_seal_01
			{
				name = "ACM_vn_backpack_seal_01";
				count = 10;
			};
			class _xx_ACM_Helmet_Mk5_Cover_Net_Multi
			{
				name = "ACM_Helmet_Mk5_Cover_Net_Multi";
				count = 10;
			};
			class _xx_acm_bag_sam_cr_ruger
			{
				name = "acm_bag_sam_cr_ruger";
				count = 10;
			};
			class _xx_ACM_Helmet_Mk5_Nostrap
			{
				name = "ACM_Helmet_Mk5_Nostrap";
				count = 10;
			};
			class _xx_acm_bag_sam_cr_garand
			{
				name = "acm_bag_sam_cr_garand";
				count = 10;
			};
			class _xx_ACM_Misc_Clothband_Blue
			{
				name = "ACM_Misc_Clothband_Blue";
				count = 10;
			};
			class _xx_acm_bag_sam_cr_FN49
			{
				name = "acm_bag_sam_cr_FN49";
				count = 10;
			};
			class _xx_acm_bag_sam_cr_AK
			{
				name = "acm_bag_sam_cr_AK";
				count = 10;
			};
			class _xx_vn_mk21_binocs
			{
				name = "vn_mk21_binocs";
				count = 10;
			};
			class _xx_acm_bag_sam_cr_AR
			{
				name = "acm_bag_sam_cr_AR";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_03
			{
				name = "vn_b_vest_usarmy_03";
				count = 10;
			};
			class _xx_acm_sam_headwear_boonie_Fold_m
			{
				name = "acm_sam_headwear_boonie_Fold_m";
				count = 10;
			};
			class _xx_acm_bag_sam_hmg
			{
				name = "acm_bag_sam_hmg";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_02
			{
				name = "vn_b_vest_usarmy_02";
				count = 10;
			};
			class _xx_acm_sam_headwear_boonie
			{
				name = "acm_sam_headwear_boonie";
				count = 10;
			};
			class _xx_V_TacVest_oli
			{
				name = "V_TacVest_oli";
				count = 10;
			};
			class _xx_ACM_Helmet_Mk5_Scrim2
			{
				name = "ACM_Helmet_Mk5_Scrim2";
				count = 10;
			};
		};
	};
	class ACM_B_SAC_2035_SupplyBox: B_SupplyCrate_F
	{
		author = "ALiVE ORBAT CREATOR";
		scope = 2;
		displayName = "Saint Anselm Constabulary (2035) Supply Box";
		class TransportMagazines
		{
			class _xx_sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer
			{
				magazine = "sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer";
				count = 50;
			};
			class _xx_vn_m61_grenade_mag
			{
				magazine = "vn_m61_grenade_mag";
				count = 50;
			};
			class _xx_vn_m18_white_mag
			{
				magazine = "vn_m18_white_mag";
				count = 50;
			};
			class _xx_vn_m127_mag
			{
				magazine = "vn_m127_mag";
				count = 50;
			};
			class _xx_20Rnd_762x51_Mag
			{
				magazine = "20Rnd_762x51_Mag";
				count = 50;
			};
			class _xx_sp_fwa_1rnd_riflegrenade_mas_ap
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_ap";
				count = 50;
			};
			class _xx_sp_fwa_1rnd_riflegrenade_mas_wp
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_wp";
				count = 50;
			};
			class _xx_sp_fwa_1rnd_riflegrenade_mas_at_l
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_at_l";
				count = 50;
			};
			class _xx_30Rnd_45ACP_Mag_SMG_01
			{
				magazine = "30Rnd_45ACP_Mag_SMG_01";
				count = 50;
			};
			class _xx_sp_fwa_20Rnd_9mm_HiPower
			{
				magazine = "sp_fwa_20Rnd_9mm_HiPower";
				count = 50;
			};
			class _xx_vn_m67_grenade_mag
			{
				magazine = "vn_m67_grenade_mag";
				count = 50;
			};
			class _xx_vn_m60_100_mag
			{
				magazine = "vn_m60_100_mag";
				count = 50;
			};
			class _xx_vn_m18_yellow_mag
			{
				magazine = "vn_m18_yellow_mag";
				count = 50;
			};
			class _xx_vn_mine_m14_mag
			{
				magazine = "vn_mine_m14_mag";
				count = 50;
			};
			class _xx_MRAWS_HEAT_F
			{
				magazine = "MRAWS_HEAT_F";
				count = 50;
			};
			class _xx_vn_mine_m112_remote_mag
			{
				magazine = "vn_mine_m112_remote_mag";
				count = 50;
			};
			class _xx_vn_mine_tripwire_m49_02_mag
			{
				magazine = "vn_mine_tripwire_m49_02_mag";
				count = 50;
			};
			class _xx_vn_mine_m18_x3_range_mag
			{
				magazine = "vn_mine_m18_x3_range_mag";
				count = 50;
			};
			class _xx_vn_mine_satchel_remote_02_mag
			{
				magazine = "vn_mine_satchel_remote_02_mag";
				count = 50;
			};
			class _xx_vn_mine_tm57_mag
			{
				magazine = "vn_mine_tm57_mag";
				count = 50;
			};
			class _xx_sp_fwa_13Rnd_9mm_HiPower
			{
				magazine = "sp_fwa_13Rnd_9mm_HiPower";
				count = 50;
			};
			class _xx_sp_fwa_30Rnd_556_Armalite_Ball
			{
				magazine = "sp_fwa_30Rnd_556_Armalite_Ball";
				count = 50;
			};
			class _xx_1Rnd_HE_Grenade_shell
			{
				magazine = "1Rnd_HE_Grenade_shell";
				count = 50;
			};
			class _xx_UGL_FlareWhite_F
			{
				magazine = "UGL_FlareWhite_F";
				count = 50;
			};
			class _xx_1Rnd_Smoke_Grenade_shell
			{
				magazine = "1Rnd_Smoke_Grenade_shell";
				count = 50;
			};
			class _xx_30Rnd_65x39_caseless_black_mag
			{
				magazine = "30Rnd_65x39_caseless_black_mag";
				count = 50;
			};
			class _xx_vn_m14_early_grenade_mag
			{
				magazine = "vn_m14_early_grenade_mag";
				count = 50;
			};
			class _xx_100Rnd_65x39_caseless_black_mag
			{
				magazine = "100Rnd_65x39_caseless_black_mag";
				count = 50;
			};
			class _xx_sp_fwa_10Rnd_762_L42
			{
				magazine = "sp_fwa_10Rnd_762_L42";
				count = 50;
			};
			class _xx_sp_fwa_20Rnd_556_Ruger_Mini14
			{
				magazine = "sp_fwa_20Rnd_556_Ruger_Mini14";
				count = 50;
			};
			class _xx_sp_fwa_8Rnd_3006_Garand
			{
				magazine = "sp_fwa_8Rnd_3006_Garand";
				count = 50;
			};
			class _xx_sp_fwa_20Rnd_762_FN49_tracer
			{
				magazine = "sp_fwa_20Rnd_762_FN49_tracer";
				count = 50;
			};
			class _xx_vn_type56_mag
			{
				magazine = "vn_type56_mag";
				count = 50;
			};
			class _xx_vn_sks_mag
			{
				magazine = "vn_sks_mag";
				count = 50;
			};
			class _xx_sp_fwa_30Rnd_556_Armalite
			{
				magazine = "sp_fwa_30Rnd_556_Armalite";
				count = 50;
			};
			class _xx_sp_fwa_30Rnd_Curved_762_FAL_Metric
			{
				magazine = "sp_fwa_30Rnd_Curved_762_FAL_Metric";
				count = 50;
			};
			class _xx_vn_m38_mag
			{
				magazine = "vn_m38_mag";
				count = 50;
			};
			class _xx_sp_fwa_20Rnd_762_FAL_Metric
			{
				magazine = "sp_fwa_20Rnd_762_FAL_Metric";
				count = 50;
			};
			class _xx_sp_fwa_32Rnd_9x19_L2A3_Sterling
			{
				magazine = "sp_fwa_32Rnd_9x19_L2A3_Sterling";
				count = 50;
			};
		};
		class TransportWeapons
		{
			class _xx_sp_fwa_fal_factory_50_64
			{
				weapon = "sp_fwa_fal_factory_50_64";
				count = 10;
			};
			class _xx_sp_fwa_fal_factory_50_63
			{
				weapon = "sp_fwa_fal_factory_50_63";
				count = 10;
			};
			class _xx_acm_sac_m_sp_fal64_scope
			{
				weapon = "acm_sac_m_sp_fal64_scope";
				count = 10;
			};
			class _xx_arifle_SPAR_03_blk_MOS_Pointer_Bipod_F
			{
				weapon = "arifle_SPAR_03_blk_MOS_Pointer_Bipod_F";
				count = 10;
			};
			class _xx_SMG_01_F
			{
				weapon = "SMG_01_F";
				count = 10;
			};
			class _xx_vn_m60
			{
				weapon = "vn_m60";
				count = 10;
			};
			class _xx_sp_fwa_l9a1_hipower
			{
				weapon = "sp_fwa_l9a1_hipower";
				count = 10;
			};
			class _xx_acm_sac_m_trg20
			{
				weapon = "acm_sac_m_trg20";
				count = 10;
			};
			class _xx_acm_sac_m_trg21
			{
				weapon = "acm_sac_m_trg21";
				count = 10;
			};
			class _xx_acm_sac_m_trg21_gl
			{
				weapon = "acm_sac_m_trg21_gl";
				count = 10;
			};
			class _xx_acm_sac_m_MXM
			{
				weapon = "acm_sac_m_MXM";
				count = 10;
			};
			class _xx_acm_sac_m_MX_SW
			{
				weapon = "acm_sac_m_MX_SW";
				count = 10;
			};
			class _xx_sp_fwa_enfield_l8_walnut
			{
				weapon = "sp_fwa_enfield_l8_walnut";
				count = 10;
			};
			class _xx_sp_fwa_ruger_mini14_ac556
			{
				weapon = "sp_fwa_ruger_mini14_ac556";
				count = 10;
			};
			class _xx_sp_fwa_m1_garand
			{
				weapon = "sp_fwa_m1_garand";
				count = 10;
			};
			class _xx_sp_fwa_fn49_arg
			{
				weapon = "sp_fwa_fn49_arg";
				count = 10;
			};
			class _xx_vn_type56
			{
				weapon = "vn_type56";
				count = 10;
			};
			class _xx_vn_sks
			{
				weapon = "vn_sks";
				count = 10;
			};
			class _xx_sp_fwa_651_CAR15
			{
				weapon = "sp_fwa_651_CAR15";
				count = 10;
			};
			class _xx_sp_fwa_bren_l4_lmg
			{
				weapon = "sp_fwa_bren_l4_lmg";
				count = 10;
			};
			class _xx_acm_sac_m_cr_m19130
			{
				weapon = "acm_sac_m_cr_m19130";
				count = 10;
			};
			class _xx_sp_fwa_fal_l1a1_wood
			{
				weapon = "sp_fwa_fal_l1a1_wood";
				count = 10;
			};
			class _xx_sp_fwa_enfield_l42_walnut
			{
				weapon = "sp_fwa_enfield_l42_walnut";
				count = 10;
			};
			class _xx_sp_fwa_smg_sterling
			{
				weapon = "sp_fwa_smg_sterling";
				count = 10;
			};
			class _xx_launch_NLAW_F
			{
				weapon = "launch_NLAW_F";
				count = 10;
			};
			class _xx_vn_m127
			{
				weapon = "vn_m127";
				count = 10;
			};
			class _xx_sp_fwa_m2_carlGustav_no78
			{
				weapon = "sp_fwa_m2_carlGustav_no78";
				count = 10;
			};
			class _xx_vn_sa7
			{
				weapon = "vn_sa7";
				count = 10;
			};
		};
		class TransportItems
		{
			class _xx_sp_fwa_scope_fal_fn_factory
			{
				name = "sp_fwa_scope_fal_fn_factory";
				count = 10;
			};
			class _xx_sp_fwa_acc_bipod_fal
			{
				name = "sp_fwa_acc_bipod_fal";
				count = 10;
			};
			class _xx_acc_pointer_IR
			{
				name = "acc_pointer_IR";
				count = 10;
			};
			class _xx_optic_SOS
			{
				name = "optic_SOS";
				count = 10;
			};
			class _xx_bipod_01_F_blk
			{
				name = "bipod_01_F_blk";
				count = 10;
			};
			class _xx_muzzle_snds_M
			{
				name = "muzzle_snds_M";
				count = 10;
			};
			class _xx_optic_Hamr
			{
				name = "optic_Hamr";
				count = 10;
			};
			class _xx_muzzle_snds_65_TI_blk_F
			{
				name = "muzzle_snds_65_TI_blk_F";
				count = 10;
			};
			class _xx_vn_o_3x_m9130
			{
				name = "vn_o_3x_m9130";
				count = 10;
			};
			class _xx_vn_b_camo_m9130
			{
				name = "vn_b_camo_m9130";
				count = 10;
			};
			class _xx_acm_sam_m_vest2
			{
				name = "acm_sam_m_vest2";
				count = 10;
			};
			class _xx_acm_pasgt_base
			{
				name = "acm_pasgt_base";
				count = 10;
			};
			class _xx_vn_b_pack_lw_01
			{
				name = "vn_b_pack_lw_01";
				count = 10;
			};
			class _xx_ItemMap
			{
				name = "ItemMap";
				count = 10;
			};
			class _xx_ItemCompass
			{
				name = "ItemCompass";
				count = 10;
			};
			class _xx_ItemWatch
			{
				name = "ItemWatch";
				count = 10;
			};
			class _xx_ItemRadio
			{
				name = "ItemRadio";
				count = 10;
			};
			class _xx_ItemGPS
			{
				name = "ItemGPS";
				count = 10;
			};
			class _xx_acm_sam_m_vest1
			{
				name = "acm_sam_m_vest1";
				count = 10;
			};
			class _xx_acm_pasgt_esscover_front
			{
				name = "acm_pasgt_esscover_front";
				count = 10;
			};
			class _xx_acm_pasgt_scrim
			{
				name = "acm_pasgt_scrim";
				count = 10;
			};
			class _xx_acm_sam_g_bandana
			{
				name = "acm_sam_g_bandana";
				count = 10;
			};
			class _xx_vn_b_vest_seal_05
			{
				name = "vn_b_vest_seal_05";
				count = 10;
			};
			class _xx_acm_pasgt_nocover
			{
				name = "acm_pasgt_nocover";
				count = 10;
			};
			class _xx_Rangefinder
			{
				name = "Rangefinder";
				count = 10;
			};
			class _xx_acm_pasgt_esscover_back
			{
				name = "acm_pasgt_esscover_back";
				count = 10;
			};
			class _xx_vn_b_pack_trp_04_02
			{
				name = "vn_b_pack_trp_04_02";
				count = 10;
			};
			class _xx_vn_b_pack_lw_05
			{
				name = "vn_b_pack_lw_05";
				count = 10;
			};
			class _xx_acm_pasgt_goggles
			{
				name = "acm_pasgt_goggles";
				count = 10;
			};
			class _xx_acm_bag_sam_grenadier
			{
				name = "acm_bag_sam_grenadier";
				count = 10;
			};
			class _xx_acm_sam_m_vest3
			{
				name = "acm_sam_m_vest3";
				count = 10;
			};
			class _xx_vn_b_pack_lw_02_m60_pl
			{
				name = "vn_b_pack_lw_02_m60_pl";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_13
			{
				name = "vn_b_vest_usarmy_13";
				count = 10;
			};
			class _xx_vn_b_helmet_t56_02_01
			{
				name = "vn_b_helmet_t56_02_01";
				count = 10;
			};
			class _xx_acm_bag_sam_medic
			{
				name = "acm_bag_sam_medic";
				count = 10;
			};
			class _xx_vn_b_pack_lw_06
			{
				name = "vn_b_pack_lw_06";
				count = 10;
			};
			class _xx_H_HeadSet_black_F
			{
				name = "H_HeadSet_black_F";
				count = 10;
			};
			class _xx_acm_bag_sam_2035_AT
			{
				name = "acm_bag_sam_2035_AT";
				count = 10;
			};
			class _xx_acm_bag_sam_demo
			{
				name = "acm_bag_sam_demo";
				count = 10;
			};
			class _xx_acm_sam_headwear_beret_anselm
			{
				name = "acm_sam_headwear_beret_anselm";
				count = 10;
			};
			class _xx_G_Goggles_VR
			{
				name = "G_Goggles_VR";
				count = 10;
			};
			class _xx_B_UAV_01_backpack_F
			{
				name = "B_UAV_01_backpack_F";
				count = 10;
			};
			class _xx_B_UGV_02_Demining_backpack_F
			{
				name = "B_UGV_02_Demining_backpack_F";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_14
			{
				name = "vn_b_vest_usarmy_14";
				count = 10;
			};
			class _xx_Binocular
			{
				name = "Binocular";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_09
			{
				name = "vn_b_vest_usarmy_09";
				count = 10;
			};
			class _xx_vn_b_item_compass
			{
				name = "vn_b_item_compass";
				count = 10;
			};
			class _xx_vn_b_item_watch
			{
				name = "vn_b_item_watch";
				count = 10;
			};
			class _xx_vn_b_item_radio_urc10
			{
				name = "vn_b_item_radio_urc10";
				count = 10;
			};
			class _xx_V_CarrierRigKBT_01_light_Olive_F
			{
				name = "V_CarrierRigKBT_01_light_Olive_F";
				count = 10;
			};
			class _xx_acm_fast_anselm_base
			{
				name = "acm_fast_anselm_base";
				count = 10;
			};
			class _xx_NVGoggles
			{
				name = "NVGoggles";
				count = 10;
			};
			class _xx_acm_fast_anselm_accessory
			{
				name = "acm_fast_anselm_accessory";
				count = 10;
			};
			class _xx_acm_fast_anselm_chops
			{
				name = "acm_fast_anselm_chops";
				count = 10;
			};
			class _xx_acm_bag_sam_2035_MG
			{
				name = "acm_bag_sam_2035_MG";
				count = 10;
			};
			class _xx_V_CarrierRigKBT_01_Olive_F
			{
				name = "V_CarrierRigKBT_01_Olive_F";
				count = 10;
			};
			class _xx_ACM_Helmet_Mk5_Cover_multi
			{
				name = "ACM_Helmet_Mk5_Cover_multi";
				count = 10;
			};
			class _xx_ACM_vn_backpack_seal_01
			{
				name = "ACM_vn_backpack_seal_01";
				count = 10;
			};
			class _xx_ACM_Helmet_Mk5_Cover_Net_Multi
			{
				name = "ACM_Helmet_Mk5_Cover_Net_Multi";
				count = 10;
			};
			class _xx_acm_bag_sam_cr_ruger
			{
				name = "acm_bag_sam_cr_ruger";
				count = 10;
			};
			class _xx_ACM_Helmet_Mk5_Nostrap
			{
				name = "ACM_Helmet_Mk5_Nostrap";
				count = 10;
			};
			class _xx_acm_bag_sam_cr_garand
			{
				name = "acm_bag_sam_cr_garand";
				count = 10;
			};
			class _xx_ACM_Misc_Clothband_Blue
			{
				name = "ACM_Misc_Clothband_Blue";
				count = 10;
			};
			class _xx_acm_bag_sam_cr_FN49
			{
				name = "acm_bag_sam_cr_FN49";
				count = 10;
			};
			class _xx_acm_bag_sam_cr_AK
			{
				name = "acm_bag_sam_cr_AK";
				count = 10;
			};
			class _xx_vn_mk21_binocs
			{
				name = "vn_mk21_binocs";
				count = 10;
			};
			class _xx_acm_bag_sam_cr_AR
			{
				name = "acm_bag_sam_cr_AR";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_03
			{
				name = "vn_b_vest_usarmy_03";
				count = 10;
			};
			class _xx_acm_sam_headwear_boonie_Fold_m
			{
				name = "acm_sam_headwear_boonie_Fold_m";
				count = 10;
			};
			class _xx_acm_bag_sam_hmg
			{
				name = "acm_bag_sam_hmg";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_02
			{
				name = "vn_b_vest_usarmy_02";
				count = 10;
			};
			class _xx_acm_sam_headwear_boonie
			{
				name = "acm_sam_headwear_boonie";
				count = 10;
			};
			class _xx_V_TacVest_oli
			{
				name = "V_TacVest_oli";
				count = 10;
			};
			class _xx_ACM_Helmet_Mk5_Scrim2
			{
				name = "ACM_Helmet_Mk5_Scrim2";
				count = 10;
			};
			class _xx_acm_sam_clothes_m_1_1
			{
				name = "acm_sam_clothes_m_1_1";
				count = 10;
			};
			class _xx_acm_sam_clothes_m_1_2
			{
				name = "acm_sam_clothes_m_1_2";
				count = 10;
			};
			class _xx_acm_sam_clothes_m_1_4
			{
				name = "acm_sam_clothes_m_1_4";
				count = 10;
			};
			class _xx_acm_sam_clothes_m_1_3
			{
				name = "acm_sam_clothes_m_1_3";
				count = 10;
			};
			class _xx_acm_sam_clothes01_3
			{
				name = "acm_sam_clothes01_3";
				count = 10;
			};
		};
	};
	class ACM_B_SAC_AmmoBox: Box_NATO_Ammo_F
	{
		author = "ALiVE ORBAT CREATOR";
		scope = 2;
		displayName = "Saint Anselm Constabulary Ammo Box";
		class TransportMagazines
		{
			class _xx_sp_fwa_10Rnd_762_L42
			{
				magazine = "sp_fwa_10Rnd_762_L42";
				count = 50;
			};
			class _xx_vn_m61_grenade_mag
			{
				magazine = "vn_m61_grenade_mag";
				count = 50;
			};
			class _xx_sp_fwa_20Rnd_762_FAL_Metric_Tracer
			{
				magazine = "sp_fwa_20Rnd_762_FAL_Metric_Tracer";
				count = 50;
			};
			class _xx_vn_hp_mag
			{
				magazine = "vn_hp_mag";
				count = 50;
			};
			class _xx_vn_m127_mag
			{
				magazine = "vn_m127_mag";
				count = 50;
			};
			class _xx_sp_fwa_30Rnd_Straight_762_FAL_Metric_Tracer
			{
				magazine = "sp_fwa_30Rnd_Straight_762_FAL_Metric_Tracer";
				count = 50;
			};
			class _xx_sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer
			{
				magazine = "sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer";
				count = 50;
			};
			class _xx_sp_fwa_20Rnd_762_FAL_Metric
			{
				magazine = "sp_fwa_20Rnd_762_FAL_Metric";
				count = 50;
			};
			class _xx_sp_fwa_30Rnd_Curved_762_FAL_Metric
			{
				magazine = "sp_fwa_30Rnd_Curved_762_FAL_Metric";
				count = 50;
			};
			class _xx_vn_m1897_buck_mag
			{
				magazine = "vn_m1897_buck_mag";
				count = 50;
			};
			class _xx_vn_m1897_fl_mag
			{
				magazine = "vn_m1897_fl_mag";
				count = 50;
			};
			class _xx_vn_mine_m112_remote_mag
			{
				magazine = "vn_mine_m112_remote_mag";
				count = 50;
			};
			class _xx_vn_mine_tripwire_m49_02_mag
			{
				magazine = "vn_mine_tripwire_m49_02_mag";
				count = 50;
			};
			class _xx_vn_mine_m18_x3_range_mag
			{
				magazine = "vn_mine_m18_x3_range_mag";
				count = 50;
			};
			class _xx_vn_mine_satchel_remote_02_mag
			{
				magazine = "vn_mine_satchel_remote_02_mag";
				count = 50;
			};
			class _xx_vn_mine_tm57_mag
			{
				magazine = "vn_mine_tm57_mag";
				count = 50;
			};
			class _xx_sp_fwa_1rnd_riflegrenade_mas_ap
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_ap";
				count = 50;
			};
			class _xx_sp_fwa_1rnd_riflegrenade_mas_wp
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_wp";
				count = 50;
			};
			class _xx_sp_fwa_1rnd_riflegrenade_mas_at_l
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_at_l";
				count = 50;
			};
			class _xx_sp_fwa_32Rnd_9x19_L2A3_Sterling
			{
				magazine = "sp_fwa_32Rnd_9x19_L2A3_Sterling";
				count = 50;
			};
			class _xx_vn_40mm_m651_cs_mag
			{
				magazine = "vn_40mm_m651_cs_mag";
				count = 50;
			};
			class _xx_vn_40mm_m682_smoke_r_mag
			{
				magazine = "vn_40mm_m682_smoke_r_mag";
				count = 50;
			};
			class _xx_vn_40mm_m583_flare_w_mag
			{
				magazine = "vn_40mm_m583_flare_w_mag";
				count = 50;
			};
			class _xx_vn_f1_grenade_mag
			{
				magazine = "vn_f1_grenade_mag";
				count = 50;
			};
			class _xx_vn_mine_m18_mag
			{
				magazine = "vn_mine_m18_mag";
				count = 50;
			};
			class _xx_sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer
			{
				magazine = "sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer";
				count = 50;
			};
		};
		class TransportWeapons{};
		class TransportItems{};
	};
	class ACM_B_SAC_WeaponsBox: Box_NATO_Wps_F
	{
		author = "ALiVE ORBAT CREATOR";
		scope = 2;
		displayName = "Saint Anselm Constabulary Weapons Box";
		class TransportMagazines
		{
			class _xx_sp_fwa_10Rnd_762_L42
			{
				magazine = "sp_fwa_10Rnd_762_L42";
				count = 50;
			};
			class _xx_sp_fwa_20Rnd_762_FAL_Metric_Tracer
			{
				magazine = "sp_fwa_20Rnd_762_FAL_Metric_Tracer";
				count = 50;
			};
			class _xx_vn_hp_mag
			{
				magazine = "vn_hp_mag";
				count = 50;
			};
			class _xx_sp_fwa_30Rnd_Straight_762_FAL_Metric_Tracer
			{
				magazine = "sp_fwa_30Rnd_Straight_762_FAL_Metric_Tracer";
				count = 50;
			};
			class _xx_sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer
			{
				magazine = "sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer";
				count = 50;
			};
			class _xx_sp_fwa_20Rnd_762_FAL_Metric
			{
				magazine = "sp_fwa_20Rnd_762_FAL_Metric";
				count = 50;
			};
			class _xx_sp_fwa_30Rnd_Curved_762_FAL_Metric
			{
				magazine = "sp_fwa_30Rnd_Curved_762_FAL_Metric";
				count = 50;
			};
			class _xx_vn_m1897_fl_mag
			{
				magazine = "vn_m1897_fl_mag";
				count = 50;
			};
			class _xx_sp_fwa_1rnd_riflegrenade_mas_at_l
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_at_l";
				count = 50;
			};
			class _xx_sp_fwa_32Rnd_9x19_L2A3_Sterling
			{
				magazine = "sp_fwa_32Rnd_9x19_L2A3_Sterling";
				count = 50;
			};
			class _xx_vn_40mm_m583_flare_w_mag
			{
				magazine = "vn_40mm_m583_flare_w_mag";
				count = 50;
			};
			class _xx_sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer
			{
				magazine = "sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer";
				count = 50;
			};
		};
		class TransportWeapons
		{
			class _xx_sp_fwa_enfield_l8_walnut
			{
				weapon = "sp_fwa_enfield_l8_walnut";
				count = 10;
			};
			class _xx_sp_fwa_fal_l1a1_wood
			{
				weapon = "sp_fwa_fal_l1a1_wood";
				count = 10;
			};
			class _xx_vn_hp
			{
				weapon = "vn_hp";
				count = 10;
			};
			class _xx_sp_fwa_falo_factory_50_42_bipod
			{
				weapon = "sp_fwa_falo_factory_50_42_bipod";
				count = 10;
			};
			class _xx_sp_fwa_smg_sterling
			{
				weapon = "sp_fwa_smg_sterling";
				count = 10;
			};
			class _xx_acm_fwa_l8t_marksman
			{
				weapon = "acm_fwa_l8t_marksman";
				count = 10;
			};
			class _xx_sp_fwa_bren_l4_lmg
			{
				weapon = "sp_fwa_bren_l4_lmg";
				count = 10;
			};
			class _xx_vn_m1897
			{
				weapon = "vn_m1897";
				count = 10;
			};
			class _xx_sp_fwa_smg_mk6sterling
			{
				weapon = "sp_fwa_smg_mk6sterling";
				count = 10;
			};
			class _xx_vn_m79
			{
				weapon = "vn_m79";
				count = 10;
			};
			class _xx_sp_fwa_smg_mk5sterling
			{
				weapon = "sp_fwa_smg_mk5sterling";
				count = 10;
			};
			class _xx_acm_fwa_l1a1_IR
			{
				weapon = "acm_fwa_l1a1_IR";
				count = 10;
			};
			class _xx_sp_fwa_fal_l1a1_laminate
			{
				weapon = "sp_fwa_fal_l1a1_laminate";
				count = 10;
			};
		};
		class TransportItems
		{
			class _xx_sp_fwa_bipod_falo
			{
				name = "sp_fwa_bipod_falo";
				count = 10;
			};
			class _xx_sp_fwa_no32_vintage
			{
				name = "sp_fwa_no32_vintage";
				count = 10;
			};
			class _xx_sp_fwa_scope_eltro_b8v_ir_scope
			{
				name = "sp_fwa_scope_eltro_b8v_ir_scope";
				count = 10;
			};
		};
	};
	class ACM_B_SAC_LaunchersBox: Box_NATO_WpsLaunch_F
	{
		author = "ALiVE ORBAT CREATOR";
		scope = 2;
		displayName = "Saint Anselm Constabulary Launchers Box";
		class TransportMagazines
		{
			class _xx_vn_m72_mag
			{
				magazine = "vn_m72_mag";
				count = 5;
			};
			class _xx_vn_m127_mag
			{
				magazine = "vn_m127_mag";
				count = 5;
			};
		};
		class TransportWeapons
		{
			class _xx_vn_m72
			{
				weapon = "vn_m72";
				count = 5;
			};
			class _xx_vn_m127
			{
				weapon = "vn_m127";
				count = 5;
			};
		};
		class TransportItems{};
	};
	class ACM_B_SAC_UniformBox: Box_NATO_Uniforms_F
	{
		author = "ALiVE ORBAT CREATOR";
		scope = 2;
		displayName = "Saint Anselm Constabulary Uniform Box";
		class TransportWeapons{};
		class TransportMagazines{};
		class TransportItems
		{
			class _xx_acm_sam_clothes01_1
			{
				name = "acm_sam_clothes01_1";
				count = 15;
			};
			class _xx_acm_sam_clothes01_2
			{
				name = "acm_sam_clothes01_2";
				count = 15;
			};
			class _xx_acm_sam_clothes01_4
			{
				name = "acm_sam_clothes01_4";
				count = 15;
			};
			class _xx_acm_sam_clothes01_3
			{
				name = "acm_sam_clothes01_3";
				count = 15;
			};
			class _xx_acm_sam_clothes01_5
			{
				name = "acm_sam_clothes01_5";
				count = 15;
			};
			class _xx_acm_sam_clothes01_1_Police
			{
				name = "acm_sam_clothes01_1_Police";
				count = 15;
			};
			class _xx_acm_sam_clothes01_3_Police
			{
				name = "acm_sam_clothes01_3_Police";
				count = 15;
			};
			class _xx_acm_sam_clothes01_2_Police
			{
				name = "acm_sam_clothes01_2_Police";
				count = 15;
			};
		};
	};
	class ACM_B_SAC_SupportBox: Box_NATO_Support_F
	{
		author = "ALiVE ORBAT CREATOR";
		scope = 2;
		displayName = "Saint Anselm Constabulary Support Box";
		class TransportWeapons{};
		class TransportMagazines{};
		class TransportItems
		{
			class _xx_vn_b_vest_usarmy_02
			{
				name = "vn_b_vest_usarmy_02";
				count = 10;
			};
			class _xx_ACM_Helmet_Mk5_Nostrap
			{
				name = "ACM_Helmet_Mk5_Nostrap";
				count = 10;
			};
			class _xx_vn_b_pack_lw_01
			{
				name = "vn_b_pack_lw_01";
				count = 10;
			};
			class _xx_ItemMap
			{
				name = "ItemMap";
				count = 10;
			};
			class _xx_vn_b_item_compass
			{
				name = "vn_b_item_compass";
				count = 10;
			};
			class _xx_vn_b_item_watch
			{
				name = "vn_b_item_watch";
				count = 10;
			};
			class _xx_vn_b_item_radio_urc10
			{
				name = "vn_b_item_radio_urc10";
				count = 10;
			};
			class _xx_ACM_Helmet_Mk5_Cover
			{
				name = "ACM_Helmet_Mk5_Cover";
				count = 10;
			};
			class _xx_ACM_Helmet_Mk5_Scrim2
			{
				name = "ACM_Helmet_Mk5_Scrim2";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_03
			{
				name = "vn_b_vest_usarmy_03";
				count = 10;
			};
			class _xx_ACM_Helmet_Mk5_Net
			{
				name = "ACM_Helmet_Mk5_Net";
				count = 10;
			};
			class _xx_vn_anpvs2_binoc
			{
				name = "vn_anpvs2_binoc";
				count = 10;
			};
			class _xx_ACM_Helmet_Mk5_Scrim
			{
				name = "ACM_Helmet_Mk5_Scrim";
				count = 10;
			};
			class _xx_vn_b_pack_lw_06
			{
				name = "vn_b_pack_lw_06";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_06
			{
				name = "vn_b_vest_usarmy_06";
				count = 10;
			};
			class _xx_acm_bag_sam_MG
			{
				name = "acm_bag_sam_MG";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_09
			{
				name = "vn_b_vest_usarmy_09";
				count = 10;
			};
			class _xx_vn_b_pack_prc77_01
			{
				name = "vn_b_pack_prc77_01";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_08
			{
				name = "vn_b_vest_usarmy_08";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_07
			{
				name = "vn_b_vest_usarmy_07";
				count = 10;
			};
			class _xx_acm_bag_sam_medic
			{
				name = "acm_bag_sam_medic";
				count = 10;
			};
			class _xx_acm_bag_sam_hmg
			{
				name = "acm_bag_sam_hmg";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_04
			{
				name = "vn_b_vest_usarmy_04";
				count = 10;
			};
			class _xx_ACM_Helmet_Mk5_Cover_Net
			{
				name = "ACM_Helmet_Mk5_Cover_Net";
				count = 10;
			};
			class _xx_vn_b_vest_sog_03
			{
				name = "vn_b_vest_sog_03";
				count = 10;
			};
			class _xx_acm_bag_sam_demo
			{
				name = "acm_bag_sam_demo";
				count = 10;
			};
			class _xx_vn_b_vest_seal_04
			{
				name = "vn_b_vest_seal_04";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_14
			{
				name = "vn_b_vest_usarmy_14";
				count = 10;
			};
			class _xx_acm_bag_sam_grenadier
			{
				name = "acm_bag_sam_grenadier";
				count = 10;
			};
			class _xx_vn_m19_binocs_grey
			{
				name = "vn_m19_binocs_grey";
				count = 10;
			};
			class _xx_acm_sam_headwear_beret_anselm
			{
				name = "acm_sam_headwear_beret_anselm";
				count = 10;
			};
			class _xx_vn_b_vest_aircrew_04
			{
				name = "vn_b_vest_aircrew_04";
				count = 10;
			};
			class _xx_vn_b_helmet_aph6_01_05
			{
				name = "vn_b_helmet_aph6_01_05";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_13
			{
				name = "vn_b_vest_usarmy_13";
				count = 10;
			};
			class _xx_vn_b_helmet_t56_02_01
			{
				name = "vn_b_helmet_t56_02_01";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_01
			{
				name = "vn_b_vest_usarmy_01";
				count = 10;
			};
			class _xx_ACM_Helmet_Mk5_VisorUp
			{
				name = "ACM_Helmet_Mk5_VisorUp";
				count = 10;
			};
			class _xx_ACM_Helmet_Mk5_Visor
			{
				name = "ACM_Helmet_Mk5_Visor";
				count = 10;
			};
			class _xx_vn_b_acc_m17_01
			{
				name = "vn_b_acc_m17_01";
				count = 10;
			};
			class _xx_vn_b_vest_sog_04
			{
				name = "vn_b_vest_sog_04";
				count = 10;
			};
			class _xx_acm_sam_headwear_boonie
			{
				name = "acm_sam_headwear_boonie";
				count = 10;
			};
			class _xx_vn_b_scarf_01_01
			{
				name = "vn_b_scarf_01_01";
				count = 10;
			};
			class _xx_vn_b_vest_sog_01
			{
				name = "vn_b_vest_sog_01";
				count = 10;
			};
			class _xx_acm_sam_headwear_boonie_Fold
			{
				name = "acm_sam_headwear_boonie_Fold";
				count = 10;
			};
			class _xx_vn_b_vest_sog_02
			{
				name = "vn_b_vest_sog_02";
				count = 10;
			};
			class _xx_vn_b_vest_sog_05
			{
				name = "vn_b_vest_sog_05";
				count = 10;
			};
			class _xx_vn_b_pack_lw_05
			{
				name = "vn_b_pack_lw_05";
				count = 10;
			};
		};
	};
	class ACM_B_SAC_SupplyBox: B_SupplyCrate_F
	{
		author = "ALiVE ORBAT CREATOR";
		scope = 2;
		displayName = "Saint Anselm Constabulary Supply Box";
		class TransportMagazines
		{
			class _xx_sp_fwa_10Rnd_762_L42
			{
				magazine = "sp_fwa_10Rnd_762_L42";
				count = 50;
			};
			class _xx_vn_m61_grenade_mag
			{
				magazine = "vn_m61_grenade_mag";
				count = 50;
			};
			class _xx_sp_fwa_20Rnd_762_FAL_Metric_Tracer
			{
				magazine = "sp_fwa_20Rnd_762_FAL_Metric_Tracer";
				count = 50;
			};
			class _xx_vn_hp_mag
			{
				magazine = "vn_hp_mag";
				count = 50;
			};
			class _xx_vn_m127_mag
			{
				magazine = "vn_m127_mag";
				count = 50;
			};
			class _xx_sp_fwa_30Rnd_Straight_762_FAL_Metric_Tracer
			{
				magazine = "sp_fwa_30Rnd_Straight_762_FAL_Metric_Tracer";
				count = 50;
			};
			class _xx_sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer
			{
				magazine = "sp_fwa_32Rnd_9x19_L2A3_Sterling_Tracer";
				count = 50;
			};
			class _xx_sp_fwa_20Rnd_762_FAL_Metric
			{
				magazine = "sp_fwa_20Rnd_762_FAL_Metric";
				count = 50;
			};
			class _xx_sp_fwa_30Rnd_Curved_762_FAL_Metric
			{
				magazine = "sp_fwa_30Rnd_Curved_762_FAL_Metric";
				count = 50;
			};
			class _xx_vn_m1897_buck_mag
			{
				magazine = "vn_m1897_buck_mag";
				count = 50;
			};
			class _xx_vn_m1897_fl_mag
			{
				magazine = "vn_m1897_fl_mag";
				count = 50;
			};
			class _xx_vn_mine_m112_remote_mag
			{
				magazine = "vn_mine_m112_remote_mag";
				count = 50;
			};
			class _xx_vn_mine_tripwire_m49_02_mag
			{
				magazine = "vn_mine_tripwire_m49_02_mag";
				count = 50;
			};
			class _xx_vn_mine_m18_x3_range_mag
			{
				magazine = "vn_mine_m18_x3_range_mag";
				count = 50;
			};
			class _xx_vn_mine_satchel_remote_02_mag
			{
				magazine = "vn_mine_satchel_remote_02_mag";
				count = 50;
			};
			class _xx_vn_mine_tm57_mag
			{
				magazine = "vn_mine_tm57_mag";
				count = 50;
			};
			class _xx_sp_fwa_1rnd_riflegrenade_mas_ap
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_ap";
				count = 50;
			};
			class _xx_sp_fwa_1rnd_riflegrenade_mas_wp
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_wp";
				count = 50;
			};
			class _xx_sp_fwa_1rnd_riflegrenade_mas_at_l
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_at_l";
				count = 50;
			};
			class _xx_sp_fwa_32Rnd_9x19_L2A3_Sterling
			{
				magazine = "sp_fwa_32Rnd_9x19_L2A3_Sterling";
				count = 50;
			};
			class _xx_vn_40mm_m651_cs_mag
			{
				magazine = "vn_40mm_m651_cs_mag";
				count = 50;
			};
			class _xx_vn_40mm_m682_smoke_r_mag
			{
				magazine = "vn_40mm_m682_smoke_r_mag";
				count = 50;
			};
			class _xx_vn_40mm_m583_flare_w_mag
			{
				magazine = "vn_40mm_m583_flare_w_mag";
				count = 50;
			};
			class _xx_vn_f1_grenade_mag
			{
				magazine = "vn_f1_grenade_mag";
				count = 50;
			};
			class _xx_vn_mine_m18_mag
			{
				magazine = "vn_mine_m18_mag";
				count = 50;
			};
			class _xx_sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer
			{
				magazine = "sp_fwa_30Rnd_Curved_762_FAL_Metric_Tracer";
				count = 50;
			};
		};
		class TransportWeapons
		{
			class _xx_sp_fwa_enfield_l8_walnut
			{
				weapon = "sp_fwa_enfield_l8_walnut";
				count = 10;
			};
			class _xx_sp_fwa_fal_l1a1_wood
			{
				weapon = "sp_fwa_fal_l1a1_wood";
				count = 10;
			};
			class _xx_vn_hp
			{
				weapon = "vn_hp";
				count = 10;
			};
			class _xx_sp_fwa_falo_factory_50_42_bipod
			{
				weapon = "sp_fwa_falo_factory_50_42_bipod";
				count = 10;
			};
			class _xx_sp_fwa_smg_sterling
			{
				weapon = "sp_fwa_smg_sterling";
				count = 10;
			};
			class _xx_acm_fwa_l8t_marksman
			{
				weapon = "acm_fwa_l8t_marksman";
				count = 10;
			};
			class _xx_sp_fwa_bren_l4_lmg
			{
				weapon = "sp_fwa_bren_l4_lmg";
				count = 10;
			};
			class _xx_vn_m1897
			{
				weapon = "vn_m1897";
				count = 10;
			};
			class _xx_sp_fwa_smg_mk6sterling
			{
				weapon = "sp_fwa_smg_mk6sterling";
				count = 10;
			};
			class _xx_vn_m79
			{
				weapon = "vn_m79";
				count = 10;
			};
			class _xx_sp_fwa_smg_mk5sterling
			{
				weapon = "sp_fwa_smg_mk5sterling";
				count = 10;
			};
			class _xx_acm_fwa_l1a1_IR
			{
				weapon = "acm_fwa_l1a1_IR";
				count = 10;
			};
			class _xx_sp_fwa_fal_l1a1_laminate
			{
				weapon = "sp_fwa_fal_l1a1_laminate";
				count = 10;
			};
			class _xx_vn_m72
			{
				weapon = "vn_m72";
				count = 10;
			};
			class _xx_vn_m127
			{
				weapon = "vn_m127";
				count = 10;
			};
		};
		class TransportItems
		{
			class _xx_sp_fwa_bipod_falo
			{
				name = "sp_fwa_bipod_falo";
				count = 10;
			};
			class _xx_sp_fwa_no32_vintage
			{
				name = "sp_fwa_no32_vintage";
				count = 10;
			};
			class _xx_sp_fwa_scope_eltro_b8v_ir_scope
			{
				name = "sp_fwa_scope_eltro_b8v_ir_scope";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_02
			{
				name = "vn_b_vest_usarmy_02";
				count = 10;
			};
			class _xx_ACM_Helmet_Mk5_Nostrap
			{
				name = "ACM_Helmet_Mk5_Nostrap";
				count = 10;
			};
			class _xx_vn_b_pack_lw_01
			{
				name = "vn_b_pack_lw_01";
				count = 10;
			};
			class _xx_ItemMap
			{
				name = "ItemMap";
				count = 10;
			};
			class _xx_vn_b_item_compass
			{
				name = "vn_b_item_compass";
				count = 10;
			};
			class _xx_vn_b_item_watch
			{
				name = "vn_b_item_watch";
				count = 10;
			};
			class _xx_vn_b_item_radio_urc10
			{
				name = "vn_b_item_radio_urc10";
				count = 10;
			};
			class _xx_ACM_Helmet_Mk5_Cover
			{
				name = "ACM_Helmet_Mk5_Cover";
				count = 10;
			};
			class _xx_ACM_Helmet_Mk5_Scrim2
			{
				name = "ACM_Helmet_Mk5_Scrim2";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_03
			{
				name = "vn_b_vest_usarmy_03";
				count = 10;
			};
			class _xx_ACM_Helmet_Mk5_Net
			{
				name = "ACM_Helmet_Mk5_Net";
				count = 10;
			};
			class _xx_vn_anpvs2_binoc
			{
				name = "vn_anpvs2_binoc";
				count = 10;
			};
			class _xx_ACM_Helmet_Mk5_Scrim
			{
				name = "ACM_Helmet_Mk5_Scrim";
				count = 10;
			};
			class _xx_vn_b_pack_lw_06
			{
				name = "vn_b_pack_lw_06";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_06
			{
				name = "vn_b_vest_usarmy_06";
				count = 10;
			};
			class _xx_acm_bag_sam_MG
			{
				name = "acm_bag_sam_MG";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_09
			{
				name = "vn_b_vest_usarmy_09";
				count = 10;
			};
			class _xx_vn_b_pack_prc77_01
			{
				name = "vn_b_pack_prc77_01";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_08
			{
				name = "vn_b_vest_usarmy_08";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_07
			{
				name = "vn_b_vest_usarmy_07";
				count = 10;
			};
			class _xx_acm_bag_sam_medic
			{
				name = "acm_bag_sam_medic";
				count = 10;
			};
			class _xx_acm_bag_sam_hmg
			{
				name = "acm_bag_sam_hmg";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_04
			{
				name = "vn_b_vest_usarmy_04";
				count = 10;
			};
			class _xx_ACM_Helmet_Mk5_Cover_Net
			{
				name = "ACM_Helmet_Mk5_Cover_Net";
				count = 10;
			};
			class _xx_vn_b_vest_sog_03
			{
				name = "vn_b_vest_sog_03";
				count = 10;
			};
			class _xx_acm_bag_sam_demo
			{
				name = "acm_bag_sam_demo";
				count = 10;
			};
			class _xx_vn_b_vest_seal_04
			{
				name = "vn_b_vest_seal_04";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_14
			{
				name = "vn_b_vest_usarmy_14";
				count = 10;
			};
			class _xx_acm_bag_sam_grenadier
			{
				name = "acm_bag_sam_grenadier";
				count = 10;
			};
			class _xx_vn_m19_binocs_grey
			{
				name = "vn_m19_binocs_grey";
				count = 10;
			};
			class _xx_acm_sam_headwear_beret_anselm
			{
				name = "acm_sam_headwear_beret_anselm";
				count = 10;
			};
			class _xx_vn_b_vest_aircrew_04
			{
				name = "vn_b_vest_aircrew_04";
				count = 10;
			};
			class _xx_vn_b_helmet_aph6_01_05
			{
				name = "vn_b_helmet_aph6_01_05";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_13
			{
				name = "vn_b_vest_usarmy_13";
				count = 10;
			};
			class _xx_vn_b_helmet_t56_02_01
			{
				name = "vn_b_helmet_t56_02_01";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_01
			{
				name = "vn_b_vest_usarmy_01";
				count = 10;
			};
			class _xx_ACM_Helmet_Mk5_VisorUp
			{
				name = "ACM_Helmet_Mk5_VisorUp";
				count = 10;
			};
			class _xx_ACM_Helmet_Mk5_Visor
			{
				name = "ACM_Helmet_Mk5_Visor";
				count = 10;
			};
			class _xx_vn_b_acc_m17_01
			{
				name = "vn_b_acc_m17_01";
				count = 10;
			};
			class _xx_vn_b_vest_sog_04
			{
				name = "vn_b_vest_sog_04";
				count = 10;
			};
			class _xx_acm_sam_headwear_boonie
			{
				name = "acm_sam_headwear_boonie";
				count = 10;
			};
			class _xx_vn_b_scarf_01_01
			{
				name = "vn_b_scarf_01_01";
				count = 10;
			};
			class _xx_vn_b_vest_sog_01
			{
				name = "vn_b_vest_sog_01";
				count = 10;
			};
			class _xx_acm_sam_headwear_boonie_Fold
			{
				name = "acm_sam_headwear_boonie_Fold";
				count = 10;
			};
			class _xx_vn_b_vest_sog_02
			{
				name = "vn_b_vest_sog_02";
				count = 10;
			};
			class _xx_vn_b_vest_sog_05
			{
				name = "vn_b_vest_sog_05";
				count = 10;
			};
			class _xx_vn_b_pack_lw_05
			{
				name = "vn_b_pack_lw_05";
				count = 10;
			};
			class _xx_acm_sam_clothes01_1
			{
				name = "acm_sam_clothes01_1";
				count = 10;
			};
			class _xx_acm_sam_clothes01_2
			{
				name = "acm_sam_clothes01_2";
				count = 10;
			};
			class _xx_acm_sam_clothes01_4
			{
				name = "acm_sam_clothes01_4";
				count = 10;
			};
			class _xx_acm_sam_clothes01_3
			{
				name = "acm_sam_clothes01_3";
				count = 10;
			};
			class _xx_acm_sam_clothes01_5
			{
				name = "acm_sam_clothes01_5";
				count = 10;
			};
			class _xx_acm_sam_clothes01_1_Police
			{
				name = "acm_sam_clothes01_1_Police";
				count = 10;
			};
			class _xx_acm_sam_clothes01_3_Police
			{
				name = "acm_sam_clothes01_3_Police";
				count = 10;
			};
			class _xx_acm_sam_clothes01_2_Police
			{
				name = "acm_sam_clothes01_2_Police";
				count = 10;
			};
		};
	};
	class Box_East_Ammo_F;
	class Box_East_Wps_F;
	class Box_East_WpsLaunch_F;
	class Box_CSAT_Equip_F;
	class Box_East_Support_F;
	class O_SupplyCrate_F;
	class ACM_O_ATIU_2035_AmmoBox: Box_East_Ammo_F
	{
		author = "ALiVE ORBAT CREATOR";
		scope = 2;
		displayName = "Alcillian Territorial Integrity Units (2035) Ammo Box";
		class TransportMagazines
		{
			class _xx_sp_fwa_20Rnd_556_Ar18_Tracer
			{
				magazine = "sp_fwa_20Rnd_556_Ar18_Tracer";
				count = 50;
			};
			class _xx_vn_m61_grenade_mag
			{
				magazine = "vn_m61_grenade_mag";
				count = 50;
			};
			class _xx_vn_m18_white_mag
			{
				magazine = "vn_m18_white_mag";
				count = 50;
			};
			class _xx_sp_fwa_30Rnd_556_Armalite
			{
				magazine = "sp_fwa_30Rnd_556_Armalite";
				count = 50;
			};
			class _xx_sp_fwa_20rnd_762_bm59
			{
				magazine = "sp_fwa_20rnd_762_bm59";
				count = 50;
			};
			class _xx_sp_fwa_1rnd_riflegrenade_mas_ap
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_ap";
				count = 50;
			};
			class _xx_sp_fwa_1rnd_riflegrenade_mas_at_l
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_at_l";
				count = 50;
			};
			class _xx_sp_fwa_1rnd_riflegrenade_mas_wp
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_wp";
				count = 50;
			};
			class _xx_vn_m127_mag
			{
				magazine = "vn_m127_mag";
				count = 50;
			};
			class _xx_sp_fwa_20Rnd_556_Armalite_Tracer
			{
				magazine = "sp_fwa_20Rnd_556_Armalite_Tracer";
				count = 50;
			};
			class _xx_1Rnd_HE_Grenade_shell
			{
				magazine = "1Rnd_HE_Grenade_shell";
				count = 50;
			};
			class _xx_UGL_FlareWhite_F
			{
				magazine = "UGL_FlareWhite_F";
				count = 50;
			};
			class _xx_1Rnd_Smoke_Grenade_shell
			{
				magazine = "1Rnd_Smoke_Grenade_shell";
				count = 50;
			};
			class _xx_sp_fwa_1rnd_riflegrenade_m9a1_at
			{
				magazine = "sp_fwa_1rnd_riflegrenade_m9a1_at";
				count = 50;
			};
			class _xx_vn_rpg7_mag
			{
				magazine = "vn_rpg7_mag";
				count = 50;
			};
			class _xx_sp_fwa_100Rnd_762_mag
			{
				magazine = "sp_fwa_100Rnd_762_mag";
				count = 50;
			};
			class _xx_vn_mine_m112_remote_mag
			{
				magazine = "vn_mine_m112_remote_mag";
				count = 50;
			};
			class _xx_vn_mine_tripwire_m49_02_mag
			{
				magazine = "vn_mine_tripwire_m49_02_mag";
				count = 50;
			};
			class _xx_vn_mine_m18_x3_range_mag
			{
				magazine = "vn_mine_m18_x3_range_mag";
				count = 50;
			};
			class _xx_vn_mine_satchel_remote_02_mag
			{
				magazine = "vn_mine_satchel_remote_02_mag";
				count = 50;
			};
			class _xx_vn_mine_tm57_mag
			{
				magazine = "vn_mine_tm57_mag";
				count = 50;
			};
			class _xx_vn_m1911_mag
			{
				magazine = "vn_m1911_mag";
				count = 50;
			};
			class _xx_30Rnd_65x39_caseless_green
			{
				magazine = "30Rnd_65x39_caseless_green";
				count = 50;
			};
			class _xx_vn_mk22_mag
			{
				magazine = "vn_mk22_mag";
				count = 50;
			};
			class _xx_1Rnd_SmokeRed_Grenade_shell
			{
				magazine = "1Rnd_SmokeRed_Grenade_shell";
				count = 50;
			};
			class _xx_10Rnd_93x64_DMR_05_Mag
			{
				magazine = "10Rnd_93x64_DMR_05_Mag";
				count = 50;
			};
			class _xx_200Rnd_556x45_Box_F
			{
				magazine = "200Rnd_556x45_Box_F";
				count = 50;
			};
		};
		class TransportWeapons{};
		class TransportItems{};
	};
	class ACM_O_ATIU_2035_WeaponsBox: Box_East_Wps_F
	{
		hiddenSelections[] = {"Camo_Signs","Camo"};
		hiddenSelectionsTextures[] = {"\A3\Supplies_F_Exp\Ammoboxes\Data\AmmoBox_signs_OPFOR_CA.paa","\A3\Supplies_F_Exp\Ammoboxes\Data\Box_T_East_Wps_F_co.paa"};
		author = "ALiVE ORBAT CREATOR";
		scope = 2;
		displayName = "Alcillian Territorial Integrity Units (2035) Weapons Box";
		class TransportMagazines
		{
			class _xx_sp_fwa_20Rnd_556_Ar18_Tracer
			{
				magazine = "sp_fwa_20Rnd_556_Ar18_Tracer";
				count = 50;
			};
			class _xx_sp_fwa_30Rnd_556_Armalite
			{
				magazine = "sp_fwa_30Rnd_556_Armalite";
				count = 50;
			};
			class _xx_sp_fwa_20rnd_762_bm59
			{
				magazine = "sp_fwa_20rnd_762_bm59";
				count = 50;
			};
			class _xx_sp_fwa_1rnd_riflegrenade_mas_at_l
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_at_l";
				count = 50;
			};
			class _xx_sp_fwa_20Rnd_556_Armalite_Tracer
			{
				magazine = "sp_fwa_20Rnd_556_Armalite_Tracer";
				count = 50;
			};
			class _xx_1Rnd_HE_Grenade_shell
			{
				magazine = "1Rnd_HE_Grenade_shell";
				count = 50;
			};
			class _xx_sp_fwa_1rnd_riflegrenade_mas_ap
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_ap";
				count = 50;
			};
			class _xx_sp_fwa_100Rnd_762_mag
			{
				magazine = "sp_fwa_100Rnd_762_mag";
				count = 50;
			};
			class _xx_vn_m1911_mag
			{
				magazine = "vn_m1911_mag";
				count = 50;
			};
			class _xx_30Rnd_65x39_caseless_green
			{
				magazine = "30Rnd_65x39_caseless_green";
				count = 50;
			};
			class _xx_vn_mk22_mag
			{
				magazine = "vn_mk22_mag";
				count = 50;
			};
			class _xx_10Rnd_93x64_DMR_05_Mag
			{
				magazine = "10Rnd_93x64_DMR_05_Mag";
				count = 50;
			};
			class _xx_200Rnd_556x45_Box_F
			{
				magazine = "200Rnd_556x45_Box_F";
				count = 50;
			};
		};
		class TransportWeapons
		{
			class _xx_sp_fwa_ar18
			{
				weapon = "sp_fwa_ar18";
				count = 10;
			};
			class _xx_sp_fwa_ar18_carbine
			{
				weapon = "sp_fwa_ar18_carbine";
				count = 10;
			};
			class _xx_sp_fwa_ar15_603_m16a1_a2
			{
				weapon = "sp_fwa_ar15_603_m16a1_a2";
				count = 10;
			};
			class _xx_sp_fwa_bm59_mk3_alpine
			{
				weapon = "sp_fwa_bm59_mk3_alpine";
				count = 10;
			};
			class _xx_acm_alc_m_sp_m16_m203
			{
				weapon = "acm_alc_m_sp_m16_m203";
				count = 10;
			};
			class _xx_acm_alc_m_sp_bm59
			{
				weapon = "acm_alc_m_sp_bm59";
				count = 10;
			};
			class _xx_sp_fwa_mag58
			{
				weapon = "sp_fwa_mag58";
				count = 10;
			};
			class _xx_vn_m1911
			{
				weapon = "vn_m1911";
				count = 10;
			};
			class _xx_acm_alc_m_sf_kat_c
			{
				weapon = "acm_alc_m_sf_kat_c";
				count = 10;
			};
			class _xx_vn_mk22
			{
				weapon = "vn_mk22";
				count = 10;
			};
			class _xx_acm_alc_m_sf_kat_GL
			{
				weapon = "acm_alc_m_sf_kat_GL";
				count = 10;
			};
			class _xx_acm_alc_m_sf_kat_TL
			{
				weapon = "acm_alc_m_sf_kat_TL";
				count = 10;
			};
			class _xx_acm_alc_m_sf_DMR_05
			{
				weapon = "acm_alc_m_sf_DMR_05";
				count = 10;
			};
			class _xx_acm_alc_m_sf_LMG_03_F
			{
				weapon = "acm_alc_m_sf_LMG_03_F";
				count = 10;
			};
		};
		class TransportItems
		{
			class _xx_sp_fwa_scope_ar_colt3x20
			{
				name = "sp_fwa_scope_ar_colt3x20";
				count = 10;
			};
			class _xx_sp_fwa_scope_bm59_diavari
			{
				name = "sp_fwa_scope_bm59_diavari";
				count = 10;
			};
			class _xx_muzzle_snds_65_TI_blk_F
			{
				name = "muzzle_snds_65_TI_blk_F";
				count = 10;
			};
			class _xx_optic_Arco_blk_F
			{
				name = "optic_Arco_blk_F";
				count = 10;
			};
			class _xx_muzzle_snds_93mmg
			{
				name = "muzzle_snds_93mmg";
				count = 10;
			};
			class _xx_optic_DMS
			{
				name = "optic_DMS";
				count = 10;
			};
			class _xx_bipod_02_F_blk
			{
				name = "bipod_02_F_blk";
				count = 10;
			};
			class _xx_muzzle_snds_M
			{
				name = "muzzle_snds_M";
				count = 10;
			};
		};
	};
	class ACM_O_ATIU_2035_LaunchersBox: Box_East_WpsLaunch_F
	{
		hiddenSelections[] = {"Camo_Signs","Camo"};
		hiddenSelectionsTextures[] = {"\A3\Supplies_F_Exp\Ammoboxes\Data\AmmoBox_signs_OPFOR_CA.paa","\A3\Supplies_F_Exp\Ammoboxes\Data\Box_T_East_Wps_F_co.paa"};
		author = "ALiVE ORBAT CREATOR";
		scope = 2;
		displayName = "Alcillian Territorial Integrity Units (2035) Launchers Box";
		class TransportMagazines
		{
			class _xx_vn_m72_mag
			{
				magazine = "vn_m72_mag";
				count = 5;
			};
			class _xx_vn_m127_mag
			{
				magazine = "vn_m127_mag";
				count = 5;
			};
			class _xx_vn_rpg7_mag
			{
				magazine = "vn_rpg7_mag";
				count = 5;
			};
		};
		class TransportWeapons
		{
			class _xx_vn_m72
			{
				weapon = "vn_m72";
				count = 5;
			};
			class _xx_vn_m127
			{
				weapon = "vn_m127";
				count = 5;
			};
			class _xx_vn_rpg7
			{
				weapon = "vn_rpg7";
				count = 5;
			};
			class _xx_vn_sa7b
			{
				weapon = "vn_sa7b";
				count = 5;
			};
		};
		class TransportItems{};
	};
	class ACM_O_ATIU_2035_UniformBox: Box_CSAT_Equip_F
	{
		hiddenSelections[] = {"Camo_Signs","Camo"};
		hiddenSelectionsTextures[] = {"\A3\Supplies_F_Exp\Ammoboxes\Data\AmmoBox_signs_OPFOR_CA.paa","\A3\Supplies_F_Exp\Ammoboxes\Data\Box_T_East_Wps_F_co.paa"};
		author = "ALiVE ORBAT CREATOR";
		scope = 2;
		displayName = "Alcillian Territorial Integrity Units (2035) Uniform Box";
		class TransportWeapons{};
		class TransportMagazines{};
		class TransportItems
		{
			class _xx_acm_sam_clothes_m_2_1
			{
				name = "acm_sam_clothes_m_2_1";
				count = 15;
			};
			class _xx_acm_sam_clothes_m_2_2
			{
				name = "acm_sam_clothes_m_2_2";
				count = 15;
			};
			class _xx_acm_sam_clothes_m_2_4
			{
				name = "acm_sam_clothes_m_2_4";
				count = 15;
			};
			class _xx_acm_sam_clothes_m_2_3
			{
				name = "acm_sam_clothes_m_2_3";
				count = 15;
			};
			class _xx_acm_sam_clothes_m_3_1
			{
				name = "acm_sam_clothes_m_3_1";
				count = 15;
			};
		};
	};
	class ACM_O_ATIU_2035_SupportBox: Box_East_Support_F
	{
		hiddenSelections[] = {"Camo_Signs","Camo"};
		hiddenSelectionsTextures[] = {"\A3\Supplies_F_Exp\Ammoboxes\Data\AmmoBox_signs_OPFOR_CA.paa","\A3\Supplies_F_Exp\Ammoboxes\Data\Box_T_East_Wps_F_co.paa"};
		author = "ALiVE ORBAT CREATOR";
		scope = 2;
		displayName = "Alcillian Territorial Integrity Units (2035) Support Box";
		class TransportWeapons{};
		class TransportMagazines{};
		class TransportItems
		{
			class _xx_acm_alc_vest_CarrierLite
			{
				name = "acm_alc_vest_CarrierLite";
				count = 10;
			};
			class _xx_H_HelmetAggressor_F
			{
				name = "H_HelmetAggressor_F";
				count = 10;
			};
			class _xx_ItemMap
			{
				name = "ItemMap";
				count = 10;
			};
			class _xx_ItemCompass
			{
				name = "ItemCompass";
				count = 10;
			};
			class _xx_ItemWatch
			{
				name = "ItemWatch";
				count = 10;
			};
			class _xx_ItemRadio
			{
				name = "ItemRadio";
				count = 10;
			};
			class _xx_ItemGPS
			{
				name = "ItemGPS";
				count = 10;
			};
			class _xx_acm_alc_helmet_avenger
			{
				name = "acm_alc_helmet_avenger";
				count = 10;
			};
			class _xx_acm_alc_vest_Carrier
			{
				name = "acm_alc_vest_Carrier";
				count = 10;
			};
			class _xx_acm_alc_helmet_m1
			{
				name = "acm_alc_helmet_m1";
				count = 10;
			};
			class _xx_acm_alc_helmet_m1_3
			{
				name = "acm_alc_helmet_m1_3";
				count = 10;
			};
			class _xx_acm_bag_AL_M_rifleman3
			{
				name = "acm_bag_AL_M_rifleman3";
				count = 10;
			};
			class _xx_V_TacVest_oli
			{
				name = "V_TacVest_oli";
				count = 10;
			};
			class _xx_acm_alc_headwear_boonie_m
			{
				name = "acm_alc_headwear_boonie_m";
				count = 10;
			};
			class _xx_Rangefinder
			{
				name = "Rangefinder";
				count = 10;
			};
			class _xx_acm_alc_g_bandana
			{
				name = "acm_alc_g_bandana";
				count = 10;
			};
			class _xx_vn_b_pack_03
			{
				name = "vn_b_pack_03";
				count = 10;
			};
			class _xx_vn_o_pack_05
			{
				name = "vn_o_pack_05";
				count = 10;
			};
			class _xx_acm_bag_AL_M_AT
			{
				name = "acm_bag_AL_M_AT";
				count = 10;
			};
			class _xx_acm_bag_AL_M_MG
			{
				name = "acm_bag_AL_M_MG";
				count = 10;
			};
			class _xx_acm_bag_AL_M_demo
			{
				name = "acm_bag_AL_M_demo";
				count = 10;
			};
			class _xx_vn_b_pack_prc77_01
			{
				name = "vn_b_pack_prc77_01";
				count = 10;
			};
			class _xx_acm_bag_sam_medic
			{
				name = "acm_bag_sam_medic";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_14
			{
				name = "vn_b_vest_usarmy_14";
				count = 10;
			};
			class _xx_vn_o_helmet_tsh3_01
			{
				name = "vn_o_helmet_tsh3_01";
				count = 10;
			};
			class _xx_acm_alc_helmet_m1_4
			{
				name = "acm_alc_helmet_m1_4";
				count = 10;
			};
			class _xx_Binocular
			{
				name = "Binocular";
				count = 10;
			};
			class _xx_vn_o_vest_vc_05
			{
				name = "vn_o_vest_vc_05";
				count = 10;
			};
			class _xx_G_Aviator
			{
				name = "G_Aviator";
				count = 10;
			};
			class _xx_H_HeadSet_black_F
			{
				name = "H_HeadSet_black_F";
				count = 10;
			};
			class _xx_G_Goggles_VR
			{
				name = "G_Goggles_VR";
				count = 10;
			};
			class _xx_O_UAV_01_backpack_F
			{
				name = "O_UAV_01_backpack_F";
				count = 10;
			};
			class _xx_O_UavTerminal
			{
				name = "O_UavTerminal";
				count = 10;
			};
			class _xx_acm_alc_vest_Smersh_Radio
			{
				name = "acm_alc_vest_Smersh_Radio";
				count = 10;
			};
			class _xx_acm_alc_g_stealth
			{
				name = "acm_alc_g_stealth";
				count = 10;
			};
			class _xx_O_NVGoggles_grn_F
			{
				name = "O_NVGoggles_grn_F";
				count = 10;
			};
			class _xx_acm_alc_vest_Smersh_NoRadio
			{
				name = "acm_alc_vest_Smersh_NoRadio";
				count = 10;
			};
			class _xx_acm_bag_AL_M_AT_SF
			{
				name = "acm_bag_AL_M_AT_SF";
				count = 10;
			};
			class _xx_vn_b_pack_02
			{
				name = "vn_b_pack_02";
				count = 10;
			};
		};
	};
	class ACM_O_ATIU_2035_SupplyBox: O_SupplyCrate_F
	{
		author = "ALiVE ORBAT CREATOR";
		scope = 2;
		displayName = "Alcillian Territorial Integrity Units (2035) Supply Box";
		class TransportMagazines
		{
			class _xx_sp_fwa_20Rnd_556_Ar18_Tracer
			{
				magazine = "sp_fwa_20Rnd_556_Ar18_Tracer";
				count = 50;
			};
			class _xx_vn_m61_grenade_mag
			{
				magazine = "vn_m61_grenade_mag";
				count = 50;
			};
			class _xx_vn_m18_white_mag
			{
				magazine = "vn_m18_white_mag";
				count = 50;
			};
			class _xx_sp_fwa_30Rnd_556_Armalite
			{
				magazine = "sp_fwa_30Rnd_556_Armalite";
				count = 50;
			};
			class _xx_sp_fwa_20rnd_762_bm59
			{
				magazine = "sp_fwa_20rnd_762_bm59";
				count = 50;
			};
			class _xx_sp_fwa_1rnd_riflegrenade_mas_ap
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_ap";
				count = 50;
			};
			class _xx_sp_fwa_1rnd_riflegrenade_mas_at_l
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_at_l";
				count = 50;
			};
			class _xx_sp_fwa_1rnd_riflegrenade_mas_wp
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_wp";
				count = 50;
			};
			class _xx_vn_m127_mag
			{
				magazine = "vn_m127_mag";
				count = 50;
			};
			class _xx_sp_fwa_20Rnd_556_Armalite_Tracer
			{
				magazine = "sp_fwa_20Rnd_556_Armalite_Tracer";
				count = 50;
			};
			class _xx_1Rnd_HE_Grenade_shell
			{
				magazine = "1Rnd_HE_Grenade_shell";
				count = 50;
			};
			class _xx_UGL_FlareWhite_F
			{
				magazine = "UGL_FlareWhite_F";
				count = 50;
			};
			class _xx_1Rnd_Smoke_Grenade_shell
			{
				magazine = "1Rnd_Smoke_Grenade_shell";
				count = 50;
			};
			class _xx_sp_fwa_1rnd_riflegrenade_m9a1_at
			{
				magazine = "sp_fwa_1rnd_riflegrenade_m9a1_at";
				count = 50;
			};
			class _xx_vn_rpg7_mag
			{
				magazine = "vn_rpg7_mag";
				count = 50;
			};
			class _xx_sp_fwa_100Rnd_762_mag
			{
				magazine = "sp_fwa_100Rnd_762_mag";
				count = 50;
			};
			class _xx_vn_mine_m112_remote_mag
			{
				magazine = "vn_mine_m112_remote_mag";
				count = 50;
			};
			class _xx_vn_mine_tripwire_m49_02_mag
			{
				magazine = "vn_mine_tripwire_m49_02_mag";
				count = 50;
			};
			class _xx_vn_mine_m18_x3_range_mag
			{
				magazine = "vn_mine_m18_x3_range_mag";
				count = 50;
			};
			class _xx_vn_mine_satchel_remote_02_mag
			{
				magazine = "vn_mine_satchel_remote_02_mag";
				count = 50;
			};
			class _xx_vn_mine_tm57_mag
			{
				magazine = "vn_mine_tm57_mag";
				count = 50;
			};
			class _xx_vn_m1911_mag
			{
				magazine = "vn_m1911_mag";
				count = 50;
			};
			class _xx_30Rnd_65x39_caseless_green
			{
				magazine = "30Rnd_65x39_caseless_green";
				count = 50;
			};
			class _xx_vn_mk22_mag
			{
				magazine = "vn_mk22_mag";
				count = 50;
			};
			class _xx_1Rnd_SmokeRed_Grenade_shell
			{
				magazine = "1Rnd_SmokeRed_Grenade_shell";
				count = 50;
			};
			class _xx_10Rnd_93x64_DMR_05_Mag
			{
				magazine = "10Rnd_93x64_DMR_05_Mag";
				count = 50;
			};
			class _xx_200Rnd_556x45_Box_F
			{
				magazine = "200Rnd_556x45_Box_F";
				count = 50;
			};
		};
		class TransportWeapons
		{
			class _xx_sp_fwa_ar18
			{
				weapon = "sp_fwa_ar18";
				count = 10;
			};
			class _xx_sp_fwa_ar18_carbine
			{
				weapon = "sp_fwa_ar18_carbine";
				count = 10;
			};
			class _xx_sp_fwa_ar15_603_m16a1_a2
			{
				weapon = "sp_fwa_ar15_603_m16a1_a2";
				count = 10;
			};
			class _xx_sp_fwa_bm59_mk3_alpine
			{
				weapon = "sp_fwa_bm59_mk3_alpine";
				count = 10;
			};
			class _xx_acm_alc_m_sp_m16_m203
			{
				weapon = "acm_alc_m_sp_m16_m203";
				count = 10;
			};
			class _xx_acm_alc_m_sp_bm59
			{
				weapon = "acm_alc_m_sp_bm59";
				count = 10;
			};
			class _xx_sp_fwa_mag58
			{
				weapon = "sp_fwa_mag58";
				count = 10;
			};
			class _xx_vn_m1911
			{
				weapon = "vn_m1911";
				count = 10;
			};
			class _xx_acm_alc_m_sf_kat_c
			{
				weapon = "acm_alc_m_sf_kat_c";
				count = 10;
			};
			class _xx_vn_mk22
			{
				weapon = "vn_mk22";
				count = 10;
			};
			class _xx_acm_alc_m_sf_kat_GL
			{
				weapon = "acm_alc_m_sf_kat_GL";
				count = 10;
			};
			class _xx_acm_alc_m_sf_kat_TL
			{
				weapon = "acm_alc_m_sf_kat_TL";
				count = 10;
			};
			class _xx_acm_alc_m_sf_DMR_05
			{
				weapon = "acm_alc_m_sf_DMR_05";
				count = 10;
			};
			class _xx_acm_alc_m_sf_LMG_03_F
			{
				weapon = "acm_alc_m_sf_LMG_03_F";
				count = 10;
			};
			class _xx_vn_m72
			{
				weapon = "vn_m72";
				count = 10;
			};
			class _xx_vn_m127
			{
				weapon = "vn_m127";
				count = 10;
			};
			class _xx_vn_rpg7
			{
				weapon = "vn_rpg7";
				count = 10;
			};
			class _xx_vn_sa7b
			{
				weapon = "vn_sa7b";
				count = 10;
			};
		};
		class TransportItems
		{
			class _xx_sp_fwa_scope_ar_colt3x20
			{
				name = "sp_fwa_scope_ar_colt3x20";
				count = 10;
			};
			class _xx_sp_fwa_scope_bm59_diavari
			{
				name = "sp_fwa_scope_bm59_diavari";
				count = 10;
			};
			class _xx_muzzle_snds_65_TI_blk_F
			{
				name = "muzzle_snds_65_TI_blk_F";
				count = 10;
			};
			class _xx_optic_Arco_blk_F
			{
				name = "optic_Arco_blk_F";
				count = 10;
			};
			class _xx_muzzle_snds_93mmg
			{
				name = "muzzle_snds_93mmg";
				count = 10;
			};
			class _xx_optic_DMS
			{
				name = "optic_DMS";
				count = 10;
			};
			class _xx_bipod_02_F_blk
			{
				name = "bipod_02_F_blk";
				count = 10;
			};
			class _xx_muzzle_snds_M
			{
				name = "muzzle_snds_M";
				count = 10;
			};
			class _xx_acm_alc_vest_CarrierLite
			{
				name = "acm_alc_vest_CarrierLite";
				count = 10;
			};
			class _xx_H_HelmetAggressor_F
			{
				name = "H_HelmetAggressor_F";
				count = 10;
			};
			class _xx_ItemMap
			{
				name = "ItemMap";
				count = 10;
			};
			class _xx_ItemCompass
			{
				name = "ItemCompass";
				count = 10;
			};
			class _xx_ItemWatch
			{
				name = "ItemWatch";
				count = 10;
			};
			class _xx_ItemRadio
			{
				name = "ItemRadio";
				count = 10;
			};
			class _xx_ItemGPS
			{
				name = "ItemGPS";
				count = 10;
			};
			class _xx_acm_alc_helmet_avenger
			{
				name = "acm_alc_helmet_avenger";
				count = 10;
			};
			class _xx_acm_alc_vest_Carrier
			{
				name = "acm_alc_vest_Carrier";
				count = 10;
			};
			class _xx_acm_alc_helmet_m1
			{
				name = "acm_alc_helmet_m1";
				count = 10;
			};
			class _xx_acm_alc_helmet_m1_3
			{
				name = "acm_alc_helmet_m1_3";
				count = 10;
			};
			class _xx_acm_bag_AL_M_rifleman3
			{
				name = "acm_bag_AL_M_rifleman3";
				count = 10;
			};
			class _xx_V_TacVest_oli
			{
				name = "V_TacVest_oli";
				count = 10;
			};
			class _xx_acm_alc_headwear_boonie_m
			{
				name = "acm_alc_headwear_boonie_m";
				count = 10;
			};
			class _xx_Rangefinder
			{
				name = "Rangefinder";
				count = 10;
			};
			class _xx_acm_alc_g_bandana
			{
				name = "acm_alc_g_bandana";
				count = 10;
			};
			class _xx_vn_b_pack_03
			{
				name = "vn_b_pack_03";
				count = 10;
			};
			class _xx_vn_o_pack_05
			{
				name = "vn_o_pack_05";
				count = 10;
			};
			class _xx_acm_bag_AL_M_AT
			{
				name = "acm_bag_AL_M_AT";
				count = 10;
			};
			class _xx_acm_bag_AL_M_MG
			{
				name = "acm_bag_AL_M_MG";
				count = 10;
			};
			class _xx_acm_bag_AL_M_demo
			{
				name = "acm_bag_AL_M_demo";
				count = 10;
			};
			class _xx_vn_b_pack_prc77_01
			{
				name = "vn_b_pack_prc77_01";
				count = 10;
			};
			class _xx_acm_bag_sam_medic
			{
				name = "acm_bag_sam_medic";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_14
			{
				name = "vn_b_vest_usarmy_14";
				count = 10;
			};
			class _xx_vn_o_helmet_tsh3_01
			{
				name = "vn_o_helmet_tsh3_01";
				count = 10;
			};
			class _xx_acm_alc_helmet_m1_4
			{
				name = "acm_alc_helmet_m1_4";
				count = 10;
			};
			class _xx_Binocular
			{
				name = "Binocular";
				count = 10;
			};
			class _xx_vn_o_vest_vc_05
			{
				name = "vn_o_vest_vc_05";
				count = 10;
			};
			class _xx_G_Aviator
			{
				name = "G_Aviator";
				count = 10;
			};
			class _xx_H_HeadSet_black_F
			{
				name = "H_HeadSet_black_F";
				count = 10;
			};
			class _xx_G_Goggles_VR
			{
				name = "G_Goggles_VR";
				count = 10;
			};
			class _xx_O_UAV_01_backpack_F
			{
				name = "O_UAV_01_backpack_F";
				count = 10;
			};
			class _xx_O_UavTerminal
			{
				name = "O_UavTerminal";
				count = 10;
			};
			class _xx_acm_alc_vest_Smersh_Radio
			{
				name = "acm_alc_vest_Smersh_Radio";
				count = 10;
			};
			class _xx_acm_alc_g_stealth
			{
				name = "acm_alc_g_stealth";
				count = 10;
			};
			class _xx_O_NVGoggles_grn_F
			{
				name = "O_NVGoggles_grn_F";
				count = 10;
			};
			class _xx_acm_alc_vest_Smersh_NoRadio
			{
				name = "acm_alc_vest_Smersh_NoRadio";
				count = 10;
			};
			class _xx_acm_bag_AL_M_AT_SF
			{
				name = "acm_bag_AL_M_AT_SF";
				count = 10;
			};
			class _xx_vn_b_pack_02
			{
				name = "vn_b_pack_02";
				count = 10;
			};
			class _xx_acm_sam_clothes_m_2_1
			{
				name = "acm_sam_clothes_m_2_1";
				count = 10;
			};
			class _xx_acm_sam_clothes_m_2_2
			{
				name = "acm_sam_clothes_m_2_2";
				count = 10;
			};
			class _xx_acm_sam_clothes_m_2_4
			{
				name = "acm_sam_clothes_m_2_4";
				count = 10;
			};
			class _xx_acm_sam_clothes_m_2_3
			{
				name = "acm_sam_clothes_m_2_3";
				count = 10;
			};
			class _xx_acm_sam_clothes_m_3_1
			{
				name = "acm_sam_clothes_m_3_1";
				count = 10;
			};
		};
	};
	class ACM_O_ATIU_AmmoBox: Box_East_Ammo_F
	{
		hiddenSelections[] = {"Camo_Signs","Camo"};
		hiddenSelectionsTextures[] = {"\A3\Supplies_F_Exp\Ammoboxes\Data\AmmoBox_signs_OPFOR_CA.paa","\A3\Supplies_F_Exp\Ammoboxes\Data\Box_T_East_Wps_F_co.paa"};
		author = "ALiVE ORBAT CREATOR";
		scope = 2;
		displayName = "Alcillian Territorial Integrity Units Ammo Box";
		class TransportMagazines
		{
			class _xx_sp_fwa_10Rnd_303_No4
			{
				magazine = "sp_fwa_10Rnd_303_No4";
				count = 50;
			};
			class _xx_vn_m61_grenade_mag
			{
				magazine = "vn_m61_grenade_mag";
				count = 50;
			};
			class _xx_sp_fwa_20Rnd_762_FN49
			{
				magazine = "sp_fwa_20Rnd_762_FN49";
				count = 50;
			};
			class _xx_vn_hp_mag
			{
				magazine = "vn_hp_mag";
				count = 50;
			};
			class _xx_vn_m127_mag
			{
				magazine = "vn_m127_mag";
				count = 50;
			};
			class _xx_sp_fwa_20Rnd_762_FAL_Metric
			{
				magazine = "sp_fwa_20Rnd_762_FAL_Metric";
				count = 50;
			};
			class _xx_vn_m1a1_30_mag
			{
				magazine = "vn_m1a1_30_mag";
				count = 50;
			};
			class _xx_sp_fwa_20Rnd_3006_BAR
			{
				magazine = "sp_fwa_20Rnd_3006_BAR";
				count = 50;
			};
			class _xx_vn_mine_m14_mag
			{
				magazine = "vn_mine_m14_mag";
				count = 50;
			};
			class _xx_vn_mine_m112_remote_mag
			{
				magazine = "vn_mine_m112_remote_mag";
				count = 50;
			};
			class _xx_vn_mine_tm57_mag
			{
				magazine = "vn_mine_tm57_mag";
				count = 50;
			};
			class _xx_vn_mine_m18_x3_range_mag
			{
				magazine = "vn_mine_m18_x3_range_mag";
				count = 50;
			};
			class _xx_vn_m1911_mag
			{
				magazine = "vn_m1911_mag";
				count = 50;
			};
			class _xx_vn_mp40_mag
			{
				magazine = "vn_mp40_mag";
				count = 50;
			};
			class _xx_vn_m18_white_mag
			{
				magazine = "vn_m18_white_mag";
				count = 50;
			};
			class _xx_sp_fwa_1rnd_riflegrenade_mas_wp
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_wp";
				count = 50;
			};
			class _xx_sp_fwa_1rnd_riflegrenade_mas_ap
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_ap";
				count = 50;
			};
			class _xx_sp_fwa_1rnd_riflegrenade_mas_at_l
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_at_l";
				count = 50;
			};
			class _xx_sp_fwa_2inch_he_mag
			{
				magazine = "sp_fwa_2inch_he_mag";
				count = 50;
			};
			class _xx_sp_fwa_2inch_wp_mag
			{
				magazine = "sp_fwa_2inch_wp_mag";
				count = 50;
			};
			class _xx_sp_fwa_2inch_flare_mag
			{
				magazine = "sp_fwa_2inch_flare_mag";
				count = 50;
			};
			class _xx_vn_m3a1_mag
			{
				magazine = "vn_m3a1_mag";
				count = 50;
			};
			class _xx_vn_m16_20_mag
			{
				magazine = "vn_m16_20_mag";
				count = 50;
			};
			class _xx_vn_m63a_150_mag
			{
				magazine = "vn_m63a_150_mag";
				count = 50;
			};
			class _xx_vn_40mm_m680_smoke_w_mag
			{
				magazine = "vn_40mm_m680_smoke_w_mag";
				count = 50;
			};
			class _xx_vn_40mm_m651_cs_mag
			{
				magazine = "vn_40mm_m651_cs_mag";
				count = 50;
			};
			class _xx_vn_40mm_m583_flare_w_mag
			{
				magazine = "vn_40mm_m583_flare_w_mag";
				count = 50;
			};
			class _xx_vn_40mm_m381_he_mag
			{
				magazine = "vn_40mm_m381_he_mag";
				count = 50;
			};
			class _xx_vn_mine_tripwire_m49_02_mag
			{
				magazine = "vn_mine_tripwire_m49_02_mag";
				count = 50;
			};
			class _xx_vn_mine_satchel_remote_02_mag
			{
				magazine = "vn_mine_satchel_remote_02_mag";
				count = 50;
			};
			class _xx_vn_m14_mag
			{
				magazine = "vn_m14_mag";
				count = 50;
			};
		};
		class TransportWeapons{};
		class TransportItems{};
	};
	class ACM_O_ATIU_WeaponsBox: Box_East_Wps_F
	{
		hiddenSelections[] = {"Camo_Signs","Camo"};
		hiddenSelectionsTextures[] = {"\A3\Supplies_F_Exp\Ammoboxes\Data\AmmoBox_signs_OPFOR_CA.paa","\A3\Supplies_F_Exp\Ammoboxes\Data\Box_T_East_Wps_F_co.paa"};
		author = "ALiVE ORBAT CREATOR";
		scope = 2;
		displayName = "Alcillian Territorial Integrity Units Weapons Box";
		class TransportMagazines
		{
			class _xx_sp_fwa_10Rnd_303_No4
			{
				magazine = "sp_fwa_10Rnd_303_No4";
				count = 50;
			};
			class _xx_sp_fwa_20Rnd_762_FN49
			{
				magazine = "sp_fwa_20Rnd_762_FN49";
				count = 50;
			};
			class _xx_vn_hp_mag
			{
				magazine = "vn_hp_mag";
				count = 50;
			};
			class _xx_vn_m1a1_30_mag
			{
				magazine = "vn_m1a1_30_mag";
				count = 50;
			};
			class _xx_sp_fwa_20Rnd_3006_BAR
			{
				magazine = "sp_fwa_20Rnd_3006_BAR";
				count = 50;
			};
			class _xx_vn_m1911_mag
			{
				magazine = "vn_m1911_mag";
				count = 50;
			};
			class _xx_vn_mp40_mag
			{
				magazine = "vn_mp40_mag";
				count = 50;
			};
			class _xx_sp_fwa_1rnd_riflegrenade_mas_wp
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_wp";
				count = 50;
			};
			class _xx_sp_fwa_2inch_he_mag
			{
				magazine = "sp_fwa_2inch_he_mag";
				count = 50;
			};
			class _xx_vn_m3a1_mag
			{
				magazine = "vn_m3a1_mag";
				count = 50;
			};
			class _xx_vn_m16_20_mag
			{
				magazine = "vn_m16_20_mag";
				count = 50;
			};
			class _xx_vn_m63a_150_mag
			{
				magazine = "vn_m63a_150_mag";
				count = 50;
			};
			class _xx_vn_40mm_m381_he_mag
			{
				magazine = "vn_40mm_m381_he_mag";
				count = 50;
			};
			class _xx_vn_m14_mag
			{
				magazine = "vn_m14_mag";
				count = 50;
			};
		};
		class TransportWeapons
		{
			class _xx_sp_fwa_enfield_no5_beech_old
			{
				weapon = "sp_fwa_enfield_no5_beech_old";
				count = 10;
			};
			class _xx_sp_fwa_fn49_arg
			{
				weapon = "sp_fwa_fn49_arg";
				count = 10;
			};
			class _xx_vn_hp
			{
				weapon = "vn_hp";
				count = 10;
			};
			class _xx_vn_m1a1_tommy
			{
				weapon = "vn_m1a1_tommy";
				count = 10;
			};
			class _xx_acm_Fwa_m1918a2_bar_LMG
			{
				weapon = "acm_Fwa_m1918a2_bar_LMG";
				count = 10;
			};
			class _xx_acm_fwa_acillo_marksman
			{
				weapon = "acm_fwa_acillo_marksman";
				count = 10;
			};
			class _xx_vn_m1911
			{
				weapon = "vn_m1911";
				count = 10;
			};
			class _xx_vn_mp40
			{
				weapon = "vn_mp40";
				count = 10;
			};
			class _xx_sp_fwa_enfield_no5
			{
				weapon = "sp_fwa_enfield_no5";
				count = 10;
			};
			class _xx_sp_fwa_2InchMortar
			{
				weapon = "sp_fwa_2InchMortar";
				count = 10;
			};
			class _xx_acm_vn_m3a1_suppress
			{
				weapon = "acm_vn_m3a1_suppress";
				count = 10;
			};
			class _xx_vn_m16_sd
			{
				weapon = "vn_m16_sd";
				count = 10;
			};
			class _xx_vn_m16_nvg_sd
			{
				weapon = "vn_m16_nvg_sd";
				count = 10;
			};
			class _xx_vn_m63a_cdo
			{
				weapon = "vn_m63a_cdo";
				count = 10;
			};
			class _xx_vn_m16_xm148
			{
				weapon = "vn_m16_xm148";
				count = 10;
			};
			class _xx_acm_vn_m14_sd_marksman
			{
				weapon = "acm_vn_m14_sd_marksman";
				count = 10;
			};
			class _xx_vn_mx991_m1911
			{
				weapon = "vn_mx991_m1911";
				count = 10;
			};
		};
		class TransportItems
		{
			class _xx_sp_fwa_acc_carryHandle_bar
			{
				name = "sp_fwa_acc_carryHandle_bar";
				count = 10;
			};
			class _xx_sp_fwa_acc_bipod_bar
			{
				name = "sp_fwa_acc_bipod_bar";
				count = 10;
			};
			class _xx_sp_fwa_no32_vintage
			{
				name = "sp_fwa_no32_vintage";
				count = 10;
			};
			class _xx_vn_s_m3a1
			{
				name = "vn_s_m3a1";
				count = 10;
			};
			class _xx_vn_s_m16
			{
				name = "vn_s_m16";
				count = 10;
			};
			class _xx_vn_o_anpvs2_m16
			{
				name = "vn_o_anpvs2_m16";
				count = 10;
			};
			class _xx_vn_s_m14
			{
				name = "vn_s_m14";
				count = 10;
			};
			class _xx_vn_o_9x_m14
			{
				name = "vn_o_9x_m14";
				count = 10;
			};
			class _xx_vn_b_camo_m14
			{
				name = "vn_b_camo_m14";
				count = 10;
			};
		};
	};
	class ACM_O_ATIU_LaunchersBox: Box_East_WpsLaunch_F
	{
		hiddenSelections[] = {"Camo_Signs","Camo"};
		hiddenSelectionsTextures[] = {"\A3\Supplies_F_Exp\Ammoboxes\Data\AmmoBox_signs_OPFOR_CA.paa","\A3\Supplies_F_Exp\Ammoboxes\Data\Box_T_East_Wps_F_co.paa"};
		author = "ALiVE ORBAT CREATOR";
		scope = 2;
		displayName = "Alcillian Territorial Integrity Units Launchers Box";
		class TransportMagazines
		{
			class _xx_vn_m72_mag
			{
				magazine = "vn_m72_mag";
				count = 5;
			};
			class _xx_vn_m127_mag
			{
				magazine = "vn_m127_mag";
				count = 5;
			};
		};
		class TransportWeapons
		{
			class _xx_vn_m72
			{
				weapon = "vn_m72";
				count = 5;
			};
			class _xx_vn_m127
			{
				weapon = "vn_m127";
				count = 5;
			};
		};
		class TransportItems{};
	};
	class ACM_O_ATIU_UniformBox: Box_CSAT_Equip_F
	{
		hiddenSelections[] = {"Camo_Signs","Camo"};
		hiddenSelectionsTextures[] = {"\A3\Supplies_F_Exp\Ammoboxes\Data\AmmoBox_signs_OPFOR_CA.paa","\A3\Supplies_F_Exp\Ammoboxes\Data\Box_T_East_Wps_F_co.paa"};
		author = "ALiVE ORBAT CREATOR";
		scope = 2;
		displayName = "Alcillian Territorial Integrity Units Uniform Box";
		class TransportWeapons{};
		class TransportMagazines{};
		class TransportItems
		{
			class _xx_acm_sam_clothes02_1
			{
				name = "acm_sam_clothes02_1";
				count = 15;
			};
			class _xx_acm_sam_clothes02_2
			{
				name = "acm_sam_clothes02_2";
				count = 15;
			};
			class _xx_acm_sam_clothes02_3
			{
				name = "acm_sam_clothes02_3";
				count = 15;
			};
			class _xx_acm_sam_clothes02_4
			{
				name = "acm_sam_clothes02_4";
				count = 15;
			};
			class _xx_acm_sam_clothes02_5
			{
				name = "acm_sam_clothes02_5";
				count = 15;
			};
		};
	};
	class ACM_O_ATIU_SupportBox: Box_East_Support_F
	{
		hiddenSelections[] = {"Camo_Signs","Camo"};
		hiddenSelectionsTextures[] = {"\A3\Supplies_F_Exp\Ammoboxes\Data\AmmoBox_signs_OPFOR_CA.paa","\A3\Supplies_F_Exp\Ammoboxes\Data\Box_T_East_Wps_F_co.paa"};
		author = "ALiVE ORBAT CREATOR";
		scope = 2;
		displayName = "Alcillian Territorial Integrity Units Support Box";
		class TransportWeapons{};
		class TransportMagazines{};
		class TransportItems
		{
			class _xx_vn_o_vest_02
			{
				name = "vn_o_vest_02";
				count = 10;
			};
			class _xx_vn_b_helmet_m1_01_01
			{
				name = "vn_b_helmet_m1_01_01";
				count = 10;
			};
			class _xx_ItemMap
			{
				name = "ItemMap";
				count = 10;
			};
			class _xx_vn_b_item_compass
			{
				name = "vn_b_item_compass";
				count = 10;
			};
			class _xx_vn_b_item_watch
			{
				name = "vn_b_item_watch";
				count = 10;
			};
			class _xx_vn_b_item_radio_urc10
			{
				name = "vn_b_item_radio_urc10";
				count = 10;
			};
			class _xx_vn_b_boonie_01_01
			{
				name = "vn_b_boonie_01_01";
				count = 10;
			};
			class _xx_vn_b_vest_seal_05
			{
				name = "vn_b_vest_seal_05";
				count = 10;
			};
			class _xx_vn_b_helmet_m1_07_01
			{
				name = "vn_b_helmet_m1_07_01";
				count = 10;
			};
			class _xx_vn_i_helmet_m1_02_01
			{
				name = "vn_i_helmet_m1_02_01";
				count = 10;
			};
			class _xx_vn_mk21_binocs
			{
				name = "vn_mk21_binocs";
				count = 10;
			};
			class _xx_vn_o_vest_07
			{
				name = "vn_o_vest_07";
				count = 10;
			};
			class _xx_vn_i_helmet_m1_03_01
			{
				name = "vn_i_helmet_m1_03_01";
				count = 10;
			};
			class _xx_vn_o_vest_01
			{
				name = "vn_o_vest_01";
				count = 10;
			};
			class _xx_vn_b_pack_prc77_01
			{
				name = "vn_b_pack_prc77_01";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_06
			{
				name = "vn_b_vest_usarmy_06";
				count = 10;
			};
			class _xx_acm_bag_AL_MG
			{
				name = "acm_bag_AL_MG";
				count = 10;
			};
			class _xx_vn_o_vest_vc_04
			{
				name = "vn_o_vest_vc_04";
				count = 10;
			};
			class _xx_acm_bag_sam_medic
			{
				name = "acm_bag_sam_medic";
				count = 10;
			};
			class _xx_vn_m19_binocs_grey
			{
				name = "vn_m19_binocs_grey";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_04
			{
				name = "vn_b_vest_usarmy_04";
				count = 10;
			};
			class _xx_vn_b_boonie_02_01
			{
				name = "vn_b_boonie_02_01";
				count = 10;
			};
			class _xx_vn_o_vest_08
			{
				name = "vn_o_vest_08";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_12
			{
				name = "vn_b_vest_usarmy_12";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_11
			{
				name = "vn_b_vest_usarmy_11";
				count = 10;
			};
			class _xx_vn_b_helmet_m1_09_01
			{
				name = "vn_b_helmet_m1_09_01";
				count = 10;
			};
			class _xx_vn_b_vest_seal_04
			{
				name = "vn_b_vest_seal_04";
				count = 10;
			};
			class _xx_vn_b_vest_seal_02
			{
				name = "vn_b_vest_seal_02";
				count = 10;
			};
			class _xx_acm_bag_AL_GL
			{
				name = "acm_bag_AL_GL";
				count = 10;
			};
			class _xx_vn_b_helmet_t56_02_03
			{
				name = "vn_b_helmet_t56_02_03";
				count = 10;
			};
			class _xx_vn_o_vest_vc_05
			{
				name = "vn_o_vest_vc_05";
				count = 10;
			};
			class _xx_vn_b_vest_aircrew_05
			{
				name = "vn_b_vest_aircrew_05";
				count = 10;
			};
			class _xx_vn_b_helmet_svh4_02_05
			{
				name = "vn_b_helmet_svh4_02_05";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_05
			{
				name = "vn_b_vest_usarmy_05";
				count = 10;
			};
			class _xx_acm_bag_AL_Mortar
			{
				name = "acm_bag_AL_Mortar";
				count = 10;
			};
			class _xx_vn_b_boonie_01_04
			{
				name = "vn_b_boonie_01_04";
				count = 10;
			};
			class _xx_G_Bandanna_oli
			{
				name = "G_Bandanna_oli";
				count = 10;
			};
			class _xx_vn_anpvs2_binoc
			{
				name = "vn_anpvs2_binoc";
				count = 10;
			};
			class _xx_vn_b_helmet_m1_06_01
			{
				name = "vn_b_helmet_m1_06_01";
				count = 10;
			};
			class _xx_vn_b_boonie_03_04
			{
				name = "vn_b_boonie_03_04";
				count = 10;
			};
			class _xx_vn_b_vest_seal_03
			{
				name = "vn_b_vest_seal_03";
				count = 10;
			};
			class _xx_vn_b_helmet_m1_08_01
			{
				name = "vn_b_helmet_m1_08_01";
				count = 10;
			};
			class _xx_vn_b_vest_seal_06
			{
				name = "vn_b_vest_seal_06";
				count = 10;
			};
			class _xx_vn_b_boonie_02_04
			{
				name = "vn_b_boonie_02_04";
				count = 10;
			};
			class _xx_G_Bandanna_blk
			{
				name = "G_Bandanna_blk";
				count = 10;
			};
			class _xx_vn_b_vest_seal_07
			{
				name = "vn_b_vest_seal_07";
				count = 10;
			};
			class _xx_vn_b_helmet_m1_04_01
			{
				name = "vn_b_helmet_m1_04_01";
				count = 10;
			};
			class _xx_acm_bag_alc_demo
			{
				name = "acm_bag_alc_demo";
				count = 10;
			};
			class _xx_vn_b_vest_sog_05
			{
				name = "vn_b_vest_sog_05";
				count = 10;
			};
			class _xx_vn_b_bandana_04
			{
				name = "vn_b_bandana_04";
				count = 10;
			};
		};
	};
	class ACM_O_ATIU_SupplyBox: O_SupplyCrate_F
	{
		author = "ALiVE ORBAT CREATOR";
		scope = 2;
		displayName = "Alcillian Territorial Integrity Units Supply Box";
		class TransportMagazines
		{
			class _xx_sp_fwa_10Rnd_303_No4
			{
				magazine = "sp_fwa_10Rnd_303_No4";
				count = 50;
			};
			class _xx_vn_m61_grenade_mag
			{
				magazine = "vn_m61_grenade_mag";
				count = 50;
			};
			class _xx_sp_fwa_20Rnd_762_FN49
			{
				magazine = "sp_fwa_20Rnd_762_FN49";
				count = 50;
			};
			class _xx_vn_hp_mag
			{
				magazine = "vn_hp_mag";
				count = 50;
			};
			class _xx_vn_m127_mag
			{
				magazine = "vn_m127_mag";
				count = 50;
			};
			class _xx_sp_fwa_20Rnd_762_FAL_Metric
			{
				magazine = "sp_fwa_20Rnd_762_FAL_Metric";
				count = 50;
			};
			class _xx_vn_m1a1_30_mag
			{
				magazine = "vn_m1a1_30_mag";
				count = 50;
			};
			class _xx_sp_fwa_20Rnd_3006_BAR
			{
				magazine = "sp_fwa_20Rnd_3006_BAR";
				count = 50;
			};
			class _xx_vn_mine_m14_mag
			{
				magazine = "vn_mine_m14_mag";
				count = 50;
			};
			class _xx_vn_mine_m112_remote_mag
			{
				magazine = "vn_mine_m112_remote_mag";
				count = 50;
			};
			class _xx_vn_mine_tm57_mag
			{
				magazine = "vn_mine_tm57_mag";
				count = 50;
			};
			class _xx_vn_mine_m18_x3_range_mag
			{
				magazine = "vn_mine_m18_x3_range_mag";
				count = 50;
			};
			class _xx_vn_m1911_mag
			{
				magazine = "vn_m1911_mag";
				count = 50;
			};
			class _xx_vn_mp40_mag
			{
				magazine = "vn_mp40_mag";
				count = 50;
			};
			class _xx_vn_m18_white_mag
			{
				magazine = "vn_m18_white_mag";
				count = 50;
			};
			class _xx_sp_fwa_1rnd_riflegrenade_mas_wp
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_wp";
				count = 50;
			};
			class _xx_sp_fwa_1rnd_riflegrenade_mas_ap
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_ap";
				count = 50;
			};
			class _xx_sp_fwa_1rnd_riflegrenade_mas_at_l
			{
				magazine = "sp_fwa_1rnd_riflegrenade_mas_at_l";
				count = 50;
			};
			class _xx_sp_fwa_2inch_he_mag
			{
				magazine = "sp_fwa_2inch_he_mag";
				count = 50;
			};
			class _xx_sp_fwa_2inch_wp_mag
			{
				magazine = "sp_fwa_2inch_wp_mag";
				count = 50;
			};
			class _xx_sp_fwa_2inch_flare_mag
			{
				magazine = "sp_fwa_2inch_flare_mag";
				count = 50;
			};
			class _xx_vn_m3a1_mag
			{
				magazine = "vn_m3a1_mag";
				count = 50;
			};
			class _xx_vn_m16_20_mag
			{
				magazine = "vn_m16_20_mag";
				count = 50;
			};
			class _xx_vn_m63a_150_mag
			{
				magazine = "vn_m63a_150_mag";
				count = 50;
			};
			class _xx_vn_40mm_m680_smoke_w_mag
			{
				magazine = "vn_40mm_m680_smoke_w_mag";
				count = 50;
			};
			class _xx_vn_40mm_m651_cs_mag
			{
				magazine = "vn_40mm_m651_cs_mag";
				count = 50;
			};
			class _xx_vn_40mm_m583_flare_w_mag
			{
				magazine = "vn_40mm_m583_flare_w_mag";
				count = 50;
			};
			class _xx_vn_40mm_m381_he_mag
			{
				magazine = "vn_40mm_m381_he_mag";
				count = 50;
			};
			class _xx_vn_mine_tripwire_m49_02_mag
			{
				magazine = "vn_mine_tripwire_m49_02_mag";
				count = 50;
			};
			class _xx_vn_mine_satchel_remote_02_mag
			{
				magazine = "vn_mine_satchel_remote_02_mag";
				count = 50;
			};
			class _xx_vn_m14_mag
			{
				magazine = "vn_m14_mag";
				count = 50;
			};
		};
		class TransportWeapons
		{
			class _xx_sp_fwa_enfield_no5_beech_old
			{
				weapon = "sp_fwa_enfield_no5_beech_old";
				count = 10;
			};
			class _xx_sp_fwa_fn49_arg
			{
				weapon = "sp_fwa_fn49_arg";
				count = 10;
			};
			class _xx_vn_hp
			{
				weapon = "vn_hp";
				count = 10;
			};
			class _xx_vn_m1a1_tommy
			{
				weapon = "vn_m1a1_tommy";
				count = 10;
			};
			class _xx_acm_Fwa_m1918a2_bar_LMG
			{
				weapon = "acm_Fwa_m1918a2_bar_LMG";
				count = 10;
			};
			class _xx_acm_fwa_acillo_marksman
			{
				weapon = "acm_fwa_acillo_marksman";
				count = 10;
			};
			class _xx_vn_m1911
			{
				weapon = "vn_m1911";
				count = 10;
			};
			class _xx_vn_mp40
			{
				weapon = "vn_mp40";
				count = 10;
			};
			class _xx_sp_fwa_enfield_no5
			{
				weapon = "sp_fwa_enfield_no5";
				count = 10;
			};
			class _xx_sp_fwa_2InchMortar
			{
				weapon = "sp_fwa_2InchMortar";
				count = 10;
			};
			class _xx_acm_vn_m3a1_suppress
			{
				weapon = "acm_vn_m3a1_suppress";
				count = 10;
			};
			class _xx_vn_m16_sd
			{
				weapon = "vn_m16_sd";
				count = 10;
			};
			class _xx_vn_m16_nvg_sd
			{
				weapon = "vn_m16_nvg_sd";
				count = 10;
			};
			class _xx_vn_m63a_cdo
			{
				weapon = "vn_m63a_cdo";
				count = 10;
			};
			class _xx_vn_m16_xm148
			{
				weapon = "vn_m16_xm148";
				count = 10;
			};
			class _xx_acm_vn_m14_sd_marksman
			{
				weapon = "acm_vn_m14_sd_marksman";
				count = 10;
			};
			class _xx_vn_mx991_m1911
			{
				weapon = "vn_mx991_m1911";
				count = 10;
			};
			class _xx_vn_m72
			{
				weapon = "vn_m72";
				count = 10;
			};
			class _xx_vn_m127
			{
				weapon = "vn_m127";
				count = 10;
			};
		};
		class TransportItems
		{
			class _xx_sp_fwa_acc_carryHandle_bar
			{
				name = "sp_fwa_acc_carryHandle_bar";
				count = 10;
			};
			class _xx_sp_fwa_acc_bipod_bar
			{
				name = "sp_fwa_acc_bipod_bar";
				count = 10;
			};
			class _xx_sp_fwa_no32_vintage
			{
				name = "sp_fwa_no32_vintage";
				count = 10;
			};
			class _xx_vn_s_m3a1
			{
				name = "vn_s_m3a1";
				count = 10;
			};
			class _xx_vn_s_m16
			{
				name = "vn_s_m16";
				count = 10;
			};
			class _xx_vn_o_anpvs2_m16
			{
				name = "vn_o_anpvs2_m16";
				count = 10;
			};
			class _xx_vn_s_m14
			{
				name = "vn_s_m14";
				count = 10;
			};
			class _xx_vn_o_9x_m14
			{
				name = "vn_o_9x_m14";
				count = 10;
			};
			class _xx_vn_b_camo_m14
			{
				name = "vn_b_camo_m14";
				count = 10;
			};
			class _xx_vn_o_vest_02
			{
				name = "vn_o_vest_02";
				count = 10;
			};
			class _xx_vn_b_helmet_m1_01_01
			{
				name = "vn_b_helmet_m1_01_01";
				count = 10;
			};
			class _xx_ItemMap
			{
				name = "ItemMap";
				count = 10;
			};
			class _xx_vn_b_item_compass
			{
				name = "vn_b_item_compass";
				count = 10;
			};
			class _xx_vn_b_item_watch
			{
				name = "vn_b_item_watch";
				count = 10;
			};
			class _xx_vn_b_item_radio_urc10
			{
				name = "vn_b_item_radio_urc10";
				count = 10;
			};
			class _xx_vn_b_boonie_01_01
			{
				name = "vn_b_boonie_01_01";
				count = 10;
			};
			class _xx_vn_b_vest_seal_05
			{
				name = "vn_b_vest_seal_05";
				count = 10;
			};
			class _xx_vn_b_helmet_m1_07_01
			{
				name = "vn_b_helmet_m1_07_01";
				count = 10;
			};
			class _xx_vn_i_helmet_m1_02_01
			{
				name = "vn_i_helmet_m1_02_01";
				count = 10;
			};
			class _xx_vn_mk21_binocs
			{
				name = "vn_mk21_binocs";
				count = 10;
			};
			class _xx_vn_o_vest_07
			{
				name = "vn_o_vest_07";
				count = 10;
			};
			class _xx_vn_i_helmet_m1_03_01
			{
				name = "vn_i_helmet_m1_03_01";
				count = 10;
			};
			class _xx_vn_o_vest_01
			{
				name = "vn_o_vest_01";
				count = 10;
			};
			class _xx_vn_b_pack_prc77_01
			{
				name = "vn_b_pack_prc77_01";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_06
			{
				name = "vn_b_vest_usarmy_06";
				count = 10;
			};
			class _xx_acm_bag_AL_MG
			{
				name = "acm_bag_AL_MG";
				count = 10;
			};
			class _xx_vn_o_vest_vc_04
			{
				name = "vn_o_vest_vc_04";
				count = 10;
			};
			class _xx_acm_bag_sam_medic
			{
				name = "acm_bag_sam_medic";
				count = 10;
			};
			class _xx_vn_m19_binocs_grey
			{
				name = "vn_m19_binocs_grey";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_04
			{
				name = "vn_b_vest_usarmy_04";
				count = 10;
			};
			class _xx_vn_b_boonie_02_01
			{
				name = "vn_b_boonie_02_01";
				count = 10;
			};
			class _xx_vn_o_vest_08
			{
				name = "vn_o_vest_08";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_12
			{
				name = "vn_b_vest_usarmy_12";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_11
			{
				name = "vn_b_vest_usarmy_11";
				count = 10;
			};
			class _xx_vn_b_helmet_m1_09_01
			{
				name = "vn_b_helmet_m1_09_01";
				count = 10;
			};
			class _xx_vn_b_vest_seal_04
			{
				name = "vn_b_vest_seal_04";
				count = 10;
			};
			class _xx_vn_b_vest_seal_02
			{
				name = "vn_b_vest_seal_02";
				count = 10;
			};
			class _xx_acm_bag_AL_GL
			{
				name = "acm_bag_AL_GL";
				count = 10;
			};
			class _xx_vn_b_helmet_t56_02_03
			{
				name = "vn_b_helmet_t56_02_03";
				count = 10;
			};
			class _xx_vn_o_vest_vc_05
			{
				name = "vn_o_vest_vc_05";
				count = 10;
			};
			class _xx_vn_b_vest_aircrew_05
			{
				name = "vn_b_vest_aircrew_05";
				count = 10;
			};
			class _xx_vn_b_helmet_svh4_02_05
			{
				name = "vn_b_helmet_svh4_02_05";
				count = 10;
			};
			class _xx_vn_b_vest_usarmy_05
			{
				name = "vn_b_vest_usarmy_05";
				count = 10;
			};
			class _xx_acm_bag_AL_Mortar
			{
				name = "acm_bag_AL_Mortar";
				count = 10;
			};
			class _xx_vn_b_boonie_01_04
			{
				name = "vn_b_boonie_01_04";
				count = 10;
			};
			class _xx_G_Bandanna_oli
			{
				name = "G_Bandanna_oli";
				count = 10;
			};
			class _xx_vn_anpvs2_binoc
			{
				name = "vn_anpvs2_binoc";
				count = 10;
			};
			class _xx_vn_b_helmet_m1_06_01
			{
				name = "vn_b_helmet_m1_06_01";
				count = 10;
			};
			class _xx_vn_b_boonie_03_04
			{
				name = "vn_b_boonie_03_04";
				count = 10;
			};
			class _xx_vn_b_vest_seal_03
			{
				name = "vn_b_vest_seal_03";
				count = 10;
			};
			class _xx_vn_b_helmet_m1_08_01
			{
				name = "vn_b_helmet_m1_08_01";
				count = 10;
			};
			class _xx_vn_b_vest_seal_06
			{
				name = "vn_b_vest_seal_06";
				count = 10;
			};
			class _xx_vn_b_boonie_02_04
			{
				name = "vn_b_boonie_02_04";
				count = 10;
			};
			class _xx_G_Bandanna_blk
			{
				name = "G_Bandanna_blk";
				count = 10;
			};
			class _xx_vn_b_vest_seal_07
			{
				name = "vn_b_vest_seal_07";
				count = 10;
			};
			class _xx_vn_b_helmet_m1_04_01
			{
				name = "vn_b_helmet_m1_04_01";
				count = 10;
			};
			class _xx_acm_bag_alc_demo
			{
				name = "acm_bag_alc_demo";
				count = 10;
			};
			class _xx_vn_b_vest_sog_05
			{
				name = "vn_b_vest_sog_05";
				count = 10;
			};
			class _xx_vn_b_bandana_04
			{
				name = "vn_b_bandana_04";
				count = 10;
			};
			class _xx_acm_sam_clothes02_1
			{
				name = "acm_sam_clothes02_1";
				count = 10;
			};
			class _xx_acm_sam_clothes02_2
			{
				name = "acm_sam_clothes02_2";
				count = 10;
			};
			class _xx_acm_sam_clothes02_3
			{
				name = "acm_sam_clothes02_3";
				count = 10;
			};
			class _xx_acm_sam_clothes02_4
			{
				name = "acm_sam_clothes02_4";
				count = 10;
			};
			class _xx_acm_sam_clothes02_5
			{
				name = "acm_sam_clothes02_5";
				count = 10;
			};
		};
	};
	class FlagCarrier;
	class Flag_ACM_SAC: FlagCarrier
	{
		author = "Anthrax";
		class SimpleObject
		{
			eden = 0;
			animate[] = {{"flag",0}};
			hide[] = {};
			verticalOffset = 3.977;
			verticalOffsetWorld = 0;
			init = "''";
		};
		editorPreview = "\A3\EditorPreviews_F\Data\CfgVehicles\Flag_AAF_F.jpg";
		scope = 2;
		scopeCurator = 2;
		displayName = "Flag (Saint Anselm)";
		hiddenSelectionsTextures[] = {"\A3\Structures_F\Mil\Flags\Data\Mast_mil_CO.paa"};
		hiddenSelectionsMaterials[] = {"\A3\Structures_F\Mil\Flags\Data\Mast_mil.rvmat"};
		class EventHandlers
		{
			init = "(_this select 0) setFlagTexture '\acm_saintanselm\faction\flag_anselm_co.paa'";
		};
	};
	class Flag_ACM_ALC: FlagCarrier
	{
		author = "Anthrax";
		class SimpleObject
		{
			eden = 0;
			animate[] = {{"flag",0}};
			hide[] = {};
			verticalOffset = 3.977;
			verticalOffsetWorld = 0;
			init = "''";
		};
		editorPreview = "\A3\EditorPreviews_F\Data\CfgVehicles\Flag_AAF_F.jpg";
		scope = 2;
		scopeCurator = 2;
		displayName = "Flag (Alcillo)";
		hiddenSelectionsTextures[] = {"\A3\Structures_F\Mil\Flags\Data\Mast_mil_CO.paa"};
		hiddenSelectionsMaterials[] = {"\A3\Structures_F\Mil\Flags\Data\Mast_mil.rvmat"};
		class EventHandlers
		{
			init = "(_this select 0) setFlagTexture '\acm_saintanselm\faction\flag_alcillo_co.paa'";
		};
	};
	class Banner_01_base_F;
	class Banner_ACM_SAC: Banner_01_base_F
	{
		author = "Anthrax";
		class SimpleObject
		{
			eden = 0;
			animate[] = {};
			hide[] = {};
			verticalOffset = 0.469;
			verticalOffsetWorld = 0;
			init = "''";
		};
		editorPreview = "\A3\EditorPreviews_F_Orange\Data\CfgVehicles\Banner_01_NATO_F.jpg";
		scope = 2;
		scopeCurator = 2;
		displayName = "Banner (Saint Anselm)";
		hiddenSelectionsTextures[] = {"\acm_saintanselm\faction\flag_anselm_co.paa"};
	};
	class Banner_ACM_ALC: Banner_01_base_F
	{
		author = "Anthrax";
		class SimpleObject
		{
			eden = 0;
			animate[] = {};
			hide[] = {};
			verticalOffset = 0.469;
			verticalOffsetWorld = 0;
			init = "''";
		};
		editorPreview = "\A3\EditorPreviews_F_Orange\Data\CfgVehicles\Banner_01_NATO_F.jpg";
		scope = 2;
		scopeCurator = 2;
		displayName = "Banner (Alcillo)";
		hiddenSelectionsTextures[] = {"\acm_saintanselm\faction\flag_alcillo_co.paa"};
	};
};
class CfgGroups
{
	class WEST
	{
		class ACM_B_SAC
		{
			name = "Saint Anselm Constabulary";
			class Infantry
			{
				name = "Infantry";
				class b_acmbsac_infantry_fireteam
				{
					name = "Fireteam";
					side = 1;
					faction = "ACM_B_SAC";
					icon = "\A3\ui_f\data\map\markers\nato\b_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "ACM_b_sam_men_rifleman";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_rifleman_AT";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_Marksman";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_grenadier";
					};
				};
				class b_acmbsac_infantry_squad
				{
					name = "Squad";
					side = 1;
					faction = "ACM_B_SAC";
					icon = "\A3\ui_f\data\map\markers\nato\b_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "ACM_b_sam_men_SL";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_rifleman";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_MG";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_Medic";
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
						vehicle = "ACM_b_sam_men_rifleman_AT";
					};
					class Unit6
					{
						position[] = {-15,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_Marksman";
					};
					class Unit7
					{
						position[] = {20,-20,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_grenadier";
					};
				};
				class b_acmbsac_infantry_sentry
				{
					name = "Sentry";
					side = 1;
					faction = "ACM_B_SAC";
					icon = "\A3\ui_f\data\map\markers\nato\b_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "ACM_b_sam_men_rifleman_2";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_rifleman_3";
					};
				};
				class b_acmbsac_infantry_machine_gun_team
				{
					name = "Machine Gun Team";
					side = 1;
					faction = "ACM_B_SAC";
					icon = "\A3\ui_f\data\map\markers\nato\b_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "ACM_b_sam_men_SL";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_MG";
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
						vehicle = "ACM_b_sam_men_HMG";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_HMG";
					};
					class Unit5
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_RTO";
					};
				};
				class b_acmbsac_infantry_anti_armour_team
				{
					name = "Anti-Armour Team";
					side = 1;
					faction = "ACM_B_SAC";
					icon = "\A3\ui_f\data\map\markers\nato\b_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "ACM_b_sam_men_SL";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_rifleman_3";
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
						vehicle = "ACM_b_sam_men_rifleman_AT";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_rifleman_AT";
					};
					class Unit5
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_rifleman_3";
					};
				};
				class b_acmbsac_infantry_assault_group
				{
					name = "Assault Group";
					side = 1;
					faction = "ACM_B_SAC";
					icon = "\A3\ui_f\data\map\markers\nato\b_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "ACM_b_sam_men_SL";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_MG";
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
						vehicle = "ACM_b_sam_men_Medic";
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
						vehicle = "ACM_b_sam_men_Trench";
					};
					class Unit6
					{
						position[] = {-15,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_Demo";
					};
					class Unit7
					{
						position[] = {20,-20,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_grenadier";
					};
				};
				class b_acmbsac_infantry_coast_guard_group
				{
					name = "Coast Guard Group";
					side = 1;
					faction = "ACM_B_SAC";
					icon = "\A3\ui_f\data\map\markers\nato\b_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "ACM_b_sam_men_cg1";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_cg2";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_cg1";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_cg2";
					};
				};
				class b_acmbsac_infantry_hq_group
				{
					name = "HQ Group";
					side = 1;
					faction = "ACM_B_SAC";
					icon = "\A3\ui_f\data\map\markers\nato\b_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "ACM_b_sam_men_officer";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_rifleman";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_officer";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_Medic";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_SL";
					};
					class Unit5
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_RTO2";
					};
				};
			};
			class SpecOps
			{
				name = "Special Forces";
				class b_acmbsac_specops_recon_team
				{
					name = "Recon Team";
					side = 1;
					faction = "ACM_B_SAC";
					icon = "\A3\ui_f\data\map\markers\nato\b_recon.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "ACM_b_sam_men_SF_TL";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_SF_scout";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_SF_Medic";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_SF_Demo";
					};
				};
				class b_acmbsac_specops_recon_squad
				{
					name = "Recon Squad";
					side = 1;
					faction = "ACM_B_SAC";
					icon = "\A3\ui_f\data\map\markers\nato\b_recon.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "ACM_b_sam_men_SF_TL";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_SF_scout";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_SF_Medic";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_SF_Autorifleman";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_SF_Demo";
					};
					class Unit5
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_SF_Grenadier";
					};
				};
				class b_acmbsac_specops_night_patrol
				{
					name = "Night Patrol";
					side = 1;
					faction = "ACM_B_SAC";
					icon = "\A3\ui_f\data\map\markers\nato\b_recon.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "ACM_b_sam_men_SF_scout";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_SF_Night";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_SF_scout";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_SF_Night";
					};
				};
			};
			class Motorized
			{
				name = "Motorized Infantry";
				class b_acmbsac_motorized_motorized_patrol
				{
					name = "Motorized Patrol";
					side = 1;
					faction = "ACM_B_SAC";
					icon = "\A3\ui_f\data\map\markers\nato\b_motor_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "acm_b_sac_vehicle_m151";
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
						vehicle = "ACM_b_sam_men_grenadier";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_rifleman_AT";
					};
				};
				class b_acmbsac_motorized_tow_group
				{
					name = "TOW-Group";
					side = 1;
					faction = "ACM_B_SAC";
					icon = "\A3\ui_f\data\map\markers\nato\b_motor_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "acm_b_sac_vehicle_m151_TOW";
					};
					class Unit1
					{
						position[] = {5,-7,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "acm_b_sac_vehicle_m151_TOW";
					};
				};
				class b_acmbsac_motorized_m15a1_patrol
				{
					name = "M51A1 Patrol";
					side = 1;
					faction = "ACM_B_SAC";
					icon = "\A3\ui_f\data\map\markers\nato\b_motor_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "acm_b_sac_vehicle_m151_mg_patrol";
					};
					class Unit1
					{
						position[] = {5,-7,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "acm_b_sac_vehicle_m151_mg_patrol";
					};
				};
				class b_acmbsac_motorized_motorized_assault
				{
					name = "Motorized Assault";
					side = 1;
					faction = "ACM_B_SAC";
					icon = "\A3\ui_f\data\map\markers\nato\b_motor_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "acm_b_sac_vehicle_m151_mg";
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
						vehicle = "ACM_b_sam_men_rifleman_3";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_Marksman";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_Medic";
					};
					class Unit5
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_RTO";
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
				};
				class b_acmbsac_motorized_m151_armoured_section
				{
					name = "M151 Armoured Section";
					side = 1;
					faction = "ACM_B_SAC";
					icon = "\A3\ui_f\data\map\markers\nato\b_motor_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "acm_b_sac_vehicle_m151_Armoured";
					};
					class Unit1
					{
						position[] = {5,-7,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "acm_b_sac_vehicle_m151_Armoured";
					};
				};
				class b_acmbsac_motorized_motorized_reinforcements_m54
				{
					name = "Motorized Reinforcements (M54)";
					side = 1;
					faction = "ACM_B_SAC";
					icon = "\A3\ui_f\data\map\markers\nato\b_motor_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "acm_b_sac_vehicle_m54_transport_Cover";
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
						vehicle = "ACM_b_sam_men_rifleman_AT";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_MG";
					};
					class Unit5
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_RTO";
					};
					class Unit6
					{
						position[] = {-15,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_rifleman_3";
					};
					class Unit7
					{
						position[] = {20,-20,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_Medic";
					};
					class Unit8
					{
						position[] = {-20,-20,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_grenadier";
					};
					class Unit9
					{
						position[] = {25,-25,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_Demo";
					};
					class Unit10
					{
						position[] = {-25,-25,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_rifleman_2";
					};
					class Unit11
					{
						position[] = {30,-30,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_HMG";
					};
					class Unit12
					{
						position[] = {-30,-30,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_Trench";
					};
				};
			};
			class ACM_Anselm_Police
			{
				name = "Police";
				class b_acmbsac_motorized_mtp_constables
				{
					name = "Constables";
					side = 1;
					faction = "ACM_B_SAC";
					icon = "\A3\ui_f\data\map\markers\nato\b_motor_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "ACM_b_sam_men_police_constable";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_police_constable";
					};
				};
				class b_acmbsac_motorized_mtp_constables_armed
				{
					name = "Constables (Armed)";
					side = 1;
					faction = "ACM_B_SAC";
					icon = "\A3\ui_f\data\map\markers\nato\b_motor_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "ACM_b_sam_men_police_constable_armor";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_police_constable_armor";
					};
				};
				class b_acmbsac_motorized_mtp_police_tactical_group
				{
					name = "Police Tactical Group";
					side = 1;
					faction = "ACM_B_SAC";
					icon = "\A3\ui_f\data\map\markers\nato\b_motor_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "ACM_b_sam_men_police_riot_shotgunner";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_police_riot_SubMachine2";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_police_riot_ArmedResponse";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_police_riot_ArmedResponse";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_police_riot_Marksman";
					};
				};
				class b_acmbsac_motorized_mtp_riot_control_group
				{
					name = "Riot Control Group";
					side = 1;
					faction = "ACM_B_SAC";
					icon = "\A3\ui_f\data\map\markers\nato\b_motor_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "ACM_b_sam_men_police_riot_shotgunner";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_police_riot_SubMachine1";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_police_riot_Grenadier";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_police_riot_Marksman";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_police_riot_ArmedResponse";
					};
					class Unit5
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_police_riot_ArmedResponse";
					};
				};
			};
			class Mechanized
			{
				name = "Mechanized Infantry";
				class b_acmbsac_mechanized_mechanized_patrol
				{
					name = "Mechanized Patrol";
					side = 1;
					faction = "ACM_B_SAC";
					icon = "\A3\ui_f\data\map\markers\nato\b_mech_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "acm_b_sog_sac_vehicle_m113";
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
						vehicle = "ACM_b_sam_men_RTO2";
					};
					class Unit5
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_HMG";
					};
					class Unit6
					{
						position[] = {-15,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_men_Medic";
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
			class Infantry
			{
				name = "Infantry";
				class b_acmbsac2035_infantry_fireteam
				{
					name = "Fireteam";
					side = 1;
					faction = "ACM_B_SAC_2035";
					icon = "\A3\ui_f\data\map\markers\nato\b_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_SL";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_rifleman";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_GR";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_MR";
					};
				};
				class b_acmbsac2035_infantry_squad
				{
					name = "Squad";
					side = 1;
					faction = "ACM_B_SAC_2035";
					icon = "\A3\ui_f\data\map\markers\nato\b_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_SL";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_rifleman_2";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_GR";
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
						vehicle = "ACM_b_sam_2035_men_rifleman_AT";
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
				};
				class b_acmbsac2035_infantry_sentry
				{
					name = "Sentry";
					side = 1;
					faction = "ACM_B_SAC_2035";
					icon = "\A3\ui_f\data\map\markers\nato\b_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_rifleman_3";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_rifleman";
					};
				};
				class b_acmbsac2035_infantry_weapons_squad
				{
					name = "Weapons Squad";
					side = 1;
					faction = "ACM_B_SAC_2035";
					icon = "\A3\ui_f\data\map\markers\nato\b_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_SL";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_rifleman_AT";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_GR";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_AR";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_HAT";
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
				};
				class b_acmbsac2035_infantry_light_anti_tank_team
				{
					name = "Light Anti-Tank Team";
					side = 1;
					faction = "ACM_B_SAC_2035";
					icon = "\A3\ui_f\data\map\markers\nato\b_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_SL";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_rifleman_AT";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_Demo";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_rifleman_AT";
					};
				};
				class b_acmbsac2035_infantry_heavy_anti_tank_team
				{
					name = "Heavy Anti-Tank Team";
					side = 1;
					faction = "ACM_B_SAC_2035";
					icon = "\A3\ui_f\data\map\markers\nato\b_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_SL";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_HAT";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_Demo";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_HAT";
					};
				};
				class b_acmbsac2035_infantry_air_defence_guard
				{
					name = "Air Defence Guard";
					side = 1;
					faction = "ACM_B_SAC_2035";
					icon = "\A3\ui_f\data\map\markers\nato\b_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_rifleman_light";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_AA";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_RTO2";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_AA";
					};
				};
				class b_acmbsac2035_infantry_explosives_team
				{
					name = "Explosives Team";
					side = 1;
					faction = "ACM_B_SAC_2035";
					icon = "\A3\ui_f\data\map\markers\nato\b_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_SL";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_EOD";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_HAT";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_Demo";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_UGV";
					};
				};
				class b_acmbsac2035_infantry_hq_group
				{
					name = "HQ Group";
					side = 1;
					faction = "ACM_B_SAC_2035";
					icon = "\A3\ui_f\data\map\markers\nato\b_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_officer";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_rifleman_light";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_officer";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_rifleman_2";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_RTO2";
					};
				};
			};
			class SpecOps
			{
				name = "Special Forces";
				class b_acmbsac2035_specops_recon_team
				{
					name = "Recon Team";
					side = 1;
					faction = "ACM_B_SAC_2035";
					icon = "\A3\ui_f\data\map\markers\nato\b_recon.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_SF_TL";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_SF_Scout";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_SF_Grenadier";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_SF_Marksman";
					};
				};
				class b_acmbsac2035_specops_recon_at_team
				{
					name = "Recon AT-Team";
					side = 1;
					faction = "ACM_B_SAC_2035";
					icon = "\A3\ui_f\data\map\markers\nato\b_recon.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_SF_TL";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_SF_Scout_AT";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_SF_Demo";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_SF_Scout_AT";
					};
				};
				class b_acmbsac2035_specops_recon_squad
				{
					name = "Recon Squad";
					side = 1;
					faction = "ACM_B_SAC_2035";
					icon = "\A3\ui_f\data\map\markers\nato\b_recon.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_SF_TL";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_SF_Scout";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_SF_Grenadier";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_SF_Marksman";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_SF_Scout_AT";
					};
					class Unit5
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_SF_Medic";
					};
					class Unit6
					{
						position[] = {-15,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_SF_Demo";
					};
					class Unit7
					{
						position[] = {20,-20,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_SF_Auto";
					};
				};
			};
			class ACM_Reserve
			{
				name = "Reserve Infantry";
				class b_acmbsac2035_reserve_citizenreserve_1
				{
					name = "Citizen's Reserve 1";
					side = 1;
					faction = "ACM_B_SAC_2035";
					icon = "\A3\ui_f\data\map\markers\nato\b_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_CR_TL";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_CR_Rifleman";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_CR_Rifleman_AT";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_CR_Rifleman_AK";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_CR_RTO";
					};
					class Unit5
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_CR_Rifleman_Garand";
					};
					class Unit6
					{
						position[] = {-15,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_CR_CLS";
					};
				};
				class b_acmbsac2035_reserve_citizenreserve_2
				{
					name = "Citizen's Reserve 2";
					side = 1;
					faction = "ACM_B_SAC_2035";
					icon = "\A3\ui_f\data\map\markers\nato\b_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_CR_TL";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_CR_AR";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_CR_Rifleman_FN49";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_CR_Rifleman_AT";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_CR_CLS";
					};
					class Unit5
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_CR_SUB";
					};
				};
				class b_acmbsac2035_reserve_ambush_group
				{
					name = "Citizen's Ambush Group";
					side = 1;
					faction = "ACM_B_SAC_2035";
					icon = "\A3\ui_f\data\map\markers\nato\b_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_CR_Rifleman_FN49";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_CR_Rifleman_AT";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_CR_Rifleman_AK";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_CR_AR";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_CR_Rifleman_AT";
					};
					class Unit5
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_CR_CLS";
					};
				};
				class b_acmbsac2035_reserve_citizensreserve_3
				{
					name = "Citizen's Reserve 3";
					side = 1;
					faction = "ACM_B_SAC_2035";
					icon = "\A3\ui_f\data\map\markers\nato\b_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_CR_TL";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_CR_MR";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_CR_Rifleman_FN49";
					};
					class Unit3
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_CR_Rifleman_AK";
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
						vehicle = "ACM_b_sam_2035_men_CR_RTO";
					};
					class Unit6
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_CR_Rifleman_SKS";
					};
				};
			};
			class Motorized
			{
				name = "Motorized Infantry";
				class b_acmbsac2035_motorized_tow_group
				{
					name = "TOW-Group";
					side = 1;
					faction = "ACM_B_SAC_2035";
					icon = "\A3\ui_f\data\map\markers\nato\b_motor_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "acm_b_sac_vehicle_m151_TOW_M";
					};
					class Unit1
					{
						position[] = {5,-7,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "acm_b_sac_vehicle_m151_TOW_M";
					};
				};
				class b_acmbsac2035_motorized_motorized_assault
				{
					name = "Motorized Assault";
					side = 1;
					faction = "ACM_B_SAC_2035";
					icon = "\A3\ui_f\data\map\markers\nato\b_motor_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "acm_b_sac_vehicle_m151_mg_M";
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
						vehicle = "ACM_b_sam_2035_men_rifleman_3";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_AR";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_RTO";
					};
				};
				class b_acmbsac2035_motorized_motorized_patrol
				{
					name = "Motorized Patrol";
					side = 1;
					faction = "ACM_B_SAC_2035";
					icon = "\A3\ui_f\data\map\markers\nato\b_motor_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "acm_b_sac_vehicle_m151_mg_patrol_M";
					};
					class Unit1
					{
						position[] = {5,-7,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "acm_b_sac_vehicle_m151_mg_patrol_M";
					};
				};
				class b_acmbsac2035_motorized_m151_armoured_section
				{
					name = "M151 Armoured Section";
					side = 1;
					faction = "ACM_B_SAC_2035";
					icon = "\A3\ui_f\data\map\markers\nato\b_motor_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "acm_b_sac_vehicle_m151_Armoured_M";
					};
					class Unit1
					{
						position[] = {5,-7,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "acm_b_sac_vehicle_m151_Armoured_M";
					};
				};
				class b_acmbsac2035_motorized_motorized_reinforcements_m52
				{
					name = "Motorized Reinforcements (M52)";
					side = 1;
					faction = "ACM_B_SAC_2035";
					icon = "\A3\ui_f\data\map\markers\nato\b_motor_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "acm_b_sac_vehicle_m54_transport_Cover_M";
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
						vehicle = "ACM_b_sam_2035_men_rifleman_3";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_rifleman_AT";
					};
					class Unit5
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_MR";
					};
					class Unit6
					{
						position[] = {-15,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_GR";
					};
					class Unit7
					{
						position[] = {20,-20,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_AR";
					};
					class Unit8
					{
						position[] = {-20,-20,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_Medic";
					};
					class Unit9
					{
						position[] = {25,-25,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_RTO2";
					};
					class Unit10
					{
						position[] = {-25,-25,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_HAT";
					};
					class Unit11
					{
						position[] = {30,-30,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_EOD";
					};
					class Unit12
					{
						position[] = {-30,-30,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_rifleman_AT";
					};
				};
			};
			class Mechanized
			{
				name = "Mechanized Infantry";
				class b_acmbsac2035_mechanized_mechanized_infantry_mora
				{
					name = "Mechanized Infantry (Mora)";
					side = 1;
					faction = "ACM_B_SAC_2035";
					icon = "\A3\ui_f\data\map\markers\nato\b_mech_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "acm_b_sac_vehicle_mora";
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
						vehicle = "ACM_b_sam_2035_men_rifleman_3";
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
						vehicle = "ACM_b_sam_2035_men_AR";
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
						vehicle = "ACM_b_sam_2035_men_Medic";
					};
					class Unit8
					{
						position[] = {-20,-20,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_HAT";
					};
				};
				class b_acmbsac2035_mechanized_mechanized_patrol
				{
					name = "Mechanized Patrol (M113)";
					side = 1;
					faction = "ACM_B_SAC";
					icon = "\A3\ui_f\data\map\markers\nato\b_mech_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "acm_b_sog_sac_vehicle_m113_M";
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
						vehicle = "ACM_b_sam_2035_men_rifleman_3";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_RTO2";
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
				};
				class b_acmbsac2035_mechanized_mechanized_assault
				{
					name = "Mechanized Assault (M113)";
					side = 1;
					faction = "ACM_B_SAC";
					icon = "\A3\ui_f\data\map\markers\nato\b_mech_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "acm_b_sog_sac_vehicle_m113_ACAV_M";
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
						vehicle = "ACM_b_sam_2035_men_rifleman_3";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_rifleman";
					};
					class Unit5
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_B_SAM_2035_Men_AR";
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
						vehicle = "ACM_b_sam_2035_men_MR";
					};
					class Unit8
					{
						position[] = {-20,-20,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_Medic";
					};
					class Unit9
					{
						position[] = {25,-25,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_HAT";
					};
					class Unit10
					{
						position[] = {-25,-25,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "ACM_b_sam_2035_men_GR";
					};
				};
			};
			class Armored
			{
				name = "Armor";
				class b_acmbsac2035_armored_tank_section
				{
					name = "Tank Section";
					side = 1;
					faction = "ACM_B_SAC_2035";
					icon = "\A3\ui_f\data\map\markers\nato\b_armor.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 1;
						vehicle = "acm_b_sac_vehicle_type63_m";
					};
					class Unit1
					{
						position[] = {8,-15,0};
						rank = "PRIVATE";
						side = 1;
						vehicle = "acm_b_sac_vehicle_type63_m";
					};
				};
			};
		};
	};
	class EAST
	{
		class ACM_O_ATIU
		{
			name = "Alcillian Territorial Integrity Units";
			class Infantry
			{
				name = "Infantry";
				class o_acmoatiu_infantry_fireteam
				{
					name = "Fireteam";
					side = 0;
					faction = "ACM_O_ATIU";
					icon = "\A3\ui_f\data\map\markers\nato\o_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "ACM_o_alci_men_rifleman";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_rifleman_AT";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_Marksman";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_grenadier";
					};
				};
				class o_acmoatiu_infantry_squad
				{
					name = "Squad";
					side = 0;
					faction = "ACM_O_ATIU";
					icon = "\A3\ui_f\data\map\markers\nato\o_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "ACM_o_alci_men_SL";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_rifleman";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_Medic";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_Marksman";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_RTO2";
					};
					class Unit5
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_MG";
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
						vehicle = "ACM_o_alci_men_rifleman_AT";
					};
				};
				class o_acmoatiu_infantry_sentry
				{
					name = "Sentry";
					side = 0;
					faction = "ACM_O_ATIU";
					icon = "\A3\ui_f\data\map\markers\nato\o_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "ACM_o_alci_men_rifleman_2";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_rifleman";
					};
				};
				class o_acmoatiu_infantry_machine_gun_team
				{
					name = "Machine Gun Team";
					side = 0;
					faction = "ACM_O_ATIU";
					icon = "\A3\ui_f\data\map\markers\nato\o_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "ACM_o_alci_men_SL";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_RTO";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_MG";
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
						vehicle = "ACM_o_alci_men_MG";
					};
					class Unit5
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_rifleman";
					};
				};
				class o_acmoatiu_infantry_assault_squad
				{
					name = "Assault Squad";
					side = 0;
					faction = "ACM_O_ATIU";
					icon = "\A3\ui_f\data\map\markers\nato\o_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "ACM_o_alci_men_SL";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_rifleman_AT";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_MG";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_Medic";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_Marksman";
					};
					class Unit5
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_RTO2";
					};
					class Unit6
					{
						position[] = {-15,-15,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_Demo";
					};
					class Unit7
					{
						position[] = {20,-20,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_Trench";
					};
				};
				class o_acmoatiu_infantry_anti_armour_team
				{
					name = "Anti-Armour team";
					side = 0;
					faction = "ACM_O_ATIU";
					icon = "\A3\ui_f\data\map\markers\nato\o_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "ACM_o_alci_men_SL";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_Demo";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_grenadier";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_rifleman_AT";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_rifleman_AT";
					};
					class Unit5
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_rifleman_AT";
					};
				};
				class o_acmoatiu_infantry_coast_guard_group
				{
					name = "Coast Guard Group";
					side = 0;
					faction = "ACM_O_ATIU";
					icon = "\A3\ui_f\data\map\markers\nato\o_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "ACM_o_alci_men_cg";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_cg2";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_cg";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_cg2";
					};
				};
				class o_acmoatiu_infantry_hq_team
				{
					name = "HQ Team";
					side = 0;
					faction = "ACM_O_ATIU";
					icon = "\A3\ui_f\data\map\markers\nato\o_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "ACM_o_alci_men_officer";
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
						vehicle = "ACM_o_alci_men_officer";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_rifleman_AT";
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
						vehicle = "ACM_o_alci_men_RTO2";
					};
				};
			};
			class SpecOps
			{
				name = "Special Forces";
				class o_acmoatiu_specops_recon_team
				{
					name = "Recon Team";
					side = 0;
					faction = "ACM_O_ATIU";
					icon = "\A3\ui_f\data\map\markers\nato\o_recon.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "ACM_o_alci_men_SF_TL";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_SF_Scout";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_SF_CLS";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_SF_Demo";
					};
				};
				class o_acmoatiu_specops_recon_squad
				{
					name = "Recon Squad";
					side = 0;
					faction = "ACM_O_ATIU";
					icon = "\A3\ui_f\data\map\markers\nato\o_recon.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "ACM_o_alci_men_SF_TL";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_SF_Scout";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_SF_AR";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_SF_CLS";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_SF_GR";
					};
					class Unit5
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_SF_Demo";
					};
					class Unit6
					{
						position[] = {-15,-15,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_SF_MR";
					};
				};
				class o_acmoatiu_specops_infiltration_group
				{
					name = "Infiltration Group";
					side = 0;
					faction = "ACM_O_ATIU";
					icon = "\A3\ui_f\data\map\markers\nato\o_recon.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "ACM_o_alci_men_SF_NF";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_SF_Scout";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_SF_Demo";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_SF_NF";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_SF_CLS";
					};
				};
			};
			class Motorized
			{
				name = "Motorized Infantry";
				class o_acmoatiu_motorized_motorized_assault
				{
					name = "Motorized Assault";
					side = 0;
					faction = "ACM_O_ATIU";
					icon = "\A3\ui_f\data\map\markers\nato\o_motor_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "acm_o_alci_vehicle_m151_mg";
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
						vehicle = "ACM_o_alci_men_rifleman";
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
						vehicle = "ACM_o_alci_men_RTO";
					};
					class Unit5
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_Medic";
					};
					class Unit6
					{
						position[] = {-15,-15,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_Marksman";
					};
					class Unit7
					{
						position[] = {20,-20,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_grenadier";
					};
					class Unit8
					{
						position[] = {-20,-20,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_rifleman_AT";
					};
				};
				class o_acmoatiu_motorized_motorized_patrol
				{
					name = "Motorized Patrol";
					side = 0;
					faction = "ACM_O_ATIU";
					icon = "\A3\ui_f\data\map\markers\nato\o_motor_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "acm_o_alci_vehicle_m151";
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
						vehicle = "ACM_o_alci_men_rifleman_2";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_RTO2";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_Medic";
					};
				};
				class o_acmoatiu_motorized_tow_group
				{
					name = "TOW-Group";
					side = 0;
					faction = "ACM_O_ATIU";
					icon = "\A3\ui_f\data\map\markers\nato\o_motor_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "acm_o_alci_vehicle_m151_TOW";
					};
					class Unit1
					{
						position[] = {5,-7,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "acm_o_alci_vehicle_m151_TOW";
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
				class o_acmoatiu_motorized_motorized_reinforcements_z157
				{
					name = "Motorized Reinforcements (Z-157)";
					side = 0;
					faction = "ACM_O_ATIU";
					icon = "\A3\ui_f\data\map\markers\nato\o_motor_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "acm_o_alci_vehicle_z157_transport_cover";
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
						vehicle = "ACM_o_alci_men_rifleman";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_rifleman_3";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_rifleman_AT";
					};
					class Unit5
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_RTO2";
					};
					class Unit6
					{
						position[] = {-15,-15,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_MG";
					};
					class Unit7
					{
						position[] = {20,-20,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_Medic";
					};
					class Unit8
					{
						position[] = {-20,-20,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_Marksman";
					};
					class Unit9
					{
						position[] = {25,-25,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_Trench";
					};
					class Unit10
					{
						position[] = {-25,-25,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_grenadier";
					};
					class Unit11
					{
						position[] = {30,-30,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_KneeMortar";
					};
					class Unit12
					{
						position[] = {-30,-30,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_rifleman_2";
					};
				};
			};
			class Mechanized
			{
				name = "Mechanized Infantry";
				class o_acmoatiu_mechanized_mechanized_patrol
				{
					name = "Mechanized Patrol";
					side = 0;
					faction = "ACM_O_ATIU";
					icon = "\A3\ui_f\data\map\markers\nato\o_mech_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "acm_o_sog_alc_vehicle_m113";
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
						vehicle = "ACM_o_alci_men_rifleman_AT";
					};
					class Unit3
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_rifleman";
					};
					class Unit4
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_MG";
					};
					class Unit5
					{
						position[] = {-15,-15,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_RTO2";
					};
					class Unit6
					{
						position[] = {20,-20,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_Medic";
					};
				};
				class o_acmoatiu_mechanized_mechanized_assault
				{
					name = "Mechanized Assault (M113)";
					side = 0;
					faction = "ACM_O_ATIU";
					icon = "\A3\ui_f\data\map\markers\nato\o_mech_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "acm_o_sog_alc_vehicle_m113_ACAV";
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
						vehicle = "ACM_o_alci_men_rifleman_AT";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_RTO";
					};
					class Unit5
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_MG";
					};
					class Unit6
					{
						position[] = {-15,-15,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_Marksman";
					};
					class Unit7
					{
						position[] = {20,-20,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_Medic";
					};
					class Unit8
					{
						position[] = {-20,-20,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_KneeMortar";
					};
					class Unit9
					{
						position[] = {25,-25,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_grenadier";
					};
					class Unit10
					{
						position[] = {-25,-25,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_men_Demo";
					};
				};
			};
		};
		class ACM_O_ATIU_2035
		{
			name = "Alcillian Territorial Integrity Units (2035)";
			class Infantry
			{
				name = "Infantry";
				class o_acmoatiu2035_infantry_fireteam
				{
					name = "Fireteam";
					side = 0;
					faction = "ACM_O_ATIU_2035";
					icon = "\A3\ui_f\data\map\markers\nato\o_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_SL";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_rifleman";
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
						vehicle = "ACM_o_alci_2035_men_marksman";
					};
				};
				class o_acmoatiu2035_infantry_squad
				{
					name = "Squad";
					side = 0;
					faction = "ACM_O_ATIU_2035";
					icon = "\A3\ui_f\data\map\markers\nato\o_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_SL";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_rifleman_AT";
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
						vehicle = "ACM_o_alci_2035_men_marksman";
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
						vehicle = "ACM_o_alci_2035_men_MG";
					};
					class Unit6
					{
						position[] = {-15,-15,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_rifleman";
					};
					class Unit7
					{
						position[] = {20,-20,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_Medic";
					};
				};
				class o_acmoatiu2035_infantry_anti_tank_team
				{
					name = "Anti-Tank Team";
					side = 0;
					faction = "ACM_O_ATIU_2035";
					icon = "\A3\ui_f\data\map\markers\nato\o_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_SL";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_rifleman_2";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_AT";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_Sapper";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_AT";
					};
					class Unit5
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_rifleman_AT";
					};
				};
				class o_acmoatiu2035_infantry_air_denial_group
				{
					name = "Air Denial Group";
					side = 0;
					faction = "ACM_O_ATIU_2035";
					icon = "\A3\ui_f\data\map\markers\nato\o_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_rifleman_light";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_AA";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_RTO";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_AA";
					};
				};
				class o_acmoatiu2035_infantry_machine_gun_team
				{
					name = "Machine Gun Team";
					side = 0;
					faction = "ACM_O_ATIU_2035";
					icon = "\A3\ui_f\data\map\markers\nato\o_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_SL";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_grenadier";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_MG";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_marksman";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_MG";
					};
					class Unit5
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_RTO";
					};
				};
				class o_acmoatiu2035_infantry_sentry
				{
					name = "Sentry";
					side = 0;
					faction = "ACM_O_ATIU_2035";
					icon = "\A3\ui_f\data\map\markers\nato\o_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_rifleman_light";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_rifleman_2";
					};
				};
				class o_acmoatiu2035_infantry_combat_sappers
				{
					name = "Combat Sappers";
					side = 0;
					faction = "ACM_O_ATIU_2035";
					icon = "\A3\ui_f\data\map\markers\nato\o_support.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_SL";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_Sapper";
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
						vehicle = "ACM_o_alci_2035_men_Sapper";
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
						vehicle = "ACM_o_alci_2035_men_RTO";
					};
				};
				class o_acmoatiu2035_infantry_hq_group
				{
					name = "HQ Group";
					side = 0;
					faction = "ACM_O_ATIU_2035";
					icon = "\A3\ui_f\data\map\markers\nato\o_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_Officer";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_rifleman_2";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_Officer";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_RTO";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_rifleman_light";
					};
				};
			};
			class SpecOps
			{
				name = "Special Forces";
				class o_acmoatiu2035_specops_recon_team
				{
					name = "Recon Team";
					side = 0;
					faction = "ACM_O_ATIU_2035";
					icon = "\A3\ui_f\data\map\markers\nato\o_recon.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "ACM_o_alci_2035_SF_SL";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_SF_Scout";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_SF_Grenadier";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_SF_MR";
					};
				};
				class o_acmoatiu2035_specops_recon_ambush_group
				{
					name = "Recon Ambush Group";
					side = 0;
					faction = "ACM_O_ATIU_2035";
					icon = "\A3\ui_f\data\map\markers\nato\o_recon.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "ACM_o_alci_2035_SF_SL";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_SF_Scout_AT";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_SF_Grenadier";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_SF_Demo";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_SF_AR";
					};
				};
				class o_acmoatiu2035_specops_recon_squad
				{
					name = "Recon Squad";
					side = 0;
					faction = "ACM_O_ATIU_2035";
					icon = "\A3\ui_f\data\map\markers\nato\o_recon.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "ACM_o_alci_2035_SF_SL";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_SF_Scout_AT";
					};
					class Unit2
					{
						position[] = {-5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_SF_Grenadier";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_SF_MR";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_SF_Scout";
					};
					class Unit5
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_SF_AR";
					};
					class Unit6
					{
						position[] = {-15,-15,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_SF_Demo";
					};
					class Unit7
					{
						position[] = {20,-20,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_SF_CLS";
					};
				};
			};
			class Motorized
			{
				name = "Motorized Infantry";
				class o_acmoatiu2035_motorized_motorized_assault
				{
					name = "Motorized Assault";
					side = 0;
					faction = "ACM_O_ATIU_2035";
					icon = "\A3\ui_f\data\map\markers\nato\o_motor_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "acm_o_alci_vehicle_m151_M";
					};
					class Unit1
					{
						position[] = {5,-5,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_rifleman";
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
						vehicle = "ACM_o_alci_2035_men_RTO";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_grenadier";
					};
				};
				class o_acmoatiu2035_motorized_pathfinders
				{
					name = "Pathfinders";
					side = 0;
					faction = "ACM_O_ATIU_2035";
					icon = "\A3\ui_f\data\map\markers\nato\o_motor_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "acm_o_alci_vehicle_m151_mg_M";
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
						vehicle = "ACM_o_alci_2035_men_rifleman_3";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_RTO";
					};
				};
				class o_acmoatiu2035_motorized_tow_group
				{
					name = "TOW-Group";
					side = 0;
					faction = "ACM_O_ATIU_2035";
					icon = "\A3\ui_f\data\map\markers\nato\o_motor_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "acm_o_alci_vehicle_m151_TOW_M";
					};
					class Unit1
					{
						position[] = {5,-7,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "acm_o_alci_vehicle_m151_TOW_M";
					};
				};
				class o_acmoatiu2035_motorized_m151_armoured_section
				{
					name = "M151 Armoured Section";
					side = 0;
					faction = "ACM_O_ATIU_2035";
					icon = "\A3\ui_f\data\map\markers\nato\o_motor_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "acm_o_alci_vehicle_m151_Armoured_M";
					};
					class Unit1
					{
						position[] = {5,-7,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "acm_o_alci_vehicle_m151_Armoured_M";
					};
				};
				class o_acmoatiu2035_motorized_motorized_reinforcements_z157
				{
					name = "Motorized Reinforcements (Z-157)";
					side = 0;
					faction = "ACM_O_ATIU_2035";
					icon = "\A3\ui_f\data\map\markers\nato\o_motor_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "acm_o_alci_vehicle_z157_transport_cover_M";
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
						vehicle = "ACM_o_alci_2035_men_rifleman_3";
					};
					class Unit4
					{
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_rifleman_AT";
					};
					class Unit5
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_grenadier";
					};
					class Unit6
					{
						position[] = {-15,-15,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_marksman";
					};
					class Unit7
					{
						position[] = {20,-20,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_AT";
					};
					class Unit8
					{
						position[] = {-20,-20,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_MG";
					};
					class Unit9
					{
						position[] = {25,-25,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_Medic";
					};
					class Unit10
					{
						position[] = {-25,-25,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_RTO";
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
						vehicle = "ACM_o_alci_2035_men_Sapper";
					};
				};
			};
			class Mechanized
			{
				name = "Mechanized Infantry";
				class o_acmoatiu2035_mechanized_mechanized_patrol
				{
					name = "Mechanized Patrol (M113)";
					side = 0;
					faction = "ACM_O_ATIU_2035";
					icon = "\A3\ui_f\data\map\markers\nato\o_mech_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "acm_o_sog_alc_vehicle_m113_M";
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
						position[] = {-10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_rifleman";
					};
					class Unit4
					{
						position[] = {15,-15,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_MG";
					};
					class Unit5
					{
						position[] = {-15,-15,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_RTO";
					};
					class Unit6
					{
						position[] = {20,-20,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_Medic";
					};
				};
				class o_acmoatiu2035_mechanized_mechanized_assault
				{
					name = "Mechanized Assault (M113)";
					side = 0;
					faction = "ACM_O_ATIU_2035";
					icon = "\A3\ui_f\data\map\markers\nato\o_mech_inf.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "acm_o_sog_alc_vehicle_m113_ACAV_M";
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
						vehicle = "ACM_o_alci_2035_men_rifleman_3";
					};
					class Unit3
					{
						position[] = {10,-10,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_rifleman_AT";
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
						vehicle = "ACM_o_alci_2035_men_MG";
					};
					class Unit6
					{
						position[] = {-15,-15,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_Marksman";
					};
					class Unit7
					{
						position[] = {20,-20,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_Medic";
					};
					class Unit8
					{
						position[] = {-20,-20,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_AT";
					};
					class Unit9
					{
						position[] = {25,-25,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_grenadier";
					};
					class Unit10
					{
						position[] = {-25,-25,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "ACM_o_alci_2035_men_Sapper";
					};
				};
			};
			class Armored
			{
				name = "Armor";
				class o_acmoatiu2035_armored_tank_section
				{
					name = "Tank Section";
					side = 0;
					faction = "ACM_O_ATIU_2035";
					icon = "\A3\ui_f\data\map\markers\nato\o_armor.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "acm_o_alci_vehicle_type63_m";
					};
					class Unit1
					{
						position[] = {8,-15,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "acm_o_alci_vehicle_type63_m";
					};
				};
				class o_acmoatiu2035_armored_tank_platoon
				{
					name = "Tank Platoon";
					side = 0;
					faction = "ACM_O_ATIU_2035";
					icon = "\A3\ui_f\data\map\markers\nato\o_armor.paa";
					rarityGroup = 0.5;
					class Unit0
					{
						position[] = {0,0,0};
						rank = "SERGEANT";
						side = 0;
						vehicle = "acm_o_alci_vehicle_type63_m";
					};
					class Unit1
					{
						position[] = {8,-15,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "acm_o_alci_vehicle_type63_m";
					};
					class Unit2
					{
						position[] = {-8,-15,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "acm_o_alci_vehicle_type63_m";
					};
					class Unit3
					{
						position[] = {16,-23,0};
						rank = "PRIVATE";
						side = 0;
						vehicle = "acm_o_alci_vehicle_type63_m";
					};
				};
			};
		};
	};
};
class CfgMarkers
{
	class flag_NATO;
	class Marker_ACM_SAC_Flag: flag_NATO
	{
		name = "Flag (Saint Anselm)";
		icon = "\acm_saintanselm\faction\flag_anselm_ico_co.paa";
		texture = "\acm_saintanselm\faction\flag_anselm_ico_co.paa";
	};
	class Marker_ACM_ALC_Flag: flag_NATO
	{
		name = "Flag (Alcillo)";
		icon = "\acm_saintanselm\faction\flag_Alcillo_ico_co.paa";
		texture = "\acm_saintanselm\faction\flag_Alcillo_ico_co.paa";
	};
};
class cfgMods
{
	author = "Anthrax";
	timepacked = "1689706685";
};
