// Cargo pose for the Zubr's well deck, ripped from cup_watervehicles_rhib.pbo
// (CUP_RHIB_Cargo / CUP_KIA_RHIB_Cargo). The Zubr's cargoAction[] points at it,
// so without these two states passengers fall back to a generic sitting pose.
// The .rtm files live in this PBO under anim\.

class CfgMovesBasic {
    class DefaultDie;
    class ManActions {
        RTZ_Zubr_Cargo = "RTZ_Zubr_Cargo";
    };
};

class CfgMovesMaleSdr: CfgMovesBasic {
    class States {
        class Crew;

        class RTZ_KIA_Zubr_Cargo: DefaultDie {
            file = "\x\rtz\addons\csat\anim\KIA_RHIB_Cargo.rtm";
            actions = "DeadActions";
            speed = 0.5;
            looped = 0;
            terminal = 1;
            connectTo[] = {"Unconscious", 0.1};
            leftHandIKCurve[] = {1};
            rightHandIKCurve[] = {1};
        };

        class RTZ_Zubr_Cargo: Crew {
            file = "\x\rtz\addons\csat\anim\RHIB_Cargo.rtm";
            interpolateTo[] = {"RTZ_KIA_Zubr_Cargo", 1};
            leftHandIKCurve[] = {1};
            rightHandIKCurve[] = {1};
        };
    };
};
