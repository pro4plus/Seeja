#!/usr/bin/env python3
"""أصول الديكور المرسومة يدوياً (محاريب، أطباق، فانوس، حصائر، جدار، مشهد الباب، منصة)."""
import os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SVG = os.path.join(ROOT, "assets", "svg")
os.makedirs(SVG, exist_ok=True)


def write(name, body):
    with open(os.path.join(SVG, name), "w", encoding="utf-8") as fh:
        fh.write(body)
    print("->", name)


# ------------------------------------------------------------- المحراب الذهبي
# كبسولة طويلة بإطار ذهبي (كما في المرجع) وفتحة داخلية داكنة.
write("niche.svg", """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 420" width="300" height="420">
  <defs>
    <linearGradient id="inner" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#2A1A10"/>
      <stop offset="1" stop-color="#43291A"/>
    </linearGradient>
  </defs>
  <!-- ظل الكوّة على الجدار -->
  <path d="M150,20 C216,20 268,80 268,152 L268,360 C268,392 244,406 214,406 L86,406 C56,406 32,392 32,360 L32,152 C32,80 84,20 150,20 Z"
        fill="#000000" opacity="0.20" transform="translate(-16,14)"/>
  <!-- الفتحة -->
  <path d="M150,20 C216,20 268,80 268,152 L268,360 C268,392 244,406 214,406 L86,406 C56,406 32,392 32,360 L32,152 C32,80 84,20 150,20 Z"
        fill="url(#inner)"/>
  <!-- الإطار الذهبي -->
  <path d="M150,20 C216,20 268,80 268,152 L268,360 C268,392 244,406 214,406 L86,406 C56,406 32,392 32,360 L32,152 C32,80 84,20 150,20 Z"
        fill="none" stroke="#D8A93C" stroke-width="7"/>
  <path d="M150,34 C206,34 252,88 252,154 L252,352 C252,378 234,392 208,392 L92,392 C66,392 48,378 48,352 L48,154 C48,88 94,34 150,34 Z"
        fill="none" stroke="#8A6524" stroke-width="3" opacity="0.85"/>
  <!-- قاعدة الكوّة -->
  <rect x="34" y="392" width="232" height="16" rx="8" fill="#8A6524"/>
  <rect x="46" y="402" width="208" height="10" rx="5" fill="#5E3F14"/>
</svg>
""")

# ------------------------------------------------------------- الصحن الطيني
BOWL_BODY = """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 340 240" width="340" height="240">
  <defs>
    <linearGradient id="clay" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#D2793F"/>
      <stop offset="0.55" stop-color="#B85A2C"/>
      <stop offset="1" stop-color="#8E4220"/>
    </linearGradient>
  </defs>
  <ellipse cx="170" cy="224" rx="150" ry="16" fill="#000000" opacity="0.22"/>
  <!-- جسم الصحن -->
  <path d="M14,92 C14,180 74,226 170,226 C266,226 326,180 326,92 Z" fill="url(#clay)"/>
  <!-- الفتحة -->
  <ellipse cx="170" cy="92" rx="156" ry="46" fill="#3A2418"/>
  <ellipse cx="170" cy="96" rx="146" ry="38" fill="#2A1A10"/>
"""

BOWL_TAIL = """  <!-- شريط الغرزة -->
  <path d="M44,140 C74,158 116,166 170,166 C224,166 266,158 296,140" stroke="#F3E2C8" stroke-width="7"
        stroke-dasharray="14 12" fill="none" stroke-linecap="round"/>
  <path d="M34,104 C50,120 70,130 96,136" stroke="#7E3418" stroke-width="4" fill="none" opacity="0.5" stroke-linecap="round"/>
  <!-- حافة الصحن -->
  <path d="M14,92 C14,180 74,226 170,226 C266,226 326,180 326,92" stroke="#6E3216" stroke-width="5" fill="none" opacity="0.65"/>
  <ellipse cx="170" cy="92" rx="156" ry="46" fill="none" stroke="#6E3216" stroke-width="5" opacity="0.8"/>
</svg>
"""

write("bowl_empty.svg", BOWL_BODY + BOWL_TAIL)

STONES_IN = """  <!-- الحصى داخل الصحن -->
  <g>
    <circle cx="86" cy="82" r="24" fill="#3B4FA0"/>
    <circle cx="132" cy="72" r="24" fill="#3B4FA0"/>
    <circle cx="178" cy="78" r="24" fill="#3B4FA0"/>
    <circle cx="222" cy="86" r="24" fill="#3B4FA0"/>
    <circle cx="110" cy="62" r="22" fill="#4A63C0"/>
    <circle cx="156" cy="56" r="22" fill="#4A63C0"/>
    <circle cx="200" cy="62" r="22" fill="#4A63C0"/>
    <circle cx="76" cy="66" r="19" fill="#2E3F86"/>
    <circle cx="238" cy="70" r="19" fill="#2E3F86"/>
    <circle cx="142" cy="42" r="17" fill="#5E76C6"/>
    <circle cx="186" cy="44" r="17" fill="#5E76C6"/>
  </g>
"""

write("bowl_stones_blue.svg", BOWL_BODY + STONES_IN + BOWL_TAIL)

write("bowl_stones_brown.svg", BOWL_BODY + STONES_IN.replace("#3B4FA0", "#B4643C")
      .replace("#4A63C0", "#D08A5E").replace("#2E3F86", "#8E4E2A")
      .replace("#5E76C6", "#E3A87C") + BOWL_TAIL)

# ------------------------------------------------------------------ الفانوس
write("lantern_lit.svg", """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 280" width="200" height="280">
  <defs>
    <radialGradient id="glow" cx="0.5" cy="0.55" r="0.5">
      <stop offset="0" stop-color="#FFD87A" stop-opacity="0.85"/>
      <stop offset="0.55" stop-color="#F6B93B" stop-opacity="0.35"/>
      <stop offset="1" stop-color="#F6B93B" stop-opacity="0"/>
    </radialGradient>
    <linearGradient id="glass" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#FFF0B8"/>
      <stop offset="0.5" stop-color="#F7C64A"/>
      <stop offset="1" stop-color="#E39A1E"/>
    </linearGradient>
  </defs>
  <circle cx="100" cy="150" r="100" fill="url(#glow)"/>
  <!-- مقبض -->
  <path d="M78,44 C78,14 122,14 122,44" stroke="#3A2418" stroke-width="8" fill="none" stroke-linecap="round"/>
  <!-- الغطاء -->
  <path d="M56,74 L144,74 L122,44 L78,44 Z" fill="#3A2418"/>
  <rect x="72" y="68" width="56" height="10" rx="5" fill="#4E3120"/>
  <!-- جسم الزجاج -->
  <path d="M54,86 L146,86 L134,206 L66,206 Z" fill="url(#glass)"/>
  <path d="M100,86 L100,206" stroke="#3A2418" stroke-width="5" opacity="0.75"/>
  <path d="M72,96 L78,196" stroke="#FFFFFF" stroke-width="7" opacity="0.35" stroke-linecap="round"/>
  <!-- القضبان -->
  <path d="M54,86 L146,86" stroke="#3A2418" stroke-width="7"/>
  <path d="M66,206 L134,206" stroke="#3A2418" stroke-width="7"/>
  <path d="M60,150 L140,150" stroke="#3A2418" stroke-width="4" opacity="0.55"/>
  <!-- القاعدة -->
  <rect x="56" y="204" width="88" height="18" rx="5" fill="#3A2418"/>
  <rect x="48" y="220" width="104" height="16" rx="6" fill="#4E3120"/>
  <!-- اللهب -->
  <path d="M100,58 C92,46 100,36 100,30 C100,38 110,46 104,58 Z" fill="#FFD87A"/>
</svg>
""")

write("lantern_off.svg", """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 280" width="200" height="280">
  <path d="M78,44 C78,14 122,14 122,44" stroke="#3A2418" stroke-width="8" fill="none" stroke-linecap="round"/>
  <path d="M56,74 L144,74 L122,44 L78,44 Z" fill="#3A2418"/>
  <rect x="72" y="68" width="56" height="10" rx="5" fill="#4E3120"/>
  <path d="M54,86 L146,86 L134,206 L66,206 Z" fill="#4A423C"/>
  <path d="M100,86 L100,206" stroke="#3A2418" stroke-width="5" opacity="0.8"/>
  <path d="M72,96 L78,196" stroke="#FFFFFF" stroke-width="7" opacity="0.12" stroke-linecap="round"/>
  <path d="M54,86 L146,86" stroke="#3A2418" stroke-width="7"/>
  <path d="M66,206 L134,206" stroke="#3A2418" stroke-width="7"/>
  <rect x="56" y="204" width="88" height="18" rx="5" fill="#3A2418"/>
  <rect x="48" y="220" width="104" height="16" rx="6" fill="#4E3120"/>
</svg>
""")

# --------------------------------------------------------- جدار الألواح الخشبية
write("wall_wood.svg", """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 400" width="400" height="400">
  <rect width="400" height="400" fill="#8A6A47"/>
  <g>
    <rect x="0" width="34" height="400" fill="#96754F"/>
    <rect x="36" width="30" height="400" fill="#7E5F3E"/>
    <rect x="68" width="36" height="400" fill="#8F6E4A"/>
    <rect x="106" width="28" height="400" fill="#7A5C3B"/>
    <rect x="136" width="34" height="400" fill="#96754F"/>
    <rect x="172" width="30" height="400" fill="#84643F"/>
    <rect x="204" width="36" height="400" fill="#8F6E4A"/>
    <rect x="242" width="28" height="400" fill="#7A5C3B"/>
    <rect x="272" width="34" height="400" fill="#96754F"/>
    <rect x="308" width="30" height="400" fill="#84643F"/>
    <rect x="340" width="36" height="400" fill="#8F6E4A"/>
    <rect x="378" width="22" height="400" fill="#7A5C3B"/>
  </g>
  <g fill="none" stroke="#5E432A" stroke-width="3" opacity="0.85">
    <path d="M34,0 L34,400 M66,0 L66,400 M104,0 L104,400 M134,0 L134,400 M170,0 L170,400
             M202,0 L202,400 M240,0 L240,400 M270,0 L270,400 M306,0 L306,400 M338,0 L338,400
             M376,0 L376,400"/>
  </g>
  <g fill="none" stroke="#A9855C" stroke-width="2" opacity="0.6">
    <path d="M20,0 L20,400 M50,0 L50,400 M88,0 L88,400 M120,0 L120,400 M152,0 L152,400
             M186,0 L186,400 M222,0 L222,400 M256,0 L256,400 M290,0 L290,400 M322,0 L322,400
             M358,0 L358,400 M390,0 L390,400"/>
  </g>
  <g fill="none" stroke="#6E5233" stroke-width="1.6" opacity="0.35">
    <path d="M40,0 C44,120 36,240 40,400 M112,0 C116,140 108,260 112,400
             M186,0 C190,120 182,250 186,400 M252,0 C256,130 248,255 252,400 M330,0 C334,125 326,245 330,400"/>
  </g>
</svg>
""")

# ------------------------------------------------------------------ الحصيرة
write("mat.svg", """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 600 260" width="600" height="260">
  <defs>
    <linearGradient id="straw" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#E8C77A"/>
      <stop offset="0.5" stop-color="#D9AF67"/>
      <stop offset="1" stop-color="#C79A4E"/>
    </linearGradient>
  </defs>
  <rect x="0" y="0" width="600" height="260" fill="url(#straw)"/>
  <!-- خيوط القصب -->
  <g fill="none" stroke="#B98C45" stroke-width="2" opacity="0.35">
    <path d="M8,0 L8,260 M22,0 L22,260 M36,0 L36,260 M50,0 L50,260 M64,0 L64,260 M78,0 L78,260
             M92,0 L92,260 M106,0 L106,260 M120,0 L120,260 M134,0 L134,260 M148,0 L148,260
             M162,0 L162,260 M176,0 L176,260 M190,0 L190,260 M204,0 L204,260 M218,0 L218,260
             M232,0 L232,260 M246,0 L246,260 M260,0 L260,260 M274,0 L274,260 M288,0 L288,260
             M302,0 L302,260 M316,0 L316,260 M330,0 L330,260 M344,0 L344,260 M358,0 L358,260
             M372,0 L372,260 M386,0 L386,260 M400,0 L400,260 M414,0 L414,260 M428,0 L428,260
             M442,0 L442,260 M456,0 L456,260 M470,0 L470,260 M484,0 L484,260 M498,0 L498,260
             M512,0 L512,260 M526,0 L526,260 M540,0 L540,260 M554,0 L554,260 M568,0 L568,260
             M582,0 L582,260 M594,0 L594,260"/>
  </g>
  <!-- أشرطة سوداء -->
  <g>
    <rect x="0" y="66" width="600" height="16" fill="#241607"/>
    <rect x="0" y="178" width="600" height="16" fill="#241607"/>
  </g>
  <!-- أشرطة حمراء -->
  <g>
    <rect x="0" y="52" width="600" height="14" fill="#C1272D"/>
    <rect x="0" y="194" width="600" height="14" fill="#C1272D"/>
  </g>
  <!-- زخارف ذهبية -->
  <g fill="#E3A72C" opacity="0.85">
    <path d="M0,82 l10,0 0,10 -10,0 z M28,82 l10,0 0,10 -10,0 z M56,82 l10,0 0,10 -10,0 z
             M84,82 l10,0 0,10 -10,0 z M112,82 l10,0 0,10 -10,0 z M140,82 l10,0 0,10 -10,0 z
             M168,82 l10,0 0,10 -10,0 z M196,82 l10,0 0,10 -10,0 z M224,82 l10,0 0,10 -10,0 z
             M252,82 l10,0 0,10 -10,0 z M280,82 l10,0 0,10 -10,0 z M308,82 l10,0 0,10 -10,0 z
             M336,82 l10,0 0,10 -10,0 z M364,82 l10,0 0,10 -10,0 z M392,82 l10,0 0,10 -10,0 z
             M420,82 l10,0 0,10 -10,0 z M448,82 l10,0 0,10 -10,0 z M476,82 l10,0 0,10 -10,0 z
             M504,82 l10,0 0,10 -10,0 z M532,82 l10,0 0,10 -10,0 z M560,82 l10,0 0,10 -10,0 z
             M588,82 l10,0 0,10 -10,0 z"/>
  </g>
  <!-- شريط علوي -->
  <rect x="0" y="18" width="600" height="10" fill="#C1272D" opacity="0.9"/>
  <rect x="0" y="28" width="600" height="4" fill="#241607" opacity="0.6"/>
  <!-- الشراشيب السفلية -->
  <g fill="none" stroke="#241607" stroke-width="3" opacity="0.6" stroke-linecap="round">
    <path d="M4,236 L4,256 M18,236 L19,254 M32,236 L32,258 M46,236 L47,254 M60,236 L60,257
             M74,236 L75,254 M88,236 L88,258 M102,236 L103,254 M116,236 L116,257 M130,236 L131,254
             M144,236 L144,258 M158,236 L159,254 M172,236 L172,257 M186,236 L187,254 M200,236 L200,258
             M214,236 L215,254 M228,236 L228,257 M242,236 L243,254 M256,236 L256,258 M270,236 L271,254
             M284,236 L284,257 M298,236 L299,254 M312,236 L312,258 M326,236 L327,254 M340,236 L340,257
             M354,236 L355,254 M368,236 L368,258 M382,236 L383,254 M396,236 L396,257 M410,236 L411,254
             M424,236 L424,258 M438,236 L439,254 M452,236 L452,257 M466,236 L467,254 M480,236 L480,258
             M494,236 L495,254 M508,236 L508,257 M522,236 L523,254 M536,236 L536,258 M550,236 L551,254
             M564,236 L564,257 M578,236 L579,254 M592,236 L592,258"/>
  </g>
</svg>
""")

# -------------------------------------------------------------- جدار القصب
write("wall_planks.svg", """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 400" width="400" height="400">
  <rect width="400" height="400" fill="#E0BC72"/>
  <g>
    <rect x="6" width="14" height="400" fill="#C79A4E" opacity="0.55"/>
    <rect x="26" width="9" height="400" fill="#C79A4E" opacity="0.4"/>
    <rect x="41" width="16" height="400" fill="#C79A4E" opacity="0.5"/>
    <rect x="63" width="8" height="400" fill="#C79A4E" opacity="0.35"/>
    <rect x="77" width="13" height="400" fill="#C79A4E" opacity="0.5"/>
    <rect x="96" width="10" height="400" fill="#C79A4E" opacity="0.4"/>
    <rect x="112" width="15" height="400" fill="#C79A4E" opacity="0.55"/>
    <rect x="133" width="8" height="400" fill="#C79A4E" opacity="0.35"/>
    <rect x="147" width="12" height="400" fill="#C79A4E" opacity="0.45"/>
    <rect x="165" width="16" height="400" fill="#C79A4E" opacity="0.55"/>
    <rect x="187" width="9" height="400" fill="#C79A4E" opacity="0.4"/>
    <rect x="202" width="14" height="400" fill="#C79A4E" opacity="0.5"/>
    <rect x="222" width="8" height="400" fill="#C79A4E" opacity="0.35"/>
    <rect x="236" width="13" height="400" fill="#C79A4E" opacity="0.5"/>
    <rect x="255" width="10" height="400" fill="#C79A4E" opacity="0.4"/>
    <rect x="271" width="15" height="400" fill="#C79A4E" opacity="0.55"/>
    <rect x="292" width="8" height="400" fill="#C79A4E" opacity="0.35"/>
    <rect x="306" width="12" height="400" fill="#C79A4E" opacity="0.45"/>
    <rect x="324" width="16" height="400" fill="#C79A4E" opacity="0.55"/>
    <rect x="346" width="9" height="400" fill="#C79A4E" opacity="0.4"/>
    <rect x="361" width="14" height="400" fill="#C79A4E" opacity="0.5"/>
    <rect x="381" width="10" height="400" fill="#C79A4E" opacity="0.4"/>
  </g>
  <g fill="none" stroke="#F2DBA6" stroke-width="3" opacity="0.5">
    <path d="M22,0 L22,400 M58,0 L58,400 M94,0 L94,400 M130,0 L130,400 M160,0 L160,400
             M197,0 L197,400 M232,0 L232,400 M266,0 L266,400 M301,0 L301,400 M340,0 L340,400 M374,0 L374,400"/>
  </g>
</svg>
""")

# ---------------------------------------------------- مشهد الباب المقوّس
write("arch_scene.svg", """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 520 700" width="520" height="700">
  <defs>
    <clipPath id="arch">
      <path d="M60,690 L60,300 C60,150 175,55 260,55 C345,55 460,150 460,300 L460,690 Z"/>
    </clipPath>
  </defs>
  <g clip-path="url(#arch)">
    <!-- سماء مسطّحة بشرائط -->
    <rect x="0" y="40" width="520" height="130" fill="#5E4F72"/>
    <rect x="0" y="170" width="520" height="90" fill="#7C5C74"/>
    <rect x="0" y="260" width="520" height="90" fill="#A86E6E"/>
    <rect x="0" y="350" width="520" height="90" fill="#C98A72"/>
    <rect x="0" y="440" width="520" height="60" fill="#E3A97E"/>
    <!-- الشمس -->
    <circle cx="150" cy="215" r="48" fill="#E2683A"/>
    <!-- الأرض -->
    <rect x="0" y="495" width="520" height="205" fill="#C08A4E"/>
    <path d="M0,495 L520,495 L520,470 C400,452 200,470 0,452 Z" fill="#C98A72"/>
    <!-- الأهرامات -->
    <path d="M30,500 L105,352 L180,500 Z" fill="#8A5A34"/>
    <path d="M105,352 L180,500 L108,500 Z" fill="#7A4C2C"/>
    <path d="M150,500 L215,385 L280,500 Z" fill="#9A6738"/>
    <path d="M215,385 L280,500 L218,500 Z" fill="#83512E"/>
    <!-- النيل -->
    <path d="M255,500 C300,520 200,545 175,575 C150,605 235,625 255,650 C270,668 255,685 235,700 L360,700
             C385,678 380,650 340,628 C300,606 250,600 268,578 C285,556 340,540 310,500 Z" fill="#3E8FB0"/>
    <path d="M262,506 C300,524 210,548 186,576" stroke="#7FC4DA" stroke-width="6" fill="none" opacity="0.7"/>
    <!-- النخلة الكبيرة -->
    <path d="M432,700 C440,600 452,520 448,420 C446,380 448,330 452,300 L486,300
             C480,340 480,390 484,430 C490,530 486,610 478,700 Z" fill="#6E4A2E"/>
    <g fill="none" stroke="#4E321F" stroke-width="5" opacity="0.7">
      <path d="M436,650 L482,650 M440,600 L484,600 M444,548 L488,548 M446,496 L490,496
               M448,446 L492,446 M450,396 L494,396 M452,346 L496,346"/>
    </g>
    <g fill="#1F6B34">
      <path d="M468,300 C420,262 388,272 362,306 C404,312 436,310 468,300 Z"/>
      <path d="M468,300 C516,262 548,272 574,306 C532,312 500,310 468,300 Z"/>
      <path d="M468,300 C438,246 452,214 476,196 C482,240 478,272 468,300 Z"/>
      <path d="M468,300 C512,250 548,248 572,262 C544,294 504,302 468,300 Z"/>
      <path d="M468,300 C418,318 388,352 390,388 C422,362 448,328 468,300 Z"/>
      <path d="M468,300 C518,318 548,352 546,388 C514,362 488,328 468,300 Z"/>
    </g>
    <g fill="#2E8B4F">
      <path d="M468,300 C428,270 400,278 378,300 C414,308 440,306 468,300 Z"/>
      <path d="M468,300 C508,270 538,278 560,300 C524,308 498,306 468,300 Z"/>
      <path d="M468,300 C500,258 526,250 546,262 C524,288 496,296 468,300 Z"/>
    </g>
    <!-- عشب -->
    <g fill="#2E7B3C">
      <path d="M410,690 C404,666 412,652 418,690 Z M428,694 C424,670 436,660 438,694 Z
               M492,694 C488,668 500,660 504,694 Z"/>
    </g>
  </g>
  <!-- إطار الفيروزي مع الحبال الحمراء -->
  <path d="M60,690 L60,300 C60,150 175,55 260,55 C345,55 460,150 460,300 L460,690"
        stroke="#2FB3B8" stroke-width="34" fill="none"/>
  <g fill="none" stroke="#B3261E" stroke-width="7" stroke-linecap="round" stroke-dasharray="13 13">
    <path d="M60,300 L60,690"/>
    <path d="M460,300 L460,690"/>
    <path d="M60,300 C60,150 175,55 260,55 C345,55 460,150 460,300"/>
  </g>
</svg>
""")

# ------------------------------------------------------------ منصة النصر
write("pedestal.svg", """<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 520 260" width="520" height="260">
  <defs>
    <linearGradient id="pd" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0" stop-color="#8A5A33"/>
      <stop offset="1" stop-color="#4A2E1B"/>
    </linearGradient>
  </defs>
  <ellipse cx="260" cy="240" rx="220" ry="20" fill="#000000" opacity="0.25"/>
  <path d="M60,110 L460,110 L430,236 L90,236 Z" fill="url(#pd)"/>
  <rect x="48" y="88" width="424" height="30" rx="14" fill="#A06A3C"/>
  <rect x="90" y="130" width="340" height="14" rx="6" fill="#3A2418" opacity="0.6"/>
  <rect x="106" y="158" width="308" height="12" rx="6" fill="#C1272D" opacity="0.8"/>
</svg>
""")

print("تم إنشاء ديكورات الأصول.")
