"""Pull the four weapons, two magazines and three ammo types the Zubr needs out of
CUP Weapons and rebase them onto rtz_zubr. Every parent class they inherit from is
vanilla Arma, so nothing here drags in a CUP dependency."""
import os, re

import sound_ext

R    = r"C:\Users\Maxim\AppData\Local\Temp\rtzrip"
DEST = r"c:\Users\Maxim\OneDrive\1D Documents\Modding\Real-Time Zeus\RTZ\addons\zubr"
AMMO = os.path.join(R, "cup_weapons_ammunition", "CUP", "Weapons",
                    "CUP_Weapons_Ammunition", "config.cpp")
VEHW = os.path.join(R, "cup_weapons_vehicleweapons", "CUP", "Weapons",
                    "CUP_Weapons_VehicleWeapons", "config.cpp")


def read(p):
    with open(p, "r", encoding="utf-8", errors="replace") as fh:
        return fh.read().replace("\r\n", "\n")


def extract(text, name):
    """Return the full `class name: parent { ... };` block, brace-matched."""
    m = re.search(r"^([ \t]*)class[ \t]+%s[ \t]*:" % re.escape(name), text, re.M)
    if not m:
        raise SystemExit("class not found: " + name)
    start = m.start()
    i = text.index("{", m.end())
    depth = 0
    while True:
        c = text[i]
        if c == "{":
            depth += 1
        elif c == "}":
            depth -= 1
            if depth == 0:
                break
        i += 1
    end = text.index(";", i) + 1
    block = text[start:end]
    # strip one level of CUP's leading tab so it sits at our indent
    return "\n".join(l[1:] if l.startswith("\t") else l for l in block.split("\n"))


SUBS = [
    (r"CUP\Weapons\CUP_Weapons_VehicleWeapons\data\sound", r"x\rtz\addons\zubr\sound"),
    ("CUP_2000Rnd_TE1_Red_Tracer_30mm_AK630_M", "RTZ_2000Rnd_30mm_AK630_M"),
    ("CUP_B_30mm_AK630_Red_Tracer",             "RTZ_B_30mm_AK630_Red_Tracer"),
    ("CUP_B_30mm_CAS_Red_Tracer",               "RTZ_B_30mm_CAS_Red_Tracer"),
    ("CUP_Vacannon_AK630_1_veh",                "RTZ_Vacannon_AK630_1_veh"),
    ("CUP_Vacannon_AK630_2_veh",                "RTZ_Vacannon_AK630_2_veh"),
    ("CUP_Vacannon_AK630_veh",                  "RTZ_Vacannon_AK630_veh"),
    ("CUP_Vmlauncher_OGON_veh",                 "RTZ_Vmlauncher_OGON_veh"),
    ("CUP_R_140mm_Ogon_HE",                     "RTZ_R_140mm_Ogon_HE"),
    ("CUP_44Rnd_Ogon_HE",                       "RTZ_44Rnd_Ogon_HE"),
    ("STR_CUP_dn_a22_44rnd_he_M",               "STR_RTZ_Zubr_mag_Ogon_HE"),
    ("STR_CUP_DN_OGON_4000",                    "STR_RTZ_Zubr_wpn_Ogon_4000"),
    ("STR_CUP_DN_OGON_3000",                    "STR_RTZ_Zubr_wpn_Ogon_3000"),
    ("STR_CUP_DN_OGON_2000",                    "STR_RTZ_Zubr_wpn_Ogon_2000"),
    ("STR_CUP_DN_OGON_1000",                    "STR_RTZ_Zubr_wpn_Ogon_1000"),
    ("STR_CUP_DN_OGON",                         "STR_RTZ_Zubr_wpn_Ogon"),
    ("STR_CUP_AUTHOR_STRING",                   "STR_RTZ_Zubr_author"),
]


# CUP ships every CamShake field as a quoted string, because the `duration` ones
# contain `round` and `max` — SQF operators the rapifier cannot evaluate, so they
# have to stay strings. The three below are plain arithmetic, and HEMTT's L-C12
# lint asks for the quotes so it can fold them at build time. Only the quotes are
# removed; the expressions, and therefore the values, are still CUP's.
UNQUOTE = [
    'power = "(25 * 0.2)";',
    'distance = "((2 + 25^0.5)*8)";',
    'distance = "((25^0.5)*8)";',
]


def apply(text):
    for old, new in SUBS:
        text = re.sub(re.escape(old), lambda m, n=new: n, text, flags=re.IGNORECASE)
    for quoted in UNQUOTE:
        text = text.replace(quoted, quoted.replace('"', ""))
    return text


ammo_src = read(AMMO)
vehw_src = read(VEHW)

HEADER = ("// Ripped from CUP Weapons 1.19.2 (%s).\n"
          "// Renamed onto the RTZ_ prefix so this addon never collides with CUP\n"
          "// when both are loaded. Values are CUP's, unchanged.\n\n")

files = {
    "CfgAmmo.hpp": (
        HEADER % "cup_weapons_ammunition.pbo"
        + "class CfgAmmo {\n"
          "    class BulletBase;\n"
          "    class RocketBase;\n\n"
        + apply(extract(ammo_src, "CUP_B_30mm_CAS_Red_Tracer")) + "\n\n"
        + apply(extract(ammo_src, "CUP_B_30mm_AK630_Red_Tracer")) + "\n\n"
        + apply(extract(ammo_src, "CUP_R_140mm_Ogon_HE")) + "\n"
          "};\n"),
    "CfgMagazines.hpp": (
        HEADER % "cup_weapons_ammunition.pbo"
        + "class CfgMagazines {\n"
          "    class VehicleMagazine;\n"
          "    class 24Rnd_missiles;\n\n"
        + apply(extract(ammo_src, "CUP_2000Rnd_TE1_Red_Tracer_30mm_AK630_M")) + "\n\n"
        + apply(extract(ammo_src, "CUP_44Rnd_Ogon_HE")) + "\n"
          "};\n"),
    "CfgWeapons.hpp": (
        HEADER % "cup_weapons_vehicleweapons.pbo"
        + "class CfgWeapons {\n"
          "    class CannonCore;\n"
          "    class RocketPods;\n\n"
        + apply(extract(vehw_src, "CUP_Vacannon_AK630_veh")) + "\n\n"
        + apply(extract(vehw_src, "CUP_Vacannon_AK630_1_veh")) + "\n\n"
        + apply(extract(vehw_src, "CUP_Vacannon_AK630_2_veh")) + "\n\n"
        + apply(extract(vehw_src, "CUP_Vmlauncher_OGON_veh")) + "\n"
          "};\n"),
}

for name, text in files.items():
    text = sound_ext.fix(text)
    p = os.path.join(DEST, name)
    with open(p, "w", encoding="utf-8", newline="\n") as fh:
        fh.write(text)
    left = sorted(set(re.findall(r"(?i)\bcup[_\\][A-Za-z0-9_\\]*", text)))
    left = [t for t in left if not t.lower().startswith("cup_weapons")]  # header comment
    print("%-20s %4d lines   %s" % (name, text.count("\n") + 1,
                                    ("LEFTOVER: " + ", ".join(left)) if left else "clean"))
