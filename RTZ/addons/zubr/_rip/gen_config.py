"""Slice CUP_ZUBR_Base + CUP_O_ZUBR_CSAT_T out of CUP's derapified config and
rebase every CUP path, class name and stringtable key onto the rtz_csat addon."""
import os, re, shutil

import sound_ext

R    = r"C:\Users\Maxim\AppData\Local\Temp\rtzrip"
DEST = r"c:\Users\Maxim\OneDrive\1D Documents\Modding\Real-Time Zeus\RTZ\addons\zubr"
SRC  = os.path.join(R, "cup_watervehicles_zubr", "CUP", "WaterVehicles",
                    "CUP_WaterVehicles_Zubr", "config.cpp")
RHIB = os.path.join(R, "cup_watervehicles_rhib", "CUP", "WaterVehicles", "CUP_WaterVehicles_RHIB")

# --- extra assets the config (not the model) reaches for ----------------
def copy(src, dst):
    os.makedirs(os.path.dirname(dst), exist_ok=True)
    shutil.copy2(src, dst)

# CUP's CDF/RU/SLA flags are not copied: only the CSAT livery ships, and
# strip_liveries() below removes the TextureSources entries that used them.
for f in ["RHIB_Cargo.rtm", "KIA_RHIB_Cargo.rtm"]:
    copy(os.path.join(RHIB, "data", "anim", f), os.path.join(DEST, "anim", f))

# --- slice --------------------------------------------------------------
with open(SRC, "r", encoding="utf-8", errors="replace") as fh:
    lines = [l.rstrip("\r\n") for l in fh]

def slice_(a, b):                      # 1-indexed, inclusive
    return "\n".join(lines[a - 1:b])

externals = slice_(58, 102)            # forward declarations
zubr_base = slice_(106, 1004)          # class CUP_ZUBR_Base
csat_t    = slice_(1193, 1286)         # class CUP_O_ZUBR_CSAT_T

# --- substitutions ------------------------------------------------------
# Paths. Only the .p3d needed byte-for-byte padding; these are plain config
# strings, but they use the same padded folders so there is one layout.
PATHS = [
    (r"cup\watervehicles\cup_watervehicles_zubr", r"x\rtz\addons\zubr\zubr_hovercraft_assets"),
    (r"CUP\AirVehicles\CUP_AirVehicles_C130J\data\sound", r"x\rtz\addons\zubr\sound"),
]
# Class names. Renamed so the addon never collides with CUP when both load.
CLASSES = [
    ("CUP_2000Rnd_TE1_Red_Tracer_30mm_AK630_M", "RTZ_2000Rnd_30mm_AK630_M"),
    ("CUP_Vacannon_AK630_1_veh",                "RTZ_Vacannon_AK630_1_veh"),
    ("CUP_Vacannon_AK630_2_veh",                "RTZ_Vacannon_AK630_2_veh"),
    ("CUP_Vmlauncher_OGON_veh",                 "RTZ_Vmlauncher_OGON_veh"),
    ("CUP_R_140mm_Ogon_HE",                     "RTZ_R_140mm_Ogon_HE"),
    ("CUP_44Rnd_Ogon_HE",                       "RTZ_44Rnd_Ogon_HE"),
    ("CUP_O_ZUBR_CSAT_T",                       "RTZ_O_Zubr_CSAT_T"),
    ("CUP_ZUBR_Base",                           "RTZ_Zubr_Base"),
    ("CUP_RHIB_Cargo",                          "RTZ_Zubr_Cargo"),
]
# Functions. CUP writes these in three different casings.
FUNCS = [
    ("CUP_fnc_ZubrEngineMonitor",     "rtz_csat_fnc_zubrEngineMonitor"),
    ("CUP_fnc_zubrMissileRangingFix", "rtz_csat_fnc_zubrMissileRangingFix"),
    ("cup_fnc_zubrhullnumbers",       "rtz_csat_fnc_zubrHullNumbers"),
]
# Stringtable keys, longest prefix first.
STRINGS = [
    ("STR_CUP_dn_LCU1600_Atrb_CustomShipNumber", "STR_RTZ_Zubr_atrb_HullNumber"),
    ("STR_CUP_dn_ZUBR_Atrb_CustomShipFlag",      "STR_RTZ_Zubr_atrb_Flag"),
    ("STR_CUP_dn_ZUBR_Atrb_FrontRampPos",        "STR_RTZ_Zubr_atrb_FrontRamp"),
    ("STR_CUP_dn_ZUBR_Atrb_RearRampPos",         "STR_RTZ_Zubr_atrb_RearRamp"),
    ("STR_CUP_dn_ZUBR_Atrb_FlagHide",            "STR_RTZ_Zubr_atrb_FlagHide"),
    ("STR_CUP_dn_Core_tex_",                     "STR_RTZ_Zubr_tex_"),
    ("STR_CUP_POSITION_Core_LG",                 "STR_RTZ_Zubr_pos_LeftGunner"),
    ("STR_CUP_POSITION_Core_RG",                 "STR_RTZ_Zubr_pos_RightGunner"),
    ("STR_CUP_dn_ZUBR_Base",                     "STR_RTZ_Zubr_Base"),
    ("STR_CUP_AUTHOR_STRING",                    "STR_RTZ_Zubr_author"),
]

def apply(text):
    for old, new in STRINGS + PATHS + CLASSES + FUNCS:
        text = re.sub(re.escape(old), lambda m, n=new: n, text, flags=re.IGNORECASE)
    return text


# Only the CSAT Pacific livery ships, so CUP's other eight TextureSources go.
# Dropping them is what makes the _dark_co textures, the CDF/RU/SLA flags and
# five of the hull-number digits unreferenced, and build_csat.py prunes those.
# The base class keeps its own hiddenSelectionsTextures: those name the light
# blue _co set, flag_run and hull_num_0, which are baked into CUP_Zubr.p3d as
# the model's default face textures and cannot be dropped.
LIVERIES = ["LightBlue", "DarkBlueWhite", "WhiteBlack", "CDF", "RU", "SLA", "AAF", "UN"]


def strip_liveries(text):
    for name in LIVERIES:
        pat = re.compile(r"[ \t]*class " + name + r"\b[^\n]*\r?\n[ \t]*\{.*?\r?\n[ \t]*\};[ \t]*\r?\n", re.S)
        text, n = pat.subn("", text)
        assert n == 1, "expected exactly one class %s, found %d" % (name, n)
    return text

# CUP ships this as CSAT Pacific. RTZ wants it in plain CSAT, crewed by the
# base-game crewman rather than the Apex one.
FACTION = [
    ('faction = "OPF_T_F"', 'faction = "OPF_F"'),
    ('crew = "O_T_crew_F"', 'crew = "O_crew_F"'),
]


def retarget_faction(text):
    for old, new in FACTION:
        text, n = re.subn(re.escape(old), lambda m, v=new: v, text)
        assert n == 1, "expected exactly one %r, found %d" % (old, n)
    return text


externals = apply(externals)
zubr_base = strip_liveries(apply(zubr_base))
csat_t    = retarget_faction(apply(csat_t))

body = "\n".join([
    "// Ripped from CUP Vehicles 1.19.2, cup_watervehicles_zubr.pbo, class",
    "// CUP_ZUBR_Base / CUP_O_ZUBR_CSAT_T. Paths, class names and stringtable keys",
    "// rebased onto rtz_csat; the values themselves are CUP's, unchanged.",
    "// See README.md in this folder before touching anything here.",
    "",
    externals,
    "",
    "class CfgVehicles {",
    "    class Ship_F;",
    "",
    zubr_base,
    csat_t,
    "};",
    "",
])

body = sound_ext.fix(body)

out = os.path.join(DEST, "CfgVehicles.hpp")
with open(out, "w", encoding="utf-8", newline="\n") as fh:
    fh.write(body)

print("wrote %s (%d lines)" % (out, body.count("\n") + 1))

# --- report anything still pointing at CUP ------------------------------
left = sorted(set(re.findall(r"(?i)\bcup[_\\][A-Za-z0-9_\\]*", body)))
if left:
    print("\nUNMAPPED CUP TOKENS:")
    for t in left:
        print("   ", t)
else:
    print("no CUP tokens remain in CfgVehicles.hpp")
