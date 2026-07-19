"""تولید آیکن منبع برنامه (assets/icon/app_icon.png) با Pillow.

الگو: پس‌زمینه گرادیانی نئون + گوشه‌های گرد + شبکهٔ دکمه تزئینی + نماد "=" درخشان.
اجرا: `python3 tool/generate_icon.py` از ریشهٔ پروژه.
"""

import os

from PIL import Image, ImageDraw, ImageFilter

SIZE = 1024
OUTPUT_PATH = os.path.join("assets", "icon", "app_icon.png")


def build_icon() -> Image.Image:
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    top_color = (10, 14, 33)
    bottom_color = (22, 33, 62)
    for y in range(SIZE):
        t = y / SIZE
        r = int(top_color[0] + (bottom_color[0] - top_color[0]) * t)
        g = int(top_color[1] + (bottom_color[1] - top_color[1]) * t)
        b = int(top_color[2] + (bottom_color[2] - top_color[2]) * t)
        draw.line([(0, y), (SIZE, y)], fill=(r, g, b, 255))

    radius = 180
    mask = Image.new("L", (SIZE, SIZE), 0)
    mask_draw = ImageDraw.Draw(mask)
    mask_draw.rounded_rectangle([(0, 0), (SIZE, SIZE)], radius=radius, fill=255)
    img.putalpha(mask)

    draw = ImageDraw.Draw(img)

    button_color = (255, 255, 255, 30)
    start_x, start_y = 130, 130
    btn_size = 90
    gap = 30
    for row in range(2):
        for col in range(3):
            x0 = start_x + col * (btn_size + gap)
            y0 = start_y + row * (btn_size + gap)
            draw.rounded_rectangle(
                [x0, y0, x0 + btn_size, y0 + btn_size], radius=20, fill=button_color
            )

    eq_color = (0, 245, 212, 255)
    bar_w, bar_h = 420, 60
    cx, cy = SIZE // 2, SIZE // 2 + 120
    gap_eq = 50

    glow = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    glow_draw.rounded_rectangle(
        [cx - bar_w // 2, cy - gap_eq // 2 - bar_h, cx + bar_w // 2, cy - gap_eq // 2],
        radius=18,
        fill=eq_color,
    )
    glow_draw.rounded_rectangle(
        [cx - bar_w // 2, cy + gap_eq // 2, cx + bar_w // 2, cy + gap_eq // 2 + bar_h],
        radius=18,
        fill=eq_color,
    )
    glow = glow.filter(ImageFilter.GaussianBlur(30))

    final = Image.alpha_composite(glow, img)
    final_draw = ImageDraw.Draw(final)
    final_draw.rounded_rectangle(
        [cx - bar_w // 2, cy - gap_eq // 2 - bar_h, cx + bar_w // 2, cy - gap_eq // 2],
        radius=18,
        fill=eq_color,
    )
    final_draw.rounded_rectangle(
        [cx - bar_w // 2, cy + gap_eq // 2, cx + bar_w // 2, cy + gap_eq // 2 + bar_h],
        radius=18,
        fill=eq_color,
    )
    return final


def main() -> None:
    os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)
    icon = build_icon()
    icon.save(OUTPUT_PATH)
    print(f"icon generated: {OUTPUT_PATH}")


if __name__ == "__main__":
    main()
