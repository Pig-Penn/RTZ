// Ripped from CUP Weapons 1.19.2 (cup_weapons_ammunition.pbo).
// Renamed onto the RTZ_ prefix so this addon never collides with CUP
// when both are loaded. Values are CUP's, unchanged.

class CfgAmmo {
    class BulletBase;
    class RocketBase;

class RTZ_B_30mm_CAS_Red_Tracer: BulletBase
{
	SoundSetExplosion[] = {"Shell30mm40mm_Exp_SoundSet","Shell30mm40mm_Tail_SoundSet","Explosion_Debris_SoundSet"};
	hit = 90;
	indirectHit = 9;
	indirectHitRange = 4;
	warheadName = "AP";
	explosive = 0.1;
	caliber = 2.5;
	cost = 20;
	model = "\a3\weapons_f\data\bullettracer\tracer_red.p3d";
	tracerScale = 2.5;
	tracerStartTime = 0.1;
	tracerEndTime = 4;
	nvgOnly = 0;
	typicalSpeed = 1030;
	visibleFire = 32;
	audibleFire = 32;
	visibleFireTime = 4;
	soundHit1[] = {"A3\Sounds_F\weapons\Explosion\gr_explosion_1.wss",3.1622777,1,1800};
	soundHit2[] = {"A3\Sounds_F\weapons\Explosion\gr_explosion_2.wss",3.1622777,1,1800};
	soundHit3[] = {"A3\Sounds_F\weapons\Explosion\gr_explosion_3.wss",3.1622777,1,1800};
	soundHit4[] = {"A3\Sounds_F\weapons\Explosion\gr_explosion_4.wss",3.1622777,1,1800};
	soundHit5[] = {"A3\Sounds_F\weapons\Explosion\gr_explosion_5.wss",3.1622777,1,1800};
	soundHit6[] = {"A3\Sounds_F\weapons\Explosion\gr_explosion_6.wss",3.1622777,1,1800};
	multiSoundHit[] = {"soundHit1",0.2,"soundHit2",0.2,"soundHit3",0.2,"soundHit4",0.1,"soundHit5",0.15,"soundHit6",0.15};
	explosionSoundEffect = "DefaultExplosion";
	CraterEffects = "ExploAmmoCrater";
	explosionEffects = "ExploAmmoExplosion";
	airFriction = -0.00076;
	muzzleEffect = "";
	class CamShakeExplode
	{
		power = (25 * 0.2);
		duration = "((round (25^0.5))*0.2 max 0.2)";
		frequency = 20;
		distance = ((2 + 25^0.5)*8);
	};
	class CamShakeHit
	{
		power = 25;
		duration = "((round (25^0.25))*0.2 max 0.2)";
		frequency = 20;
		distance = 1;
	};
	class CamShakeFire
	{
		power = "(25^0.25)";
		duration = "((round (25^0.5))*0.2 max 0.2)";
		frequency = 20;
		distance = ((25^0.5)*8);
	};
	class CamShakePlayerFire
	{
		power = 0.01;
		duration = 0.1;
		frequency = 20;
		distance = 1;
	};
};

class RTZ_B_30mm_AK630_Red_Tracer: RTZ_B_30mm_CAS_Red_Tracer
{
	timeToLive = 15;
	visibleFireTime = 15;
	tracerEndTime = 15;
};

class RTZ_R_140mm_Ogon_HE: RocketBase
{
	SoundSetExplosion[] = {"RocketsHeavy_Exp_SoundSet","RocketsHeavy_Tail_SoundSet","Explosion_Debris_SoundSet"};
	model = "\A3\Weapons_F\Ammo\Rocket_02_fly_F.p3d";
	hit = 650;
	indirectHit = 400;
	indirectHitRange = 20;
	warheadName = "HE";
	cost = 200;
	maxSpeed = 300;
	thrustTime = 1;
	thrust = 370;
	sideAirFriction = 0.0;
	airFriction = 0.1;
	timeToLive = 120;
	fuseDistance = 40;
	soundFly[] = {"A3\Sounds_F\weapons\Rockets\rocket_fly_1.wss",6,1,500};
	whistleDist = 100;
};
};
