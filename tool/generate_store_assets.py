"""Generate Google Play listing screenshots for Packing List."""
from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "store_assets"
SIZE = (1080, 1920)

INDIGO = (67, 56, 202)
VIOLET = (129, 140, 248)
CORAL = (251, 113, 133)
TEAL = (45, 212, 191)
GOLD = (251, 191, 36)
WHITE = (255, 255, 255)
DEEP = (49, 46, 129)
CREAM = (250, 250, 254)


def load_font(size: int, bold: bool = False):
    for path in [
        "C:/Windows/Fonts/segoeuib.ttf" if bold else "C:/Windows/Fonts/segoeui.ttf",
        "C:/Windows/Fonts/arialbd.ttf" if bold else "C:/Windows/Fonts/arial.ttf",
    ]:
        if Path(path).exists():
            return ImageFont.truetype(path, size)
    return ImageFont.load_default()


def gradient_bg() -> Image.Image:
    img = Image.new("RGB", SIZE)
    px = img.load()
    for y in range(SIZE[1]):
        for x in range(SIZE[0]):
            t = x / SIZE[0] * 0.35 + y / SIZE[1] * 0.65
            r = int(DEEP[0] + (INDIGO[0] - DEEP[0]) * t)
            g = int(DEEP[1] + (VIOLET[1] - DEEP[1]) * t)
            b = int(DEEP[2] + (VIOLET[2] - DEEP[2]) * t)
            px[x, y] = (r, g, b)
    return img


def header(draw, title, subtitle):
    draw.text((72, 120), title, fill=WHITE, font=load_font(58, bold=True))
    draw.text((72, 200), subtitle, fill=(230, 230, 255), font=load_font(32))


def save(name, img):
    OUT.mkdir(parents=True, exist_ok=True)
    path = OUT / name
    img.save(path, optimize=True)
    print(f"Saved {path}")


def shot_home() -> None:
    img = gradient_bg()
    draw = ImageDraw.Draw(img)
    header(draw, "Packing List", "Smart packing checklist")
    templates = [("Beach trip", CORAL), ("Business", INDIGO), ("Camping", TEAL)]
    y = 380
    for label, color in templates:
        draw.rounded_rectangle((72, y, 1008, y + 140), radius=24, fill=CREAM)
        draw.rounded_rectangle((100, y + 30, 160, y + 90), radius=16, fill=color)
        draw.text((190, y + 45), label, fill=DEEP, font=load_font(36, bold=True))
        y += 160
    save("01_home.png", img)


def shot_checklist() -> None:
    img = gradient_bg()
    draw = ImageDraw.Draw(img)
    header(draw, "Check off items", "Never forget essentials")
    items = ["Sunscreen SPF 50+", "Swimsuit", "Sandals", "Beach towel", "Phone charger"]
    y = 380
    for i, label in enumerate(items):
        draw.rounded_rectangle((72, y, 1008, y + 100), radius=20, fill=CREAM)
        draw.rectangle((100, y + 30, 130, y + 60), fill=TEAL if i < 2 else (200, 200, 220))
        draw.text((160, y + 32), label, fill=DEEP, font=load_font(32, bold=True))
        y += 120
    save("02_checklist.png", img)


def shot_shop() -> None:
    img = gradient_bg()
    draw = ImageDraw.Draw(img)
    header(draw, "Star Shop", "Earn stars or buy via Google Play")
    cards = [("Remove ads", "500 ★"), ("Midnight theme", "200 ★"), ("Unlimited lists", "300 ★")]
    y = 380
    for title, price in cards:
        draw.rounded_rectangle((72, y, 1008, y + 170), radius=24, fill=(255, 255, 255, 30), outline=GOLD, width=2)
        draw.text((110, y + 36), title, fill=WHITE, font=load_font(36, bold=True))
        draw.text((110, y + 96), price, fill=GOLD, font=load_font(30, bold=True))
        y += 200
    save("03_shop.png", img)


def main() -> None:
    shot_home()
    shot_checklist()
    shot_shop()


if __name__ == "__main__":
    main()
