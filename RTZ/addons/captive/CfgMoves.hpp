// The prisoner pose: hands bound behind the back, as distinct from the hands-up
// surrender the unit was in a moment earlier. There is no vanilla animation
// STATE for this — only the animation FILE, which BI ships for the campaign's
// captive scenes and never binds to a usable state on CAManBase — so the state
// has to be declared here. ACE's ace_captives does the identical thing with the
// identical file; this is deliberately not that class, because ACE is a
// reference for RTZ and not a dependency (see the component's requiredAddons),
// and a prisoner must look like a prisoner on a server running ZEN alone.
//
// One looped state, no enter/exit transition pair. The transitions would only
// pay off entering from a relaxed stand, and a prisoner never arrives from one:
// he is taken while already frozen in the surrender pose, which no vanilla
// ConnectTo chain reaches this from anyway. FUNC(captureApply) forces the switch
// with playMoveNow, and a single static state cannot leave him stranded
// mid-transition — the failure a non-looped enter state invites when the unit
// holding it has disableAI "ANIM" set.

class CfgMovesBasic {
    class Actions {
        class CivilStandActions;
        // Belt-and-braces against the engine: a captured unit already has MOVE,
        // TARGET and ANIM disabled, but if any of that is ever lifted the action
        // set is what stops him turning on the spot or reaching for gear while
        // still visibly bound.
        class GVAR(capturedActions): CivilStandActions {
            turnL = "";
            turnR = "";
            stop = QGVAR(animcaptured);
            StopRelaxed = QGVAR(animcaptured);
            default = QGVAR(animcaptured);
            PutDown = "";
            getOver = "";
            throwPrepare = "";
            throwGrenade[] = {"", "Gesture"};
        };
    };
};

class CfgMovesMaleSdr: CfgMovesBasic {
    class States {
        class CutSceneAnimationBase;

        // Lowercase class name on purpose, and the one place in this component
        // where that matters: animationState returns the state lowercased, so
        // naming it this way lets ANIM_CAPTURED_STATE be the same QGVAR the
        // config declares rather than a hand-written "rtz_captive_..." literal.
        //
        // speed = 0 freezes the clip on its first frame — the pose, held
        // indefinitely, with no per-frame cost and nothing to re-play.
        class GVAR(animcaptured): CutSceneAnimationBase {
            actions = QGVAR(capturedActions);
            file = "\A3\anims_f\Data\Anim\Sdr\mov\erc\stp\non\non\AmovPercMstpSnonWnonDnon_Ease";
            speed = 0;
            looped = 1;
            interpolationRestart = 2;
            canReload = 0;
            ConnectTo[] = {};
            // Unconscious only: a prisoner who goes down must ragdoll out of the
            // pose rather than stay standing bound while incapacitated.
            InterpolateTo[] = {"Unconscious", 0.01};
            head = "headDefault";
            aimingBody = "aimingNo";
            forceAim = 1;
            static = 1;
        };
    };
};
