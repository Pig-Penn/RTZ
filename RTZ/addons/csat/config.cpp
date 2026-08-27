#include "script_component.hpp"

// Asset component: the CSAT (Pacific) Zubr-class LCAC, ported out of CUP Vehicles.

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {"RTZ_O_Zubr_CSAT_T"};
        weapons[] = {"RTZ_Vacannon_AK630_veh", "RTZ_Vacannon_AK630_1_veh", "RTZ_Vacannon_AK630_2_veh", "RTZ_Vmlauncher_OGON_veh"};
        magazines[] = {"RTZ_2000Rnd_30mm_AK630_M", "RTZ_44Rnd_Ogon_HE"};
        ammo[] = {"RTZ_B_30mm_AK630_Red_Tracer", "RTZ_R_140mm_Ogon_HE"};
        requiredVersion = REQUIRED_VERSION;
        // No CUP dependency: every asset the Zubr reaches for is either in this
        // PBO or in vanilla Arma. A3_Anims_F carries the CfgMovesMaleSdr states
        // the ripped cargo pose inherits from.
        requiredAddons[] = {"rtz_main", "A3_Boat_F", "A3_Weapons_F", "A3_Anims_F"};
        author = "Maxim";
        authors[] = {"Maxim"};
        url = "";
        VERSION_CONFIG;
    };
};

#include "CfgFunctions.hpp"
#include "CfgMoves.hpp"
#include "CfgAmmo.hpp"
#include "CfgMagazines.hpp"
#include "CfgWeapons.hpp"
#include "CfgVehicles.hpp"
