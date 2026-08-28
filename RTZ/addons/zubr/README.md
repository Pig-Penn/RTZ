# rtz_csat — CSAT Zubr-class LCAC

It contains the Zubr-class LCAC hovercraft lifted out of **CUP Vehicles 1.19.2** —
model, textures, materials, sounds, animations and configs — repathed so it runs
with no CUP mod installed.

## What's in the box

| Class | What it is |
| --- | --- |
| `RTZ_O_Zubr_CSAT_T` | The CSAT Zubr. `faction = OPF_F`, `crew = O_crew_F`, white hull, CSAT flag. Scope 2 in both Eden and Zeus. CUP ships this class as CSAT Pacific (`OPF_T_F` / `O_T_crew_F`); `gen_config.py` retargets it to plain CSAT, which is also why the class name still carries CUP's `_T` suffix. |
| `RTZ_Zubr_Base` | Hidden base class (`scope = 0`) holding the whole vehicle definition. |
| `RTZ_Vacannon_AK630_veh` / `_1_veh` / `_2_veh` | The two AK-630 30 mm CIWS mounts. |
| `RTZ_Vmlauncher_OGON_veh` | A-22 Ogon 140 mm MRL, with CUP's four ranging firemodes. |
| `RTZ_2000Rnd_30mm_AK630_M`, `RTZ_44Rnd_Ogon_HE` | Magazines. |
| `RTZ_B_30mm_CAS_Red_Tracer`, `RTZ_B_30mm_AK630_Red_Tracer`, `RTZ_R_140mm_Ogon_HE` | Ammo. |
| `RTZ_Zubr_Cargo`, `RTZ_KIA_Zubr_Cargo` | Well-deck passenger pose, from CUP's RHIB. |

Everything is prefixed `RTZ_`, so this addon and CUP Vehicles can be loaded at the
same time without class collisions.

Only one variant is included, and only one livery. CUP builds this class as CSAT
Pacific; the rip retargets it to plain CSAT (see the table above). CUP's other eight
`TextureSources` entries (Light Blue, Dark Blue/White, White/Black, CDF, RU, SLA,
AAF, UN) are stripped, so the Eden/Zeus texture dropdown offers the CSAT one alone,
and the textures they reached for are not packed.

Three files still ship that read as RU assets — the light blue `zubr_body_1_co` /
`zubr_body_2_co` / `zubr_details_co` set, plus `flag_run_co.paa` and
`hull_num_0_ca.paa`. They are **not** removable: they are baked into `CUP_Zubr.p3d`
as the model's default face textures. Config overrides them at runtime through
`hiddenSelectionsTextures`, but the binarised model still asks for them by name, and
repathing it needs a byte-length-exact swap — see below.

## The padded folder names

`zubr_hovercraft_assets`, `rhib_proxy_assets_data` and `vehicle_logo_asset` look
arbitrary. They are not — **their lengths are load-bearing.**

`CUP_Zubr.p3d` is binarised ODOL v75. In that format the LOD start and end
addresses stored in the header are *absolute file offsets*, and the texture and
material paths live inside the LOD blocks that follow. Rewriting a path to a
different length shifts every subsequent LOD and corrupts the model. So each
replacement directory is padded to match the CUP path it replaced byte for byte:

```
cup\watervehicles\cup_watervehicles_zubr  ->  x\rtz\addons\zubr\zubr_hovercraft_assets   (40 == 40)
cup\watervehicles\cup_watervehicles_rhib  ->  x\rtz\addons\zubr\rhib_proxy_assets_data   (40 == 40)
cup\airvehicles\cup_airvehicles_core      ->  x\rtz\addons\zubr\vehicle_logo_asset       (36 == 36)
```

**Renaming any of those three folders breaks the model.** If you must rename one,
the new name has to be exactly the same length, and the p3d files have to be
re-patched to match.

`sound/` and `anim/` are only referenced from config text, so those names are free.
(`flags/` is gone — it only held the CDF/RU/SLA flags the stripped liveries used.)

## Known rough edges

- CUP writes its vanilla-Arma sound paths without a file extension. Arma resolves
  those itself, but hemtt's `L-C11ME` lint flags them, so `_rip/sound_ext.py` puts
  the extension back. Nothing there is guessed: all 24 paths were looked up in
  `sounds_f_vehicles.pbo` / `sounds_f.pbo` / `sounds_f_exp.pbo`, each resolves to
  exactly one file, and every one is `.wss`. A bare path that is not on that
  verified list makes the rip scripts raise rather than guess.
- The model keeps CUP's `proxy:\ca\temp\proxies\rhib\cargo.NNN` cargo-position
  proxies. That path does not exist in CUP either — they are inert placeholders —
  so behaviour matches CUP's Zubr exactly.
- `fn_ZubrEngineMonitor.sqf` runs `while {alive _vehicle} do { ... sleep 0.05 }`
  per craft, for the life of the craft. That is CUP's design and is untouched, but
  it is worth knowing about given RTZ targets multi-hour sessions with many units.
- `addon.toml` disables binarization: everything here is already binarised, and
  handing ODOL back to Binarize fails.

## Provenance

| From | PBO |
| --- | --- |
| Model, textures, materials, functions, previews | `cup_watervehicles_zubr.pbo` |
| RHIB hull textures used by the Zubr model, cargo `.rtm` animations | `cup_watervehicles_rhib.pbo` |
| CUP logo texture used by the model's UI LOD | `cup_airvehicles_core.pbo` |
| Engine sounds | `cup_airvehicles_c130j.pbo` |
| AK-630 / Ogon weapon configs, gun sound | `cup_weapons_vehicleweapons.pbo` |
| Ammo and magazine configs | `cup_weapons_ammunition.pbo` |

Every remaining external reference points at vanilla Arma 3. Credit for all of it belongs to the Community Upgrade Project.
