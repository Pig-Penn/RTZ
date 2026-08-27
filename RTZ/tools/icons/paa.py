"""Reading Arma's .paa texture container, in pure stdlib Python.

Only what RTZ's icons need: the largest mipmap of a DXT5 (type 0xff05) sheet,
LZO1X-decompressed if ImageToPAA flagged it so. Shared by icons.py (which reads
the shipped trashcan to rebuild it) and verify.py (which checks the results).
"""

import struct

RAMP = " .:-=+*#%@"


def lzo1x_decompress(src):
    """Decompress an LZO1X stream. Transcribed from the reference decoder in
    minilzo; its goto-driven control flow is kept as explicit state names so
    this stays checkable against the original."""
    op = bytearray()
    ip = 0

    def u16():
        return src[ip] | (src[ip + 1] << 8)

    def copy_match(dist, length):
        start = len(op) - dist
        if start < 0:
            raise ValueError("LZO: match distance %d exceeds output" % dist)
        for k in range(length):
            op.append(op[start + k])

    t = 0
    if src[ip] > 17:
        t = src[ip] - 17
        ip += 1
        if t < 4:
            state = "match_next"
        else:
            op.extend(src[ip:ip + t])
            ip += t
            state = "first_literal_run"
    else:
        state = "top"

    while True:
        if state == "top":
            t = src[ip]
            ip += 1
            if t < 16:
                if t == 0:
                    while src[ip] == 0:
                        t += 255
                        ip += 1
                    t += 15 + src[ip]
                    ip += 1
                op.extend(src[ip:ip + t + 3])
                ip += t + 3
                state = "first_literal_run"
                continue
            state = "match"
            continue

        if state == "first_literal_run":
            t = src[ip]
            ip += 1
            if t >= 16:
                state = "match"
                continue
            dist = 1 + 0x0800 + (t >> 2) + (src[ip] << 2)
            ip += 1
            copy_match(dist, 3)
            state = "match_done"
            continue

        if state == "match":
            if t >= 64:
                dist = 1 + ((t >> 2) & 7) + (src[ip] << 3)
                ip += 1
                copy_match(dist, (t >> 5) + 1)
            elif t >= 32:
                length = t & 31
                if length == 0:
                    while src[ip] == 0:
                        length += 255
                        ip += 1
                    length += 31 + src[ip]
                    ip += 1
                dist = 1 + (u16() >> 2)
                ip += 2
                copy_match(dist, length + 2)
            elif t >= 16:
                high = (t & 8) << 11
                length = t & 7
                if length == 0:
                    while src[ip] == 0:
                        length += 255
                        ip += 1
                    length += 7 + src[ip]
                    ip += 1
                low = u16() >> 2
                ip += 2
                if high == 0 and low == 0:
                    break  # end of stream
                copy_match(16384 + high + low, length + 2)
            else:
                dist = 1 + (t >> 2) + (src[ip] << 2)
                ip += 1
                copy_match(dist, 2)
            state = "match_done"
            continue

        if state == "match_done":
            t = src[ip - 2] & 3
            state = "top" if t == 0 else "match_next"
            continue

        if state == "match_next":
            op.extend(src[ip:ip + t])
            ip += t
            t = src[ip]
            ip += 1
            state = "match"
            continue

    return bytes(op)


def read_mip0(path):
    """Return (paa_type, width, height, was_lzo, block_bytes) for the largest mipmap."""
    with open(path, "rb") as handle:
        data = handle.read()

    paa_type = struct.unpack_from("<H", data, 0)[0]
    off = 2
    while data[off:off + 4] == b"GGAT":  # "TAGG" little-endian
        off += 12 + struct.unpack_from("<I", data, off + 8)[0]

    off += 2 + struct.unpack_from("<H", data, off)[0] * 3  # palette

    width, height = struct.unpack_from("<HH", data, off)
    lzo = bool(width & 0x8000)  # high bit of the width word flags LZO
    width &= 0x7FFF
    size = struct.unpack_from("<I", data, off + 4)[0] & 0xFFFFFF
    payload = data[off + 7:off + 7 + size]

    if lzo:
        payload = lzo1x_decompress(payload)
    return paa_type, width, height, lzo, payload


def decode_dxt5(data, width, height):
    """Return (alpha, rgb) as row-major 2D lists of ints / (r,g,b) tuples."""
    alpha = [[0] * width for _ in range(height)]
    rgb = [[(0, 0, 0)] * width for _ in range(height)]
    blocks_x = max(1, width // 4)

    def unpack565(c):
        return (((c >> 11) & 31) * 255 // 31,
                ((c >> 5) & 63) * 255 // 63,
                (c & 31) * 255 // 31)

    for i in range(0, min(len(data), width * height), 16):
        by, bx = divmod(i // 16, blocks_x)

        a0, a1 = data[i], data[i + 1]
        bits = int.from_bytes(data[i + 2:i + 8], "little")
        if a0 > a1:
            table = [a0, a1] + [((7 - k) * a0 + k * a1) // 7 for k in range(1, 7)]
        else:
            table = [a0, a1] + [((5 - k) * a0 + k * a1) // 5 for k in range(1, 5)] + [0, 255]

        c0, c1 = struct.unpack_from("<HH", data, i + 8)
        colour_bits = struct.unpack_from("<I", data, i + 12)[0]
        p0, p1 = unpack565(c0), unpack565(c1)
        palette = [p0, p1,
                   tuple((2 * p0[k] + p1[k]) // 3 for k in range(3)),
                   tuple((p0[k] + 2 * p1[k]) // 3 for k in range(3))]

        for t in range(16):
            y, x = by * 4 + t // 4, bx * 4 + t % 4
            if y < height and x < width:
                alpha[y][x] = table[(bits >> (3 * t)) & 7]
                rgb[y][x] = palette[(colour_bits >> (2 * t)) & 3]

    return alpha, rgb


def load_alpha(path):
    """Convenience: decode a .paa straight to (alpha, width, height)."""
    _, width, height, _, payload = read_mip0(path)
    alpha, _ = decode_dxt5(payload, width, height)
    return alpha, width, height


def ascii_render(alpha, width, height, size):
    """Box-filter the alpha channel down to `size` and map it onto RAMP -- a
    stand-in for how the engine will downsample the icon in the context menu."""
    out = []
    for j in range(size):
        y0, y1 = j * height // size, (j + 1) * height // size
        row = ""
        for i in range(size):
            x0, x1 = i * width // size, (i + 1) * width // size
            cells = [alpha[y][x] for y in range(y0, y1) for x in range(x0, x1)]
            row += RAMP[min(9, (sum(cells) // len(cells)) * 10 // 256)]
        out.append(row)
    return out
