// Ripped from CUP Weapons 1.19.2 (cup_weapons_vehicleweapons.pbo).
// Renamed onto the RTZ_ prefix so this addon never collides with CUP
// when both are loaded. Values are CUP's, unchanged.

class CfgWeapons {
    class CannonCore;
    class RocketPods;

class RTZ_Vacannon_AK630_veh: CannonCore
{
	author = "$STR_RTZ_CSAT_author";
	scope = 1;
	displayName = "AK-630";
	nameSound = "cannon";
	cursor = "EmptyCursor";
	cursorAim = "EmptyCursor";
	cursorSize = 1;
	magazines[] = {"RTZ_2000Rnd_30mm_AK630_M"};
	canLock = 2;
	ballisticsComputer = 1;
	modes[] = {"Manual","close","short","medium","far"};
	class Manual: CannonCore
	{
		displayName = "AK-630";
		autoFire = 1;
		sounds[] = {"StandardSound"};
		class StandardSound
		{
			weaponSoundEffect = "DefaultRifle";
			begin1[] = {"x\rtz\addons\csat\sound\GAU8_05sec_burst.wss",7,1,1800};
			soundBegin[] = {"begin1",1};
		};
		reloadTime = 0.03;
		dispersion = 0.007;
		soundContinuous = 0;
		showToPlayer = 1;
		burst = 1;
		aiRateOfFire = 0.5;
		aiRateOfFireDistance = 50;
		minRange = 1;
		minRangeProbab = 0.01;
		midRange = 2;
		midRangeProbab = 0.01;
		maxRange = 3;
		maxRangeProbab = 0.01;
		textureType = "fullAuto";
	};
	class Close: Manual
	{
		showToPlayer = 0;
		soundBurst = 0;
		burst = 15;
		aiRateOfFire = 0.5;
		aiRateOfFireDistance = 400;
		minRange = 0;
		minRangeProbab = 0.05;
		midRange = 200;
		midRangeProbab = 0.58;
		maxRange = 400;
		maxRangeProbab = 0.2;
	};
	class short: Close
	{
		burst = 10;
		aiRateOfFire = 1;
		aiRateOfFireDistance = 500;
		minRange = 300;
		minRangeProbab = 0.2;
		midRange = 400;
		midRangeProbab = 0.58;
		maxRange = 500;
		maxRangeProbab = 0.2;
	};
	class medium: Close
	{
		burst = 7;
		aiRateOfFire = 2;
		aiRateOfFireDistance = 9000;
		minRange = 400;
		minRangeProbab = 0.2;
		midRange = 700;
		midRangeProbab = 0.58;
		maxRange = 900;
		maxRangeProbab = 0.2;
	};
	class Far: Close
	{
		burst = 4;
		aiRateOfFire = 3;
		aiRateOfFireDistance = 1500;
		minRange = 800;
		minRangeProbab = 0.2;
		midRange = 1000;
		midRangeProbab = 0.4;
		maxRange = 1500;
		maxRangeProbab = 0.01;
	};
};

class RTZ_Vacannon_AK630_1_veh: RTZ_Vacannon_AK630_veh
{
	class GunParticles
	{
		class FirstEffect
		{
			directionName = "gun_1_end";
			effectName = "MachineGun2";
			positionName = "gun_1_beg";
		};
	};
};

class RTZ_Vacannon_AK630_2_veh: RTZ_Vacannon_AK630_veh
{
	class GunParticles
	{
		class FirstEffect
		{
			directionName = "gun_2_end";
			effectName = "MachineGun2";
			positionName = "gun_2_beg";
		};
	};
};

class RTZ_Vmlauncher_OGON_veh: RocketPods
{
	author = "$STR_RTZ_CSAT_author";
	scope = 1;
	displayName = "$STR_RTZ_CSAT_wpn_Ogon";
	magazines[] = {"RTZ_44Rnd_Ogon_HE"};
	magazineReloadTime = 30;
	modes[] = {"fire_4000","fire_3000","fire_2000","fire_1000"};
	cursor = "EmptyCursor";
	cursorAim = "EmptyCursor";
	canLock = 0;
	ballisticsComputer = 0;
	class fire_4000: RocketPods
	{
		minRange = 50;
		minRangeProbab = 0.041;
		midRange = 600;
		midRangeProbab = 0.21;
		maxRange = 2500;
		maxRangeProbab = 0.11;
		aiRateOfFire = 0.8;
		aiRateOfFireDistance = 2500;
		displayName = "$STR_RTZ_CSAT_wpn_Ogon_4000";
		burst = 1;
		reloadTime = 0.2;
		autoFire = 1;
		showToPlayer = 1;
		dispersion = 0.04;
		soundBurst = 0;
		sounds[] = {"StandardSound"};
		class StandardSound
		{
			begin1[] = {"A3\Sounds_F\weapons\Rockets\Titan_2.wss",1.77828,1,1500};
			soundBegin[] = {"begin1",1};
		};
		textureType = "fullAuto";
	};
	class fire_3000: fire_4000
	{
		minRange = 50;
		minRangeProbab = 0.041;
		midRange = 600;
		midRangeProbab = 0.21;
		maxRange = 2500;
		maxRangeProbab = 0.11;
		aiRateOfFire = 0.8;
		aiRateOfFireDistance = 2500;
		displayName = "$STR_RTZ_CSAT_wpn_Ogon_3000";
		textureType = "burst";
	};
	class fire_2000: fire_4000
	{
		minRange = 50;
		minRangeProbab = 0.041;
		midRange = 600;
		midRangeProbab = 0.21;
		maxRange = 2500;
		maxRangeProbab = 0.11;
		aiRateOfFire = 0.8;
		aiRateOfFireDistance = 2500;
		displayName = "$STR_RTZ_CSAT_wpn_Ogon_2000";
		textureType = "dual";
	};
	class fire_1000: fire_4000
	{
		minRange = 50;
		minRangeProbab = 0.041;
		midRange = 600;
		midRangeProbab = 0.21;
		maxRange = 2500;
		maxRangeProbab = 0.11;
		aiRateOfFire = 0.8;
		aiRateOfFireDistance = 2500;
		displayName = "$STR_RTZ_CSAT_wpn_Ogon_1000";
		textureType = "semi";
	};
};
};
