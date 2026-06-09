#!/usr/bin/env python3
"""Generate 1024x1024 Zuvaro app icon: black mark on warm white gradient."""

import math
from pathlib import Path

from PIL import Image, ImageDraw

SIZE = 1024
MARK_COLOR = (10, 10, 15)
BG_TOP = (255, 255, 255)
BG_BOTTOM = (245, 240, 235)


def lerp(a: float, b: float, t: float) -> float:
    return a + (b - a) * t


def gradient_background() -> Image.Image:
    img = Image.new("RGB", (SIZE, SIZE))
    px = img.load()
    for y in range(SIZE):
        t = y / (SIZE - 1)
        r = int(lerp(BG_TOP[0], BG_BOTTOM[0], t))
        g = int(lerp(BG_TOP[1], BG_BOTTOM[1], t))
        b = int(lerp(BG_TOP[2], BG_BOTTOM[2], t))
        for x in range(SIZE):
            px[x, y] = (r, g, b)
    return img


def rotate_point(x: float, y: float, cx: float, cy: float, degrees: float) -> tuple[float, float]:
    rad = math.radians(degrees)
    cos_a, sin_a = math.cos(rad), math.sin(rad)
    dx, dy = x - cx, y - cy
    return cx + dx * cos_a - dy * sin_a, cy + dx * sin_a + dy * cos_a


def rounded_rect_points(x: float, y: float, w: float, h: float, r: float, steps: int = 24) -> list[tuple[float, float]]:
    points: list[tuple[float, float]] = []
    corners = [
        (x + w - r, y + r, 270, 360),
        (x + w - r, y + h - r, 0, 90),
        (x + r, y + h - r, 90, 180),
        (x + r, y + r, 180, 270),
    ]
    for cx, cy, start, end in corners:
        for i in range(steps // 4 + 1):
            ang = math.radians(start + (end - start) * i / (steps // 4))
            points.append((cx + r * math.cos(ang), cy + r * math.sin(ang)))
    points.append(points[0])
    return points


def draw_mark(draw: ImageDraw.ImageDraw, scale: float, offset: tuple[float, float]) -> None:
    ox, oy = offset
    stroke = max(4, int(7 * scale))

    def tx(x: float, y: float) -> tuple[float, float]:
        return ox + x * scale, oy + y * scale

    def pill_path(degrees: float) -> list[tuple[float, float]]:
        pts = rounded_rect_points(12, 38, 76, 24, 12)
        cx, cy = 50, 50
        return [rotate_point(px, py, cx, cy, degrees) for px, py in pts]

    for degrees in (-45, 45):
        path = [tx(px, py) for px, py in pill_path(degrees)]
        draw.line(path, fill=MARK_COLOR, width=stroke, joint="curve")

    arrow = [tx(76, 14), tx(86, 14), tx(86, 24)]
    draw.line(arrow, fill=MARK_COLOR, width=stroke, joint="curve")

    knot_cx, knot_cy = tx(62, 38)
    knot_r = 9.8 * scale
    draw.ellipse(
        (knot_cx - knot_r, knot_cy - knot_r, knot_cx + knot_r, knot_cy + knot_r),
        fill=BG_TOP,
    )


def main() -> None:
    out = Path(__file__).resolve().parents[1] / "Zuvaro/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png"
    img = gradient_background()
    draw = ImageDraw.Draw(img)
    mark_size = SIZE * 0.62
    scale = mark_size / 100
    offset = ((SIZE - mark_size) / 2, (SIZE - mark_size) / 2)
    draw_mark(draw, scale, offset)
    out.parent.mkdir(parents=True, exist_ok=True)
    img.save(out, "PNG")
    print(f"Wrote {out}")


if __name__ == "__main__":
    main()
