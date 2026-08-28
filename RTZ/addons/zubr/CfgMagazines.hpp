// Ripped from CUP Weapons 1.19.2 (cup_weapons_ammunition.pbo).
// Renamed onto the RTZ_ prefix so this addon never collides with CUP
// when both are loaded. Values are CUP's, unchanged.

class CfgMagazines {
    class VehicleMagazine;
    class 24Rnd_missiles;

    class RTZ_2000Rnd_30mm_AK630_M: VehicleMagazine
    {
        scope = 2;
        displayName = "2000Rnd AK630 Mag";
        ammo = "RTZ_B_30mm_AK630_Red_Tracer";
        count = 2000;
        initSpeed = 900;
        maxLeadSpeed = 600;
        tracersEvery = 1;
        nameSound = "cannon";
    };

    class RTZ_44Rnd_Ogon_HE: 24Rnd_missiles
    {
        displayName = "$STR_RTZ_Zubr_mag_Ogon_HE";
        ammo = "RTZ_R_140mm_Ogon_HE";
        displayNameShort = "$STR_A3_CFGMAGAZINES_250RND_30MM_HE_SHELLS_DNS";
        count = 44;
        initSpeed = 0;
        maxLeadSpeed = 40;
        nameSound = "rockets";
    };
};
