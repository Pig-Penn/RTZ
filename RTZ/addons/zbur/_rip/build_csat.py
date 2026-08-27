import os, re, shutil

R    = r"C:\Users\Maxim\AppData\Local\Temp\rtzrip"
DEST = r"c:\Users\Maxim\OneDrive\1D Documents\Modding\Real-Time Zeus\RTZ\addons\csat"

ZUBR = os.path.join(R, "cup_watervehicles_zubr", "CUP", "WaterVehicles", "CUP_WaterVehicles_Zubr")
RHIB = os.path.join(R, "cup_watervehicles_rhib", "CUP", "WaterVehicles", "CUP_WaterVehicles_RHIB")
CORE = os.path.join(R, "cup_airvehicles_core", "CUP", "AirVehicles", "CUP_AirVehicles_Core")
VW   = os.path.join(R, "cup_weapons_vehicleweapons", "CUP", "Weapons", "CUP_Weapons_VehicleWeapons")
C130 = os.path.join(R, "cup_airvehicles_c130j", "CUP", "AirVehicles", "CUP_AirVehicles_C130J")

# Same-length prefix rewrites. The .p3d files are binarised ODOL v75: their LOD
# start/end addresses are absolute file offsets, so a shorter or longer path
# would shift every LOD and corrupt the model. Each replacement directory name
# is padded to match the CUP path it replaces byte for byte.
REWRITES = [
    (rb"cup\watervehicles\cup_watervehicles_zubr", rb"x\rtz\addons\csat\zubr_hovercraft_assets"),
    (rb"cup\watervehicles\cup_watervehicles_rhib", rb"x\rtz\addons\csat\rhib_proxy_assets_data"),
    (rb"cup\airvehicles\cup_airvehicles_core",     rb"x\rtz\addons\csat\vehicle_logo_asset"),
]
for old, new in REWRITES:
    assert len(old) == len(new), (old, new, len(old), len(new))


def copy(src, dst):
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    shutil.copy2(src, dst)


if os.path.isdir(DEST):
    shutil.rmtree(DEST)

# --- assets -------------------------------------------------------------
copy(os.path.join(ZUBR, "CUP_Zubr.p3d"),
     os.path.join(DEST, "zubr_hovercraft_assets", "CUP_Zubr.p3d"))
# CUP_Zubr_proxies_placeholder.p3d is not copied: nothing loads it. CUP_Zubr.p3d
# keeps its own proxy:\ca\temp\proxies\rhib\cargo.NNN placeholders, which point at
# a path that does not exist in CUP either.
shutil.copytree(os.path.join(ZUBR, "data"),
                os.path.join(DEST, "zubr_hovercraft_assets", "data"), dirs_exist_ok=True)
shutil.copytree(os.path.join(ZUBR, "functions"),
                os.path.join(DEST, "zubr_hovercraft_assets", "functions"), dirs_exist_ok=True)

# CUP names its editor preview after its own class; ours is RTZ_O_Zubr_CSAT_T.
DATA = os.path.join(DEST, "zubr_hovercraft_assets", "data")
os.replace(os.path.join(DATA, "preview", "CUP_O_ZUBR_CSAT_T.jpg"),
           os.path.join(DATA, "preview", "RTZ_O_Zubr_CSAT_T.jpg"))

# Only the CSAT Pacific livery ships. gen_config.py strips CUP's other eight
# TextureSources entries, which leaves these unreferenced - the _dark_co set,
# the non-CSAT flags, five hull-number digits and the other previews. The light
# blue _co set, flag_run and hull_num_0 are NOT prunable: they are baked into
# CUP_Zubr.p3d as the model's default face textures. Run verify_paths.py after
# any change here.
PRUNE = (
    ["zubr_body_1_dark_co.paa", "zubr_body_2_dark_co.paa", "zubr_details_dark_co.paa"]
    + [os.path.join("flags", f) for f in
       ["flag_greece_co.paa", "flag_plan_co.paa", "flag_sovn_co.paa"]]
    + [os.path.join("num", "hull_num_%d_ca.paa" % d) for d in (1, 4, 6, 8, 9)]
    + [os.path.join("preview", f) for f in
       ["CUP_B_ZUBR_CDF.jpg", "CUP_I_ZUBR_AAF.jpg", "CUP_I_ZUBR_UN.jpg",
        "CUP_O_ZUBR_RU.jpg", "CUP_O_ZUBR_SLA.jpg"]]
)
for rel in PRUNE:
    os.remove(os.path.join(DATA, rel))
print("pruned %d non-CSAT assets" % len(PRUNE))

for src, out in [("RHIB.rvmat", "rhib.rvmat"), ("rhib_co.paa", "rhib_co.paa"),
                 ("rhib_nohq.paa", "rhib_nohq.paa"), ("rhib_smdi.paa", "rhib_smdi.paa")]:
    copy(os.path.join(RHIB, "data", src),
         os.path.join(DEST, "rhib_proxy_assets_data", "data", out))

copy(os.path.join(CORE, "ui", "cup_logo_vehicles_1024.paa"),
     os.path.join(DEST, "vehicle_logo_asset", "ui", "cup_logo_vehicles_1024.paa"))

for s in ["ext_engine_hi", "ext_engine_low", "ext_forsage_1",
          "int_engine_hi", "int_engine_low", "int_forsage_1"]:
    copy(os.path.join(C130, "data", "Sound", s + ".wss"),
         os.path.join(DEST, "sound", s + ".wss"))
copy(os.path.join(VW, "data", "sound", "GAU8_05sec_burst.wss"),
     os.path.join(DEST, "sound", "GAU8_05sec_burst.wss"))

# texHeaders.bin is a Binarize-generated cache keyed to the original paths, so it
# is deliberately not copied. .gitignore already excludes that name repo-wide.

# --- path rewrite -------------------------------------------------------
total = 0
for root, _, files in os.walk(DEST):
    for f in sorted(files):
        # .sqf too: fn_zubrhullnumbers builds a texture path with format at runtime
        if not f.lower().endswith((".p3d", ".rvmat", ".sqf")):
            continue
        p = os.path.join(root, f)
        with open(p, "rb") as fh:
            blob = fh.read()
        before = len(blob)
        n = 0
        for old, new in REWRITES:
            # Arma paths are case-insensitive; CUP writes them in mixed case.
            # lambda repl: backslashes in a plain replacement string are escapes
            blob, k = re.subn(re.escape(old), lambda m, n=new: n, blob, flags=re.IGNORECASE)
            n += k
        if f.lower().endswith(".p3d"):
            assert len(blob) == before, "p3d length changed - LOD offsets would break"
        if n:
            with open(p, "wb") as fh:
                fh.write(blob)
            total += n
            print("  %4d  %s" % (n, os.path.relpath(p, DEST)))

print("\nrewrote %d path references" % total)

# --- verify no CUP paths survive ---------------------------------------
leftovers = {}
for root, _, files in os.walk(DEST):
    for f in files:
        if not f.lower().endswith((".p3d", ".rvmat", ".sqf")):
            continue
        with open(os.path.join(root, f), "rb") as fh:
            blob = fh.read()
        for m in re.finditer(rb"(?i)cup\\[a-z0-9_\\]+", blob):
            k = m.group(0).decode("latin1").lower()
            leftovers[k] = leftovers.get(k, 0) + 1

if leftovers:
    print("\nREMAINING CUP PATHS:")
    for k, v in sorted(leftovers.items()):
        print("  %4d  %s" % (v, k))
else:
    print("\nno CUP paths remain in p3d/rvmat/sqf")

size = sum(os.path.getsize(os.path.join(r, f))
           for r, _, fs in os.walk(DEST) for f in fs)
print("addon payload: %.1f MB" % (size / 1024 / 1024))
