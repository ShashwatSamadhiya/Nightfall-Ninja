"""Generate the app icon for the runner game (matches in-game art)."""
import os
from PIL import Image, ImageDraw

SS = 4          # supersample factor for smooth edges
SIZE = 1024
S = SIZE * SS
OUT = "/Users/farmsetu/Desktop/game/assets/icon"

SKY_TOP = (0x4F, 0xC3, 0xF7)
SKY_BOT = (0xB3, 0xE5, 0xFC)


def draw_coin(d, cx, cy, r):
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill="#F9A825")
    r2 = r * 0.72
    d.ellipse([cx - r2, cy - r2, cx + r2, cy + r2], fill="#FDD835")
    hx, hy, hr = cx - r * 0.3, cy - r * 0.35, r * 0.22
    d.ellipse([hx - hr, hy - hr, hx + hr, hy + hr], fill="#FFF9C4")


def draw_character(d, cx, cy, u):
    """Body is ~400x380 units at u=1, centred on (cx, cy)."""
    # Headband ribbons trailing left.
    d.polygon(
        [(cx - 190 * u, cy - 130 * u), (cx - 360 * u, cy - 190 * u),
         (cx - 320 * u, cy - 100 * u), (cx - 190 * u, cy - 85 * u)],
        fill="#D32F2F",
    )
    d.polygon(
        [(cx - 190 * u, cy - 105 * u), (cx - 330 * u, cy - 20 * u),
         (cx - 280 * u, cy - 70 * u), (cx - 190 * u, cy - 60 * u)],
        fill="#B71C1C",
    )
    # Legs.
    d.rounded_rectangle(
        [cx - 95 * u, cy + 150 * u, cx - 25 * u, cy + 280 * u],
        radius=30 * u, fill="#BF360C",
    )
    d.rounded_rectangle(
        [cx + 25 * u, cy + 150 * u, cx + 95 * u, cy + 280 * u],
        radius=30 * u, fill="#BF360C",
    )
    # Body.
    d.rounded_rectangle(
        [cx - 200 * u, cy - 190 * u, cx + 200 * u, cy + 190 * u],
        radius=120 * u, fill="#FF7043",
    )
    # Belly highlight.
    d.ellipse(
        [cx - 120 * u, cy + 20 * u, cx + 90 * u, cy + 170 * u],
        fill="#FFAB91",
    )
    # Headband.
    d.rounded_rectangle(
        [cx - 200 * u, cy - 145 * u, cx + 200 * u, cy - 80 * u],
        radius=32 * u, fill="#D32F2F",
    )
    # Eye.
    d.ellipse(
        [cx + 20 * u, cy - 100 * u, cx + 160 * u, cy + 40 * u], fill="white"
    )
    d.ellipse(
        [cx + 90 * u, cy - 62 * u, cx + 154 * u, cy + 2 * u], fill="#263238"
    )


def main():
    os.makedirs(OUT, exist_ok=True)

    # --- Full icon with background --------------------------------------
    img = Image.new("RGB", (S, S))
    d = ImageDraw.Draw(img)
    ground_y = int(S * 0.80)
    for y in range(ground_y):
        t = y / ground_y
        d.line(
            [(0, y), (S, y)],
            fill=tuple(int(a + (b - a) * t) for a, b in zip(SKY_TOP, SKY_BOT)),
        )
    # Sun.
    sx, sy = S * 0.79, S * 0.19
    d.ellipse([sx - S * 0.11, sy - S * 0.11, sx + S * 0.11, sy + S * 0.11],
              fill="#FFF59D")
    d.ellipse([sx - S * 0.08, sy - S * 0.08, sx + S * 0.08, sy + S * 0.08],
              fill="#FFEE58")
    # Hills behind the ground.
    d.ellipse([-S * 0.25, S * 0.62, S * 0.55, S * 1.0], fill="#A5D6A7")
    d.ellipse([S * 0.45, S * 0.66, S * 1.25, S * 1.05], fill="#81C784")
    # Ground.
    d.rectangle([0, ground_y, S, S], fill="#795548")
    d.rectangle([0, ground_y, S, ground_y + int(S * 0.035)], fill="#66BB6A")
    # Coin and character.
    draw_coin(d, S * 0.21, S * 0.24, S * 0.085)
    draw_character(d, S * 0.5, S * 0.52, S / 1024 * 0.95)
    img = img.resize((SIZE, SIZE), Image.LANCZOS)
    img.save(os.path.join(OUT, "icon.png"))

    # --- Adaptive-icon foreground (transparent, inside safe zone) -------
    fg = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(fg)
    draw_coin(d, S * 0.30, S * 0.30, S * 0.06)
    draw_character(d, S * 0.52, S * 0.54, S / 1024 * 0.62)
    fg = fg.resize((SIZE, SIZE), Image.LANCZOS)
    fg.save(os.path.join(OUT, "icon_fg.png"))

    for f in ("icon.png", "icon_fg.png"):
        print(f, os.path.getsize(os.path.join(OUT, f)) // 1024, "KB")


main()
