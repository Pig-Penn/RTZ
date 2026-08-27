"""Check RTZ's .paa icons against the metrics that decide whether they read
well in ZEN's context menu.

ZEN draws these into an RscPicture roughly 18-24 px square and tints it with
ctrlSetTextColor, which multiplies the texture. So an icon is only as good as
its alpha channel, and its RGB must be white everywhere -- including in fully
transparent texels, whose colour still bleeds into the edge under bilinear
filtering and shows up as a dark fringe once the engine scales the sheet down.

Usage:
    python tools/icons/verify.py                 # the four RTZ icons
    python tools/icons/verify.py <file.paa> ...  # specific files
"""

import os
import sys

from paa import RAMP, ascii_render, decode_dxt5, read_mip0

# Targets every icon we own must hit. Derived from trash_ca.paa, which was the
# best of the four when this pipeline was written.
TARGET_SIZE = 128
INK_MIN, INK_MAX = 0.28, 0.36
VINSET_MIN, VINSET_MAX = 0.10, 0.13
HINSET_TOLERANCE = 0.01  # allowed L/R asymmetry, as a fraction of canvas width

# surrender_ca.paa is a verbatim copy of ACE3's, kept byte-identical for
# provenance (see captive/script_component.hpp). It has the same black-fringe
# defect the others had; that is a known, accepted trade and is reported as a
# note rather than a failure.
ICONS = [
    ("addons/control/ui/pause_ca.paa", None),
    ("addons/control/ui/play_ca.paa", None),
    ("addons/delete/ui/trash_ca.paa", None),
    ("addons/captive/ui/surrender_ca.paa", "verbatim ACE3 copy, deliberately not regenerated"),
]


def measure(alpha, rgb, width, height):
    ink = sum(1 for row in alpha for v in row if v > 127) / (width * height)
    rows = [y for y in range(height) if any(v > 16 for v in alpha[y])]
    cols = [x for x in range(width) if any(alpha[y][x] > 16 for y in range(height))]
    transparent = [rgb[y][x] for y in range(height) for x in range(width) if alpha[y][x] < 8]

    return {
        "ink": ink,
        "bbox": (cols[0], cols[-1], rows[0], rows[-1]),
        "inset": (cols[0] / width, (width - 1 - cols[-1]) / width,
                  rows[0] / height, (height - 1 - rows[-1]) / height),
        "darkest": min(transparent, key=sum) if transparent else None,
        "transparent_count": len(transparent),
    }


def check(path, m, width, height):
    problems = []
    if (width, height) != (TARGET_SIZE, TARGET_SIZE):
        problems.append("size %dx%d, want %dx%d"
                        % (width, height, TARGET_SIZE, TARGET_SIZE))

    if m["darkest"] is not None and m["darkest"] != (255, 255, 255):
        problems.append("transparent texels not white (darkest %s) -- will fringe"
                        % (m["darkest"],))

    if not INK_MIN <= m["ink"] <= INK_MAX:
        problems.append("ink %.1f%% outside %.0f-%.0f%%"
                        % (m["ink"] * 100, INK_MIN * 100, INK_MAX * 100))

    left, right, top, bottom = m["inset"]
    for name, value in (("top", top), ("bottom", bottom)):
        if not VINSET_MIN <= value <= VINSET_MAX:
            problems.append("%s inset %.1f%% outside %.0f-%.0f%%"
                            % (name, value * 100, VINSET_MIN * 100, VINSET_MAX * 100))

    # A play triangle is optically centred by sitting right of the geometric
    # centre, so only the symmetric glyphs are held to the symmetry rule.
    if "play" not in os.path.basename(path) and abs(left - right) > HINSET_TOLERANCE:
        problems.append("L/R insets differ by %.1f%% (max %.0f%%)"
                        % (abs(left - right) * 100, HINSET_TOLERANCE * 100))

    return problems


def main(argv):
    if argv:
        targets = [(p, None) for p in argv]
    else:
        root = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..")
        targets = [(os.path.normpath(os.path.join(root, p)), waived) for p, waived in ICONS]

    failures = 0
    renders = []

    for path, waived in targets:
        paa_type, width, height, lzo, payload = read_mip0(path)
        alpha, rgb = decode_dxt5(payload, width, height)
        m = measure(alpha, rgb, width, height)
        x0, x1, y0, y1 = m["bbox"]
        left, right, top, bottom = m["inset"]

        print("=" * 72)
        print("%s   %dx%d  type=%#x  mips=%s"
              % (os.path.basename(path), width, height, paa_type, "LZO" if lzo else "raw"))
        print("  bbox      x%d-%d y%d-%d" % (x0, x1, y0, y1))
        print("  inset     L%.1f%% R%.1f%% T%.1f%% B%.1f%%"
              % (left * 100, right * 100, top * 100, bottom * 100))
        print("  ink@50%%   %.1f%%" % (m["ink"] * 100))
        print("  alpha=0   darkest RGB %s  (%d texels)" % (m["darkest"], m["transparent_count"]))

        problems = check(path, m, width, height)
        if not problems:
            print("  PASS      all checks")
        elif waived:
            for p in problems:
                print("  NOTE      %s" % p)
            print("  WAIVED    %s" % waived)
        else:
            failures += len(problems)
            for p in problems:
                print("  FAIL      %s" % p)

        renders.append((os.path.basename(path), ascii_render(alpha, width, height, 20)))

    print("=" * 72)
    print("Menu-size simulation (20 px), side by side:\n")
    print("  " + "".join(n[:20].ljust(22) for n, _ in renders))
    for j in range(20):
        print("  " + "".join(r[j].ljust(22) for _, r in renders))

    print()
    print("%d check(s) failed." % failures if failures else "All checks passed.")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
