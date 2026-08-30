"""Slice CUP_ZUBR_Base + CUP_O_ZUBR_CSAT_T out of CUP's derapified config and
rebase every CUP path, class name and stringtable key onto the rtz_zubr addon."""
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
#
# The tag MUST match what CfgFunctions.hpp actually builds, which is
# PREFIX_COMPONENT = rtz_zubr (script_mod.hpp defines PREFIX rtz, and
# script_component.hpp defines COMPONENT zubr). These read rtz_csat_ until
# 2026-08-29 — a leftover of the addons/csat -> addons/zubr rename — so all five
# generated call sites resolved to nil and `spawn nil` threw: no propeller or air
# cushion animation, no Ogon ranging fix, no hull numbers. Nothing catches this,
# because the call sites are string literals inside config properties and
# `hemtt check` does not look inside them.
FUNCS = [
    ("CUP_fnc_ZubrEngineMonitor",     "rtz_zubr_fnc_zubrEngineMonitor"),
    ("CUP_fnc_zubrMissileRangingFix", "rtz_zubr_fnc_zubrMissileRangingFix"),
    ("cup_fnc_zubrhullnumbers",       "rtz_zubr_fnc_zubrHullNumbers"),
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

# CUP registers the engine monitor only where the hull is local at creation, and
# its monitor then never re-tests locality. That pair loses the animation for good
# on a handover: the old owner's animateSource calls become silent no-ops and the
# new owner has nothing registered to resume. RTZ's monitor registers on every
# machine and tests `local` per tick instead, so the guard has to come off here.
# See fn_ZubrEngineMonitor.sqf.
EVENT_HANDLERS = [
    ('if (local (_this select 0)) then {(_this select 0) spawn RTZ_FNC_ENGINE_MONITOR}',
     '(_this select 0) call RTZ_FNC_ENGINE_MONITOR'),
]


def unguard_init(text):
    """Drop CUP's creation-time locality guard from the engine monitor's init EH.

    Runs AFTER apply(), so the function name is already the rebased one — hence
    the placeholder, substituted in from the FUNCS table rather than spelled twice.
    """
    monitor = dict(FUNCS)["CUP_fnc_ZubrEngineMonitor"]
    for old, new in EVENT_HANDLERS:
        old = old.replace("RTZ_FNC_ENGINE_MONITOR", monitor)
        new = new.replace("RTZ_FNC_ENGINE_MONITOR", monitor)
        text, n = re.subn(re.escape(old), lambda m, v=new: v, text)
        assert n == 1, "expected exactly one %r, found %d" % (old, n)
    return text

# CUP `spawn`s both helper scripts. RTZ's ports are unscheduled — the monitor is a
# shared CBA per-frame handler and the ranging fix is a CBA_fnc_waitAndExecute — so
# a scheduled scope buys nothing and costs the ~3 ms/frame scheduler budget.
SPAWN_TO_CALL = [dict(FUNCS)[k] for k in (
    "CUP_fnc_zubrMissileRangingFix", "cup_fnc_zubrhullnumbers",
)]


def unspawn(text):
    for fnc in SPAWN_TO_CALL:
        text, n = re.subn(r"\bspawn (?=" + re.escape(fnc) + r"\b)", "call ", text)
        assert n > 0, "expected at least one `spawn %s`" % fnc
    return text


externals = apply(externals)
zubr_base = unspawn(unguard_init(strip_liveries(apply(zubr_base))))
csat_t    = retarget_faction(apply(csat_t))

body = "\n".join([
    "// Ripped from CUP Vehicles 1.19.2, cup_watervehicles_zubr.pbo, class",
    "// CUP_ZUBR_Base / CUP_O_ZUBR_CSAT_T. Paths, class names and stringtable keys",
    "// rebased onto rtz_zubr; the values themselves are CUP's, unchanged.",
    "// See README.md in this folder before touching anything here.",
    "//",
    "// Generated by _rip/gen_config.py. Hand-edit only alongside the matching change",
    "// there, or the next regeneration silently reverts it.",
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
