"""Generate RTZ's context-menu icons as 128x128 RGBA PNGs, ready for ImageToPAA.

ZEN tints these with ctrlSetTextColor on an RscPicture, which multiplies the
texture, so the glyph lives entirely in the alpha channel and RGB is flooded
white -- including where alpha is 0. Transparent texels still contribute colour
under bilinear filtering, and black ones show up as a dark fringe once the
engine scales the sheet down to the ~20 px the menu actually draws.

Antialiasing comes from signed distance fields rather than supersampling: for a
rounded rect or rounded polygon the exact distance is cheap and gives a clean
one-pixel ramp on the play triangle's diagonals, where the old 64 px asset had
a visible staircase. Axis-aligned edges are placed on integer boundaries so
they stay perfectly hard.

Usage:
    python tools/icons/icons.py [outdir]      # default: tools/icons/build
"""

import math
import os
import struct
import sys
import zlib

import paa

SIZE = 128


# --------------------------------------------------------------------------
# PNG output
# --------------------------------------------------------------------------

def _png(path, width, height, colour_type, raw):
    def chunk(tag, payload):
        return (struct.pack(">I", len(payload)) + tag + payload
                + struct.pack(">I", zlib.crc32(tag + payload) & 0xFFFFFFFF))

    header = struct.pack(">IIBBBBB", width, height, 8, colour_type, 0, 0, 0)
    with open(path, "wb") as handle:
        handle.write(b"\x89PNG\r\n\x1a\n")
        handle.write(chunk(b"IHDR", header))
        handle.write(chunk(b"IDAT", zlib.compress(bytes(raw), 9)))
        handle.write(chunk(b"IEND", b""))


def read_png_alpha(path):
    """Read the alpha channel of an 8-bit RGBA PNG written by write_png.
    Only the non-interlaced, filter-0 form this module emits is supported."""
    with open(path, "rb") as handle:
        data = handle.read()

    pos, idat, width, height = 8, b"", 0, 0
    while pos < len(data):
        length = struct.unpack_from(">I", data, pos)[0]
        tag = data[pos + 4:pos + 8]
        payload = data[pos + 8:pos + 8 + length]
        if tag == b"IHDR":
            width, height, depth, colour = struct.unpack_from(">IIBB", payload, 0)
            if (depth, colour) != (8, 6):
                raise SystemExit("%s: expected 8-bit RGBA" % path)
        elif tag == b"IDAT":
            idat += payload
        pos += 12 + length

    raw = zlib.decompress(idat)
    stride = width * 4 + 1
    for y in range(height):
        if raw[y * stride] != 0:
            raise SystemExit("%s: unsupported PNG row filter" % path)
    return [[raw[y * stride + 1 + x * 4 + 3] for x in range(width)] for y in range(height)]


def write_png(path, alpha, size=SIZE):
    """Write the deliverable: 8-bit RGBA, colour white everywhere."""
    raw = bytearray()
    for y in range(size):
        raw.append(0)  # filter: none
        row = alpha[y]
        for x in range(size):
            raw += b"\xff\xff\xff"
            raw.append(row[x])
    _png(path, size, size, 6, raw)


def write_preview(path, alpha, size=SIZE, scale=3, menu=20):
    """Write an opaque preview -- the glyph is white on transparent, so it is
    invisible in any normal image viewer. Left panel is the full-resolution
    sheet, right panel is the same alpha box-filtered to `menu` px and blown
    back up, i.e. what the context menu actually shows."""
    small = []
    for j in range(menu):
        y0, y1 = j * size // menu, (j + 1) * size // menu
        small.append([sum(alpha[y][x] for y in range(y0, y1)
                          for x in range(i * size // menu, (i + 1) * size // menu))
                      // ((y1 - y0) * ((i + 1) * size // menu - i * size // menu))
                      for i in range(menu)])

    panel = size * scale
    gap = 8
    width, height = panel * 2 + gap, panel
    raw = bytearray()
    for y in range(height):
        raw.append(0)
        for x in range(width):
            if x < panel:
                a = alpha[y // scale][x // scale]
            elif x < panel + gap:
                raw += b"\x80\x80\x80"
                continue
            else:
                px = x - panel - gap
                a = small[(y * menu) // panel][(px * menu) // panel]
            # Dark glyph on a light ground, so the silhouette is legible.
            v = 235 - (215 * a) // 255
            raw += bytes((v, v, v))
    _png(path, width, height, 2, raw)


# --------------------------------------------------------------------------
# Signed distance fields
# --------------------------------------------------------------------------

def sd_rounded_rect(px, py, x0, y0, x1, y1, r):
    cx, cy = (x0 + x1) / 2.0, (y0 + y1) / 2.0
    hx, hy = (x1 - x0) / 2.0 - r, (y1 - y0) / 2.0 - r
    qx, qy = abs(px - cx) - hx, abs(py - cy) - hy
    outside = math.hypot(max(qx, 0.0), max(qy, 0.0))
    return outside + min(max(qx, qy), 0.0) - r


def sd_polygon(px, py, verts):
    """Exact signed distance to a simple polygon (negative inside)."""
    n = len(verts)
    d = (px - verts[0][0]) ** 2 + (py - verts[0][1]) ** 2
    sign = 1.0
    j = n - 1
    for i in range(n):
        vix, viy = verts[i]
        vjx, vjy = verts[j]
        ex, ey = vjx - vix, vjy - viy
        wx, wy = px - vix, py - viy
        t = (wx * ex + wy * ey) / (ex * ex + ey * ey)
        t = 0.0 if t < 0.0 else (1.0 if t > 1.0 else t)
        bx, by = wx - ex * t, wy - ey * t
        d = min(d, bx * bx + by * by)

        c1, c2, c3 = py >= viy, py < vjy, ex * wy > ey * wx
        if (c1 and c2 and c3) or not (c1 or c2 or c3):
            sign = -sign
        j = i
    return sign * math.sqrt(d)


def offset_inward(verts, r):
    """Shrink a polygon by r, by moving each edge inward and re-intersecting.
    Rounding is then applied as `sd_polygon(...) - r`, which restores the
    original outline everywhere except at the corners.

    Winding is taken from the shoelace sign rather than assumed, so the normal
    points into the shape either way."""
    n = len(verts)
    area = 0.5 * sum(verts[i][0] * verts[(i + 1) % n][1] - verts[(i + 1) % n][0] * verts[i][1]
                     for i in range(n))
    winding = 1.0 if area < 0 else -1.0

    lines = []
    for i in range(n):
        (ax, ay), (bx, by) = verts[i], verts[(i + 1) % n]
        ex, ey = bx - ax, by - ay
        length = math.hypot(ex, ey)
        nx, ny = winding * ey / length, -winding * ex / length
        lines.append((ax + nx * r, ay + ny * r, ex, ey))

    out = []
    for i in range(n):
        px1, py1, dx1, dy1 = lines[i - 1]
        px2, py2, dx2, dy2 = lines[i]
        denom = dx1 * dy2 - dy1 * dx2
        t = ((px2 - px1) * dy2 - (py2 - py1) * dx2) / denom
        out.append((px1 + dx1 * t, py1 + dy1 * t))
    return out


def rasterize(shapes, size=SIZE):
    """shapes: callables (px, py) -> signed distance. Union via min()."""
    alpha = [[0] * size for _ in range(size)]
    for y in range(size):
        py = y + 0.5
        row = alpha[y]
        for x in range(size):
            px = x + 0.5
            d = min(shape(px, py) for shape in shapes)
            cov = 0.5 - d
            row[x] = 0 if cov <= 0.0 else (255 if cov >= 1.0 else int(cov * 255 + 0.5))
    return alpha


# --------------------------------------------------------------------------
# The glyphs
# --------------------------------------------------------------------------

# Shared metrics. The vertical extent matches trash_ca.paa's measured 100-px
# body (y14..114), which is what keeps all three icons the same optical size.
TOP, BOTTOM = 14, 114
RADIUS = 6

# Two bars, symmetric about x=64. 28 wide with a 22 gap = 78 total, giving a
# 34.2% ink fraction -- deliberately close to the solid trashcan's, since these
# two sit in the same submenu.
PAUSE_BAR, PAUSE_GAP = 28, 22

# The triangle is specified as its sharp outline; rounding then pulls the three
# corners in, so these numbers are deliberately larger than the box the glyph
# ends up occupying. As rendered it lands on x23-111 y14-113 -- the same 100-px
# vertical extent as the pause bars, at 30.1% ink.
#
# It is wider than a typographic play glyph on purpose: Material's 0.79 aspect
# would drop it to ~24% ink and it would read visibly lighter than the bars it
# alternates with. And it sits 3 px right of centre (L/R inset 1.44), because a
# triangle is optically centred nearer its centroid than its bounding box --
# but only 3 px, since squadHideActionModifier swaps pause and play into the
# same menu row and a larger offset would make that row visibly jump.
PLAY_LEFT, PLAY_WIDTH = 23, 94
PLAY_TOP, PLAY_BOTTOM = 11, 117
PLAY_RADIUS = 5


def build_pause():
    total = 2 * PAUSE_BAR + PAUSE_GAP
    left = (SIZE - total) // 2
    x0a, x1a = left, left + PAUSE_BAR
    x0b, x1b = x1a + PAUSE_GAP, x1a + PAUSE_GAP + PAUSE_BAR
    return rasterize([
        lambda px, py: sd_rounded_rect(px, py, x0a, TOP, x1a, BOTTOM, RADIUS),
        lambda px, py: sd_rounded_rect(px, py, x0b, TOP, x1b, BOTTOM, RADIUS),
    ])


def build_play():
    apex = PLAY_LEFT + PLAY_WIDTH
    verts = [(PLAY_LEFT, PLAY_TOP),
             (apex, (PLAY_TOP + PLAY_BOTTOM) / 2.0),
             (PLAY_LEFT, PLAY_BOTTOM)]
    inner = offset_inward(verts, PLAY_RADIUS)
    return rasterize([lambda px, py: sd_polygon(px, py, inner) - PLAY_RADIUS])


def close_slots(alpha, width, height):
    """Fill each row solid between its own outermost opaque texels.

    This is how the trashcan was rebuilt: by subtraction, not redesign. The
    silhouette is kept pixel-for-pixel -- handle, lid, lid gap and the tapered
    body all stay exactly where they were -- and only the three vertical slots
    in the body close up. Those slots contradicted the brief in
    delete/script_component.hpp: at the ~18 px the menu draws, they averaged
    out to grey and left the can washed out beside solid neighbours.

    Filling strictly *between* the outermost opaque texels leaves the
    antialiased outer edge untouched, so the outline keeps its softness."""
    filled = 0
    for y in range(height):
        row = alpha[y]
        ink = [x for x in range(width) if row[x] > 127]
        if not ink:
            continue
        for x in range(ink[0] + 1, ink[-1]):
            if row[x] != 255:
                row[x] = 255
                filled += 1
    return filled


def derive_trash(source, dest):
    """One-shot: regenerate the checked-in trashcan source from a .paa.

    Not part of the normal build. build_trash reads the PNG this writes, so
    that the pipeline is deterministic -- deriving from the .paa on every run
    would mean re-reading our own output and compounding a DXT5 generation
    each time."""
    alpha, width, height = paa.load_alpha(source)
    if (width, height) != (SIZE, SIZE):
        raise SystemExit("expected %dx%d source, got %dx%d" % (SIZE, SIZE, width, height))
    filled = close_slots(alpha, width, height)
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    write_png(dest, alpha)
    print("derived %s from %s (%d interior texels filled)" % (dest, source, filled))


def build_trash(source):
    """The trashcan is not synthesised -- it is a hand-shaped silhouette, so
    its alpha is checked in as a PNG and passed through unchanged."""
    return read_png_alpha(source)


def main(argv):
    here = os.path.dirname(os.path.abspath(__file__))
    trash_src = os.path.join(here, "src", "trash_ca.png")

    if argv and argv[0] == "--derive-trash":
        if len(argv) != 2:
            raise SystemExit("usage: icons.py --derive-trash <old_trash_ca.paa>")
        derive_trash(argv[1], trash_src)
        return 0

    outdir = argv[0] if argv else os.path.join(here, "build")
    os.makedirs(outdir, exist_ok=True)

    targets = [
        ("pause_ca.png", build_pause()),
        ("play_ca.png", build_play()),
        ("trash_ca.png", build_trash(trash_src)),
    ]

    for name, alpha in targets:
        path = os.path.join(outdir, name)
        write_png(path, alpha)
        write_preview(os.path.join(outdir, name.replace(".png", "_preview.png")), alpha)
        ink = sum(1 for row in alpha for v in row if v > 127) / float(SIZE * SIZE)
        rows = [y for y in range(SIZE) if any(v > 16 for v in alpha[y])]
        cols = [x for x in range(SIZE) if any(alpha[y][x] > 16 for y in range(SIZE))]
        print("%-14s ink %.1f%%  bbox x%d-%d y%d-%d  inset L%.1f%% R%.1f%% T%.1f%% B%.1f%%"
              % (name, ink * 100, cols[0], cols[-1], rows[0], rows[-1],
                 cols[0] * 100.0 / SIZE, (SIZE - 1 - cols[-1]) * 100.0 / SIZE,
                 rows[0] * 100.0 / SIZE, (SIZE - 1 - rows[-1]) * 100.0 / SIZE))

    print("\nWrote %d PNGs to %s" % (len(targets), outdir))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
