#!/usr/bin/env python3
"""Generate the placeholder app icon: dark purple background, neon ring, equalizer bars.

Standard library only. Usage: python3 scripts/generate_app_icon.py   (run from ios/)
"""
import math
import os
import struct
import zlib

SIZE = 1024
OUT = os.path.join(os.path.dirname(__file__), "..", "MoodStream", "Resources",
                   "Assets.xcassets", "AppIcon.appiconset", "AppIcon.png")

BG_CENTER = (48, 16, 82)
BG_EDGE = (11, 7, 18)
NEON = (177, 78, 255)
BARS = [0.30, 0.55, 0.80, 0.50, 0.65]  # relative heights


def mix(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def pixel(x, y):
    cx = cy = SIZE / 2
    d = math.hypot(x - cx, y - cy) / (SIZE / 2)
    color = mix(BG_CENTER, BG_EDGE, min(d, 1.0))
    # Neon ring with glow.
    ring = abs(d - 0.72)
    glow = math.exp(-(ring * 40) ** 2) + 0.35 * math.exp(-(ring * 12) ** 2)
    color = mix(color, NEON, min(glow, 1.0))
    # Equalizer bars in the middle.
    bar_w, gap = 56, 28
    total = len(BARS) * bar_w + (len(BARS) - 1) * gap
    left = cx - total / 2
    base = cy + 150
    for i, h in enumerate(BARS):
        x0 = left + i * (bar_w + gap)
        if x0 <= x < x0 + bar_w and base - h * 380 <= y < base:
            return mix(NEON, (255, 255, 255), 0.25 + 0.3 * (base - y) / 380)
    return color


def main():
    rows = []
    for y in range(SIZE):
        row = bytearray([0])
        for x in range(SIZE):
            row.extend(pixel(x, y))
        rows.append(bytes(row))

    def chunk(tag, data):
        return struct.pack(">I", len(data)) + tag + data + struct.pack(">I", zlib.crc32(tag + data) & 0xFFFFFFFF)

    png = b"\x89PNG\r\n\x1a\n"
    png += chunk(b"IHDR", struct.pack(">IIBBBBB", SIZE, SIZE, 8, 2, 0, 0, 0))
    png += chunk(b"IDAT", zlib.compress(b"".join(rows), 9))
    png += chunk(b"IEND", b"")
    with open(OUT, "wb") as f:
        f.write(png)
    print("wrote", os.path.relpath(OUT))


if __name__ == "__main__":
    main()
