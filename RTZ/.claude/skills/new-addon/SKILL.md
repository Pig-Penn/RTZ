---
name: new-addon
description: Scaffold a new RTZ component under addons/ with the full CBA skeleton (config.cpp, script_component.hpp, XEH files, functions dir, settings, stringtable). Use when adding a new feature component to Real-Time Zeus. Argument = the component name (lowercase snake_case, e.g. "suppress").
---

# New RTZ Addon Component

Scaffold a new component `addons/<name>/` matching the existing RTZ skeleton. `<name>` is lowercase snake_case; `<Name>` is the beautified form (e.g. `unit_info` → `Unit Info` for display, `UnitInfo` where an identifier is needed, `UNIT_INFO` for the debug defines).

If the user did not provide a name or a description of what the component does, ask before scaffolding.

## Steps

1. Create the files below, substituting the name.
2. Only include `CfgContext.hpp` if the feature adds ZEN context-menu actions; only include `initKeybinds.inc.sqf` if it adds CBA keybinds (and add the matching `#include` lines).
3. Add at least one starter function in `functions/` with a matching `PREP()` line — HEMTT fails on an empty `XEH_PREP.hpp` include chain if a PREP'd function file is missing.
4. Run `hemtt check` to verify.
5. Remind the user to add real stringtable entries for all user-facing text.

## Files

### `addons/<name>/$PBOPREFIX$` (no trailing newline)
```
x\rtz\addons\<name>
```

### `addons/<name>/config.cpp`
```cpp
#include "script_component.hpp"

class CfgPatches {
    class ADDON {
        name = COMPONENT_NAME;
        units[] = {};
        weapons[] = {};
        requiredVersion = REQUIRED_VERSION;
        requiredAddons[] = {"rtz_main", "zen_common"};
        author = "Maxim";
        authors[] = {"Maxim"};
        url = "";
        VERSION_CONFIG;
    };
};

#include "CfgEventHandlers.hpp"
#include "CfgContext.hpp"
```
(`rtz_common` goes in `requiredAddons` too if the component calls `EFUNC(common,...)` helpers. Drop the `CfgContext.hpp` include when there is no context menu.)

### `addons/<name>/script_component.hpp`
```cpp
#define COMPONENT <name>
#define COMPONENT_BEAUTIFIED <Name>
#include "\x\rtz\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE

#ifdef DEBUG_ENABLED_<NAME>
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_<NAME>
    #define DEBUG_SETTINGS DEBUG_SETTINGS_<NAME>
#endif

#include "\x\rtz\addons\main\script_macros.hpp"

// Component-specific tunable/visual #defines go here, each with a comment
// explaining the constraint (units, why the value)
```

### `addons/<name>/CfgEventHandlers.hpp`
```cpp
class Extended_PreStart_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_SCRIPT(XEH_preStart));
    };
};

class Extended_PreInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_SCRIPT(XEH_preInit));
    };
};

class Extended_PostInit_EventHandlers {
    class ADDON {
        init = QUOTE(call COMPILE_SCRIPT(XEH_postInit));
    };
};
```

### `addons/<name>/XEH_PREP.hpp`
```cpp
PREP(myFunction);
```

### `addons/<name>/XEH_preStart.sqf`
```sqf
#include "script_component.hpp"

#include "XEH_PREP.hpp"
```

### `addons/<name>/XEH_preInit.sqf`
```sqf
#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

#include "initSettings.inc.sqf"

ADDON = true;
```
(Add `#include "initKeybinds.inc.sqf"` after settings if the component has keybinds.)

### `addons/<name>/XEH_postInit.sqf`
```sqf
#include "script_component.hpp"

// CBA event handlers for order execution go here, e.g.:
// [QGVAR(myEvent), {_this call FUNC(myFunction)}] call CBA_fnc_addEventHandler;
```

### `addons/<name>/functions/script_component.hpp`
```cpp
#include "\x\rtz\addons\<name>\script_component.hpp"
```

### `addons/<name>/functions/fnc_myFunction.sqf`
```sqf
#include "script_component.hpp"
/*
 * Author: Maxim
 * <What the function does.>
 *
 * Arguments:
 * 0: <Description> <TYPE>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_unit] call rtz_<name>_fnc_myFunction
 *
 * Public: No
 */
```

### `addons/<name>/initSettings.inc.sqf`
```sqf
private _category = [ELSTRING(main,DisplayName), LSTRING(DisplayName)];

[
    QGVAR(enabled), "CHECKBOX",
    [LSTRING(Enabled), LSTRING(Enabled_Description)],
    _category,
    true,
    true
] call CBA_fnc_addSetting;
```
(Comment each setting with which machine reads it — curator client vs where the unit is local.)

### `addons/<name>/CfgContext.hpp` (only for ZEN context-menu features)
```cpp
class zen_context_menu_actions {
    class GVAR(myAction) {
        displayName = CSTRING(ActionMyAction);
        icon = "\a3\ui_f\data\igui\cfg\simpleTasks\types\attack_ca.paa";
        statement = QUOTE(_objects call FUNC(myFunction));
        condition = QUOTE(_objects isNotEqualTo []);
        priority = 28;
    };
};
```

### `addons/<name>/stringtable.xml`
```xml
<?xml version="1.0" encoding="utf-8"?>
<Project name="RTZ">
    <Package name="<Name>">
        <Key ID="STR_RTZ_<Name>_DisplayName">
            <English><Beautified Display Name></English>
        </Key>
        <Key ID="STR_RTZ_<Name>_Enabled">
            <English>Enable <Beautified Display Name></English>
        </Key>
        <Key ID="STR_RTZ_<Name>_Enabled_Description">
            <English>...</English>
        </Key>
    </Package>
</Project>
```
