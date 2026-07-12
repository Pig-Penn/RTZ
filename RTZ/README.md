<p align="center">
    <strong>Real-Time Zeus (RTZ)</strong><br/>
    Live unit information tools for the Zeus interface.
</p>

---

Real-Time Zeus is an Arma 3 mod that adds real-time information displays to the Zeus interface. It is built on [CBA A3](https://github.com/CBATeam/CBA_A3) and [Zeus Enhanced (ZEN)](https://github.com/zen-mod/ZEN), and follows the [ACE3 coding guidelines](https://ace3.acemod.org/wiki/development/coding-guidelines) and modular component structure.

## Features

### Unit Info (`rtz_unit_info`)

A toggleable, per-unit overlay for Zeus:

- **Show/Hide Unit Info** action in the [ZEN context menu](https://github.com/zen-mod/ZEN/wiki/Context-Menu) (default: <kbd>⊞ Win</kbd> while in Zeus). Works on selected/hovered units; selecting a vehicle toggles its whole crew. The action label switches between *Show* and *Hide* based on the current state.
- A condensed **horizontal health bar** above each tracked unit with a green → yellow → red gradient that shrinks as the unit takes damage.
- A thinner **ammo bar** below the health bar showing the remaining ammunition in the unit's current magazine (hidden while mounted).
- A single **info line** above the bar: name, group ID, health %, camera distance, and mounted vehicle — each element individually toggleable.
- Optional **AI state info** on the same line: the unit's current command and unit state, plus the group's active [LAMBS Danger FSM](https://github.com/nk3nny/LambsDanger) task and tactic on group leaders.
- **State markers**: `UNC` (unconscious, amber) and `KIA` (dead, red). Works with ACE Medical via `lifeState`.
- Info text colored by the unit's side (optional).

Everything is drawn only while the Zeus display is open and only within a configurable draw distance.

### CBA Settings

All settings are client-side, under **Options → Addon Options → Real-Time Zeus** (in-Zeus feedback is immediate):

| Setting | Default | Description |
|---|---|---|
| Draw Distance | 1000 m | Maximum camera distance at which info is drawn |
| Size | 1 | Overall scale of the bar and text |
| Show Name | On | Display the unit's name |
| Show Group | Off | Display the unit's group ID |
| Show Health Percentage | On | Display health as a percentage |
| Show Ammo Bar | On | Display remaining ammo in the unit's current magazine |
| Show Distance | Off | Display distance from the Zeus camera |
| Show Vehicle | On | Display the name of the vehicle the unit is crewing |
| Show Current Command | Off | Display the unit's current AI command (e.g. MOVE, ATTACKFIRE) |
| Show Unit State | Off | Display the execution state of the unit's current AI command |
| Show LAMBS Task | Off | Display the current LAMBS Danger FSM task on the group leader |
| Show LAMBS Tactic | Off | Display the group's current LAMBS Danger FSM tactic on the group leader |
| Color Text by Side | On | Color the info text using the unit's side color |
| Remove on Death | Off | Stop tracking units on death instead of showing a KIA marker |

## Performance Notes

- The `Draw3D` handler only exists while the Zeus display is open **and** at least one unit is tracked (`zen_curatorDisplayLoaded` / `zen_curatorDisplayUnloaded` events); it is fully removed otherwise.
- Static/expensive data (bar height from `boundingBoxReal`, unit name, side color) is cached once per unit when tracking starts; magazine capacities are cached per classname in a hashmap so config lookups happen once per magazine type.
- Distance culling uses `vectorDistanceSqr` (no square root per unit per frame).
- Deleted and dead units are pruned lazily from the tracking list.
- Everything is fully local to the Zeus client — no network traffic, no server-side code.

## Requirements

- Arma 3 v2.18+
- [CBA A3](https://steamcommunity.com/workshop/filedetails/?id=450814997) v3.16+
- [Zeus Enhanced](https://steamcommunity.com/workshop/filedetails/?id=1779063631) v1.13+

## Project Structure

```
RTZ/
├── .hemtt/project.toml     # HEMTT build configuration
├── mod.cpp                 # Launcher metadata
├── include/                # Vendored CBA headers so HEMTT can build without a P: drive
└── addons/
    ├── main/               # Framework core: prefix, version, CBA/ZEN macros, dependency checks
    └── unit_info/          # Health bar + unit info component
        ├── config.cpp      # CfgPatches, XEH hooks, ZEN context menu action (CfgContext.hpp)
        ├── XEH_*.sqf       # CBA extended event handler entry points
        ├── initSettings.inc.sqf
        ├── stringtable.xml
        └── functions/      # PREP'd component functions (fnc_*.sqf)
```

New features should be added as new components under `addons/` following the same pattern (`$PBOPREFIX$`, `script_component.hpp`, `XEH_PREP.hpp`, PREP'd functions), depending on `rtz_main`.

Visual tunables (bar dimensions, colors, text size/offset) are `#define`s at the top of [addons/unit_info/script_component.hpp](addons/unit_info/script_component.hpp).

## Building

Building uses [HEMTT](https://hemtt.dev):

```
hemtt dev      # quick dev build
hemtt launch   # dev build + launch the game with CBA and ZEN
hemtt release  # signed release build
```

For `hemtt launch`, configure your launch preset in `.hemtt/project.toml` ([docs](https://hemtt.dev/configuration/launch)) with CBA and ZEN as workshop dependencies.

## Credits

- The [ZEN](https://github.com/zen-mod/ZEN) and [ACE3](https://github.com/acemod/ACE3) teams for the frameworks, standards, and structural conventions this mod is modeled on.
- [CBA A3](https://github.com/CBATeam/CBA_A3) team for the underlying scripting framework (vendored headers in `include/` are © the CBA team, GPL-2.0).
