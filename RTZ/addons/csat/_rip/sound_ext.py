"""Put the file extension back on the vanilla Arma sound paths CUP writes bare.

Arma resolves an extension-less sound path itself, so CUP's configs work as
written, but hemtt's L-C11ME lint flags every one of them. Each path below was
looked up in the shipped PBOs (sounds_f_vehicles.pbo, sounds_f.pbo,
sounds_f_exp.pbo) by parsing their headers: all 24 resolve to exactly one file
and it is always .wss, so none of them is a .wss/.ogg coin flip.

fix() raises on any bare path that is not in VERIFIED, so a re-rip against a
newer CUP that introduces one fails loudly instead of guessing an extension.
"""
import re

EXTS = (".wss", ".ogg", ".wav", ".paa", ".p3d", ".rvmat", ".rtm", ".jpg", ".bisurf")

VERIFIED = {
    # sounds_f_exp.pbo
    r"a3\sounds_f_exp\vehicles\air\vtol_02\vtol_02_start_int",
    r"a3\sounds_f_exp\vehicles\air\vtol_02\vtol_02_start_ext",
    r"a3\sounds_f_exp\vehicles\air\vtol_02\vtol_02_stop_int",
    r"a3\sounds_f_exp\vehicles\air\vtol_02\vtol_02_stop_ext",
    # sounds_f_vehicles.pbo
    r"a3\sounds_f\vehicles\crashes\cars\cars_coll_big_default_ext_1",
    r"a3\sounds_f\vehicles\crashes\cars\cars_coll_big_default_ext_2",
    r"a3\sounds_f\vehicles\crashes\cars\cars_coll_big_default_ext_3",
    r"a3\sounds_f\vehicles\crashes\cars\cars_coll_big_default_ext_4",
    r"a3\sounds_f\vehicles\crashes\cars\cars_coll_big_wood_ext_1",
    r"a3\sounds_f\vehicles\crashes\cars\cars_coll_big_wood_ext_2",
    r"a3\sounds_f\vehicles\crashes\cars\cars_coll_big_wood_ext_6",
    r"a3\sounds_f\vehicles\crashes\cars\cars_coll_big_wood_ext_8",
    r"a3\sounds_f\vehicles\crashes\helis\heli_coll_default_ext_1",
    r"a3\sounds_f\vehicles\crashes\helis\heli_coll_default_ext_2",
    r"a3\sounds_f\vehicles\crashes\helis\heli_coll_default_ext_3",
    r"a3\sounds_f\vehicles\boat\sfx\voda-o-bok-lodi-0-speed1",
    r"a3\sounds_f\vehicles\boat\sfx\voda-o-bok-lodi-20-speed",
    r"a3\sounds_f\vehicles\boat\sfx\voda-o-bok-lodi-50-speed",
    r"a3\sounds_f\vehicles\boat\noises\boat_land_on_shallow",
    r"a3\sounds_f\vehicles\boat\boat_armed_01\servo_boat_comm",
    r"a3\sounds_f\vehicles\boat\boat_armed_01\servo_boat_comm_vertical",
    r"a3\sounds_f\vehicles\noises\rain1_ext",
    r"a3\sounds_f\vehicles\air\noises\wind_closed",
    # sounds_f.pbo
    r"a3\sounds_f\weapons\rockets\titan_2",
}

_QUOTED = re.compile(r'"([^"]*\\[^"]*)"')


def fix(text):
    """Append .wss to every bare vanilla sound path in a config string."""
    unknown = set()

    def repl(m):
        s = m.group(1)
        low = s.lower()
        if not low.startswith("a3\\") or low.endswith(EXTS):
            return m.group(0)
        if "proxy:" in low or "#(" in low:
            return m.group(0)
        if low not in VERIFIED:
            unknown.add(s)
            return m.group(0)
        return '"%s.wss"' % s

    out = _QUOTED.sub(repl, text)
    if unknown:
        raise AssertionError(
            "extension-less vanilla path not in VERIFIED - look it up in the "
            "Arma PBOs and add it rather than guessing:\n  "
            + "\n  ".join(sorted(unknown))
        )
    return out
