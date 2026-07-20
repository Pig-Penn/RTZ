class RscText;

class zen_common_RscDisplay {
    class controls;
};

// Merged into ZEN's attribute window display (zen_common gui.hpp). ZEN's
// functions are compiled final by CBA, so zen_attributes_fnc_open cannot be
// wrapped by reassignment — instead this invisible control rides along in the
// display and its onLoad schedules the visual lock. One frame of delay lets
// zen_attributes_fnc_open finish building the rows and storing them on the
// display (onLoad fires during createDialog, before any row exists).
//
// Both inheritance links must be restated: patching a class without naming its
// parent severs the link, which would drop idd/movingEnable/onLoad (ZEN keeps
// them on zen_common_RscDisplay) and the inherited Title/Background/Content.
class zen_common_RscDisplayScrollbars: zen_common_RscDisplay {
    class controls: controls {
        class GVAR(lockHook): RscText {
            idc = -1;
            x = 0;
            y = 0;
            w = 0;
            h = 0;
            onLoad = QUOTE([ARR_2(FUNC(lockControls),ctrlParent (_this select 0))] call CBA_fnc_execNextFrame);
        };
    };
};
