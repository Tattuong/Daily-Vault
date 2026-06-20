"""Generate Daily Vault square app logo (1024x1024, sharp corners)."""
from __future__ import annotations

import math
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter

SIZE = 1024
OUT = Path(__file__).resolve().parents[1] / "assets" / "logo.png"

NAVY_DEEP = (11, 18, 32)
NAVY = (30, 58, 95)
BLUE = (37, 99, 235)
BLUE_LIGHT = (96, 165, 250)
TEAL = (20, 184, 166)
GOLD = (251, 191, 36)
WHITE = (255, 255, 255)


def lerp(a: int, b: int, t: float) -> int:
    return int(a + (b - a) * t)


def square_gradient(size: int) -> Image.Image:
    img = Image.new("RGB", (size, size))
    px = img.load()
    for y in range(size):
        for x in range(size):
            t = x / size * 0.45 + y / size * 0.55
            r = lerp(NAVY_DEEP[0], BLUE[0], t * 0.9)
            g = lerp(NAVY_DEEP[1], BLUE_LIGHT[1], t * 0.75)
            b = lerp(NAVY[2], TEAL[2], t * 0.6)
            px[x, y] = (r, g, b)
    return img


def draw_shield(draw: ImageDraw.ImageDraw) -> None:
    # Shield body
    shield = [
        (512, 180),
        (720, 260),
        (700, 520),
        (512, 760),
        (324, 520),
        (304, 260),
    ]
    draw.polygon(shield, fill=WHITE + (240,))
    draw.polygon(shield, outline=BLUE_LIGHT + (200,), width=8)

    # Inner shield gradient band
    inner = [
        (512, 240),
        (660, 300),
        (645, 490),
        (512, 680),
        (379, 490),
        (364, 300),
    ]
    draw.polygon(inner, fill=BLUE + (60,))


def draw_lock(draw: ImageDraw.ImageDraw) -> None:
    # Lock shackle
    draw.arc((432, 340, 592, 500), start=180, end=0, fill=NAVY + (255,), width=22)
    # Lock body
    draw.rounded_rectangle((400, 460, 624, 620), radius=28, fill=BLUE + (255,))
    draw.rounded_rectangle((400, 460, 624, 620), radius=28, outline=BLUE_LIGHT + (200,), width=6)
    # Keyhole
    draw.ellipse((488, 510, 536, 558), fill=WHITE + (255,))
    draw.rectangle((506, 540, 518, 590), fill=WHITE + (255,))


def draw_star(draw: ImageDraw.ImageDraw) -> None:
    cx, cy = 780, 280
    points = []
    for i in range(5):
        angle = math.radians(-90 + i * 72)
        points.append((cx + 34 * math.cos(angle), cy + 34 * math.sin(angle)))
        angle2 = math.radians(-90 + i * 72 + 36)
        points.append((cx + 14 * math.cos(angle2), cy + 14 * math.sin(angle2)))
    draw.polygon(points, fill=GOLD + (255,))


def main() -> None:
    base = square_gradient(SIZE).convert("RGBA")
    overlay = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    draw_shield(draw)
    draw_lock(draw)
    draw_star(draw)

    glow = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    glow_draw.ellipse((340, 200, 684, 540), fill=(255, 255, 255, 30))
    glow = glow.filter(ImageFilter.GaussianBlur(50))

    composed = Image.alpha_composite(base, glow)
    composed = Image.alpha_composite(composed, overlay)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    composed.convert("RGB").save(OUT, format="PNG", optimize=True)
    print(f"Saved Daily Vault logo: {OUT} ({SIZE}x{SIZE})")


if __name__ == "__main__":
    main()
