#!/usr/bin/env python3
"""يولّد الأصول الهندسية المتكررة (الحجارة، عجلة الطبق، الأطباق، الأيقونات)
في assets/svg. الأصول المتكررة تُبنى رياضياً بدل رسمها يدوياً.

المرجع البصري: اللقطات المرفقة (لوحة السيجا السودانية).
الاستخدام: python3 tools/gen_art.py
"""
import math
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SVG = os.path.join(ROOT, "assets", "svg")
os.makedirs(SVG, exist_ok=True)


def write(name, body):
    with open(os.path.join(SVG, name), "w", encoding="utf-8") as fh:
        fh.write(body)
    print("->", name)


# ---------------------------------------------------------------- الحجارة
# الشكل بيضيّ لامع (كما في المرجع) مع ظل سفلي ولمعة علوية.
STONES = {
    # الألوان مطابقة تماماً لـ SudaneseTheme.pebbles في lib/theme/sudanese_theme.dart
    "indigo": ("#1D2A5B", "#3A4E8C", "#101838"),
    "clay": ("#B4552D", "#D2754B", "#843A1D"),
    "green": ("#1F6B3A", "#2E8B4F", "#124C27"),
    "red": ("#B3261E", "#D24038", "#821713"),
    "turquoise": ("#1AA3A8", "#33C6CB", "#0F6C70"),
    "ochre": ("#E58A1F", "#F5AC55", "#AE650F"),
    "charcoal": ("#3A3230", "#584C46", "#221C1A"),
}


def stone_svg(base, light, dark):
    """حجر بيض: قاعدة عريضة تتجه إلى قمة مدببة."""
    return f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 120 120" width="120" height="120">
  <defs>
    <radialGradient id="g" cx="0.36" cy="0.28" r="0.82">
      <stop offset="0" stop-color="{light}"/>
      <stop offset="0.52" stop-color="{base}"/>
      <stop offset="1" stop-color="{dark}"/>
    </radialGradient>
    <clipPath id="c">
      <path d="M60,8 C79,8 96,28 98,52 C100,80 84,104 60,104 C36,104 20,80 22,52 C24,28 41,8 60,8 Z"/>
    </clipPath>
  </defs>
  <ellipse cx="60" cy="104" rx="36" ry="8" fill="#000000" opacity="0.22"/>
  <path d="M60,8 C79,8 96,28 98,52 C100,80 84,104 60,104 C36,104 20,80 22,52 C24,28 41,8 60,8 Z" fill="url(#g)"/>
  <g clip-path="url(#c)">
    <ellipse cx="44" cy="42" rx="15" ry="11" fill="#FFFFFF" opacity="0.30" transform="rotate(-22 44 42)"/>
    <ellipse cx="70" cy="86" rx="30" ry="16" fill="{dark}" opacity="0.45"/>
  </g>
  <ellipse cx="41" cy="33" rx="9" ry="6" fill="#FFFFFF" opacity="0.75" transform="rotate(-24 41 33)"/>
  <circle cx="52" cy="46" r="3.2" fill="#FFFFFF" opacity="0.30"/>
</svg>
"""


for name, (base, light, dark) in STONES.items():
    write(f"stone_{name}.svg", stone_svg(base, light, dark))


# ------------------------------------------------------- عجلة الطبق (تاباق)
def square_ring(cx, cy, radius, color, count, size, rot=0.0):
    """حلقة مربعات صغيرة (موTiles) حول المركز."""
    out = []
    step = 360.0 / count
    for i in range(count):
        a = math.radians(i * step + rot)
        x = cx + radius * math.cos(a)
        y = cy + radius * math.sin(a)
        out.append(
            f'<rect x="{x - size / 2:.2f}" y="{y - size / 2:.2f}" width="{size}" '
            f'height="{size}" rx="{size * 0.18:.2f}" fill="{color}" '
            f'transform="rotate({i * step:.2f} {x:.2f} {y:.2f})"/>'
        )
    return "\n  ".join(out)


def rays(cx, cy, r_out, r_in, count, colors, rot=-90.0):
    out = []
    for i in range(count):
        a0 = math.radians(rot + i * 360.0 / count)
        a1 = math.radians(rot + (i + 1) * 360.0 / count)
        p0 = (cx + r_out * math.cos(a0), cy + r_out * math.sin(a0))
        p1 = (cx + r_in * math.cos(a1), cy + r_in * math.sin(a1))
        p2 = (cx + r_in * math.cos(a0), cy + r_in * math.sin(a0))
        color = colors[i % len(colors)]
        out.append(
            f'<path d="M{p0[0]:.2f},{p0[1]:.2f} L{p1[0]:.2f},{p1[1]:.2f} '
            f'L{p2[0]:.2f},{p2[1]:.2f} Z" fill="{color}"/>'
        )
    return "\n  ".join(out)


def wheel_svg():
    cx = cy = 260.0
    parts = ["""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 520 520" width="520" height="520">
  <defs>
    <radialGradient id="rim" cx="0.4" cy="0.3" r="0.8">
      <stop offset="0" stop-color="#5A5A57"/>
      <stop offset="1" stop-color="#17150F"/>
    </radialGradient>
    <radialGradient id="felt" cx="0.4" cy="0.34" r="0.8">
      <stop offset="0" stop-color="#EBD49B"/>
      <stop offset="1" stop-color="#C9A25A"/>
    </radialGradient>
  </defs>
  <!-- الظل -->
  <ellipse cx="266" cy="276" rx="246" ry="244" fill="#000000" opacity="0.30"/>
  <!-- الإطار الأسود -->
  <circle cx="260" cy="260" r="250" fill="url(#rim)"/>
  <circle cx="260" cy="260" r="236" fill="url(#felt)"/>"""]
    # حلقات المربعات من الخارج إلى الداخل.
    parts.append("  " + square_ring(cx, cy, 214, "#B3261E", 56, 20))
    parts.append("  " + square_ring(cx, cy, 192, "#17150F", 52, 16))
    parts.append("  " + square_ring(cx, cy, 170, "#E58A1F", 48, 15))
    parts.append("  " + square_ring(cx, cy, 148, "#8E2F7A", 44, 14))
    parts.append("  " + square_ring(cx, cy, 126, "#E58A1F", 40, 13))
    # قرص المركز وش rays.
    parts.append(f'  <circle cx="{cx}" cy="{cy}" r="104" fill="#EFC46A"/>')
    parts.append("  " + rays(cx, cy, 102, 34, 16, ["#1F7A8C", "#E8A33A"]))
    parts.append(f'  <circle cx="{cx}" cy="{cy}" r="30" fill="#C1272D"/>')
    parts.append(f'  <circle cx="{cx}" cy="{cy}" r="30" fill="none" stroke="#8A1B15" stroke-width="3"/>')
    parts.append('</svg>')
    return "\n".join(parts)


write("tabaq_wheel.svg", wheel_svg())


# --------------------------------------------------------------- الأطباق
def plate_rings_svg():
    """طبق المرجع: حلقات مربعات حمراء/خضراء على أسود ومركز أحمر داكن."""
    cx = cy = 150.0
    parts = ["""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 300" width="300" height="300">
  <defs>
    <radialGradient id="p" cx="0.4" cy="0.32" r="0.8">
      <stop offset="0" stop-color="#EBD49B"/>
      <stop offset="1" stop-color="#C9A25A"/>
    </radialGradient>
  </defs>
  <circle cx="150" cy="156" r="142" fill="#000000" opacity="0.26"/>
  <circle cx="150" cy="150" r="140" fill="url(#p)"/>"""]
    parts.append("  " + square_ring(cx, cy, 124, "#B3261E", 34, 14))
    parts.append("  " + square_ring(cx, cy, 106, "#1F7A34", 30, 12))
    parts.append("  " + square_ring(cx, cy, 88, "#17150F", 26, 10))
    parts.append("  " + square_ring(cx, cy, 70, "#D8B96F", 22, 9))
    parts.append(f'  <circle cx="{cx}" cy="{cy}" r="50" fill="#8E1F19"/>')
    parts.append(f'  <circle cx="{cx}" cy="{cy}" r="50" fill="none" stroke="#5E130F" stroke-width="3"/>')
    parts.append('  <circle cx="150" cy="150" r="140" fill="none" stroke="#17150F" stroke-width="9"/>')
    parts.append('</svg>')
    return "\n".join(parts)


def plate_star_svg():
    """طبق المرجع الثاني: نجمة ثمانية ذهبية على أرضية بنية."""
    cx = cy = 150.0
    pts = []
    for i in range(16):
        r = 104 if i % 2 == 0 else 52
        a = math.radians(-90 + i * 22.5)
        pts.append(f"{cx + r * math.cos(a):.2f},{cy + r * math.sin(a):.2f}")
    dots = []
    for i in range(36):
        a = math.radians(i * 10)
        dots.append(
            f'<circle cx="{cx + 122 * math.cos(a):.2f}" cy="{cy + 122 * math.sin(a):.2f}" '
            f'r="5" fill="#C9A25A" opacity="0.85"/>'
        )
    return f"""<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 300" width="300" height="300">
  <defs>
    <radialGradient id="q" cx="0.4" cy="0.32" r="0.8">
      <stop offset="0" stop-color="#C08A46"/>
      <stop offset="1" stop-color="#8B5A28"/>
    </radialGradient>
  </defs>
  <circle cx="150" cy="156" r="142" fill="#000000" opacity="0.26"/>
  <circle cx="150" cy="150" r="140" fill="url(#q)"/>
  <circle cx="150" cy="150" r="112" fill="none" stroke="#6E3F1E" stroke-width="7"/>
  {''.join(dots)}
  <path d="M{' L'.join(pts)} Z" fill="#D9B168"/>
  <path d="M{' L'.join(pts)} Z" fill="none" stroke="#7A4A22" stroke-width="4"/>
  <circle cx="150" cy="150" r="140" fill="none" stroke="#3A2418" stroke-width="10"/>
</svg>
"""


write("plate.svg", plate_rings_svg())
write("plate_star.svg", plate_star_svg())


# --------------------------------------------------------------- الأيقونات
def icon(body, size=96):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 96 96" width="{size}" height="{size}">\n'
            + body + "\n</svg>\n")


write("icon_pause.svg", icon("""  <rect x="30" y="24" width="14" height="48" rx="5" fill="#FBF3E3"/>
  <rect x="52" y="24" width="14" height="48" rx="5" fill="#FBF3E3"/>"""))

write("icon_play.svg", icon("""  <path d="M34,22 L74,48 L34,74 Z" fill="#FBF3E3"/>"""))

write("icon_sound_on.svg", icon("""  <path d="M22,38 L34,38 L50,24 L50,72 L34,58 L22,58 Z" fill="#FBF3E3"/>
  <path d="M60,36 C66,42 66,54 60,60" stroke="#FBF3E3" stroke-width="6" fill="none" stroke-linecap="round"/>
  <path d="M68,28 C80,38 80,58 68,68" stroke="#FBF3E3" stroke-width="6" fill="none" stroke-linecap="round"/>"""))

write("icon_sound_off.svg", icon("""  <path d="M22,38 L34,38 L50,24 L50,72 L34,58 L22,58 Z" fill="#FBF3E3"/>
  <path d="M60,38 L80,60" stroke="#FBF3E3" stroke-width="6" stroke-linecap="round"/>
  <path d="M80,38 L60,60" stroke="#FBF3E3" stroke-width="6" stroke-linecap="round"/>"""))

write("icon_back.svg", icon("""  <path d="M58,20 L28,48 L58,76 Z" fill="#FBF3E3"/>"""))

write("icon_bulb.svg", icon("""  <path d="M48,20 C36,20 26,30 26,42 C26,50 31,55 34,60 L36,66 L60,66 L62,60 C65,55 70,50 70,42 C70,30 60,20 48,20 Z" fill="#FBF3E3"/>
  <rect x="36" y="68" width="24" height="6" rx="3" fill="#FBF3E3"/>
  <rect x="39" y="76" width="18" height="5" rx="2.5" fill="#FBF3E3"/>"""))

write("icon_undo.svg", icon("""  <path d="M30,30 L30,54 L54,54" stroke="#FBF3E3" stroke-width="8" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
  <path d="M32,54 C46,36 70,42 72,58 C74,74 56,82 44,74" stroke="#FBF3E3" stroke-width="8" fill="none" stroke-linecap="round"/>"""))

write("icon_gear.svg", icon("""  <g fill="#FBF3E3">
    <path d="M48,14 L57,14 L59,25 L65,27 L74,20 L81,27 L74,36 L76,42 L87,44 L87,53 L76,55 L74,61 L81,70 L74,77 L65,70 L59,72 L57,83 L48,83 L46,72 L40,70 L31,77 L24,70 L31,61 L29,55 L18,53 L18,44 L29,42 L31,36 L24,27 L31,20 L40,27 L46,25 Z" transform="translate(-3,-4) scale(0.94)"/>
    <circle cx="48" cy="45" r="13" fill="#6B4426"/>
  </g>"""))

print("تم توليد الأصول الهندسية.")
