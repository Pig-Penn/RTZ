# How this addon was generated

These are the scripts that produced `addons/csat`. Nothing here is needed at
runtime — keep them only so the rip can be redone against a newer CUP without
hand-editing a thousand lines of config.

They all expect the CUP PBOs to be **extracted to `C:\Users\Maxim\AppData\Local\Temp\rtzrip`**
first. That path is short on purpose: the default scratch directory is ~150
characters deep, and CUP's internal folder structure pushes some files past
Windows' 260-character `MAX_PATH`, which makes `extractpbo` silently drop them.

## 1. Extract

Using Mikero's `extractpbo` (`C:\Program Files (x86)\Mikero\DePboTools\bin`):

```sh
R=/c/Users/Maxim/AppData/Local/Temp/rtzrip
A="/c/Program Files (x86)/Steam/steamapps/common/Arma 3/!Workshop"
mkdir -p "$R" && cd "$R"
for p in \
  "@CUP Vehicles/addons/cup_watervehicles_zubr" \
  "@CUP Vehicles/addons/cup_watervehicles_rhib" \
  "@CUP Vehicles/addons/cup_airvehicles_core" \
  "@CUP Vehicles/addons/cup_airvehicles_c130j" \
  "@CUP Weapons/addons/cup_weapons_vehicleweapons" \
  "@CUP Weapons/addons/cup_weapons_ammunition" ; do
    f=$(basename "$p"); cp "$A/$p.pbo" "$f.pbo"
    "/c/Program Files (x86)/Mikero/DePboTools/bin/extractpbo" -PW "$f.pbo"
done
```

`-P` skips the keypress pause, `-W` waits for completion. Watch for `cannot write
to file` — that means `MAX_PATH` truncated the extraction and the result is
incomplete.

## 2. Generate

Run from the repo root, in this order:

| Script | Does |
| --- | --- |
| `build_csat.py` | Wipes and rebuilds `addons/csat`, copies every asset, renames the CSAT editor preview, prunes the non-CSAT assets, then byte-patches the CUP paths inside the `.p3d`, `.rvmat` and `.sqf` files. Asserts the `.p3d` length never changes. |
| `gen_config.py` | Slices `CUP_ZUBR_Base` and `CUP_O_ZUBR_CSAT_T` out of CUP's derapified config and writes `CfgVehicles.hpp`, rebasing paths, class names, function names and stringtable keys, and stripping the eight non-CSAT `TextureSources`. |
| `gen_weapons.py` | Brace-matches the four weapons, two magazines and three ammo types out of CUP Weapons into `CfgWeapons.hpp` / `CfgMagazines.hpp` / `CfgAmmo.hpp`. |
| `sound_ext.py` | Not run directly. Imported by the two generators to put `.wss` back on the vanilla sound paths CUP writes bare. Raises on any bare path not on its verified list, so a newer CUP fails loudly instead of being guessed at. |
| `verify_paths.py` | Collects every `x\rtz\addons\csat\…` reference from the built addon and confirms each resolves to a file that exists. Run this last. |

`build_csat.py` deletes `addons/csat` wholesale, so it also removes the
hand-written files (`config.cpp`, `script_component.hpp`, `stringtable.xml`,
`CfgFunctions.hpp`, `CfgMoves.hpp`, `addon.toml`, `README.md`, `$PBOPREFIX$` and
this folder). Back those up before re-running it, or comment out the `rmtree`.

Note that OneDrive holds locks on freshly written files, so a re-run immediately
after a previous one can fail on `rmtree` with `WinError 32`. Wait for sync to
settle and try again.

## Line-length constraint

`build_csat.py` asserts that each replacement path is exactly as long as the CUP
path it replaces. That is not cosmetic — see the "padded folder names" section of
`../README.md`. If you add a new source PBO, its replacement folder name must be
padded to match, or the model will be corrupted.
