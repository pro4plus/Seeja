#!/usr/bin/env python3
"""يجمع كل أصول PNG في ورقة معاينة واحدة (contact sheet) للمراجعة السريعة."""
import os
import sys

from playwright.sync_api import sync_playwright

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PNG = os.path.join(ROOT, "assets", "png")
OUT = os.path.join(ROOT, "assets", "preview_sheet.png")
CHROME = "/root/.cache/ms-playwright/chromium-1243/chrome-linux/chrome"

names = sorted(f for f in os.listdir(PNG) if f.endswith(".png"))
cells = "".join(
    f'<figure><img src="file://{os.path.join(PNG, n)}"><figcaption>{n[:-4]}</figcaption></figure>'
    for n in names
)
html = f"""<html><head><meta charset="utf-8"><style>
body {{ background:#F3E6C8; font-family: sans-serif; margin:16px; }}
h1 {{ font-size:20px; color:#3A2418; }}
.grid {{ display:grid; grid-template-columns:repeat(6,1fr); gap:12px; }}
figure {{ background:#fff; border:2px solid #C79A4E; border-radius:10px; padding:8px; margin:0;
          display:flex; flex-direction:column; align-items:center; justify-content:flex-end; height:200px; }}
img {{ max-width:100%; max-height:150px; object-fit:contain; }}
figcaption {{ font-size:11px; color:#5E3A20; margin-top:6px; direction:rtl; }}
</style></head><body><h1>أصول لعبة السيجا — مكتبة الرسومات</h1><div class="grid">{cells}</div></body></html>"""

def launch_chromium(p):
    """يفتح كروميوم: يحاول المسار الافتراضي أولاً ثم المسار المحلي."""
    args = ["--no-sandbox", "--disable-dev-shm-usage", "--force-color-profile=srgb"]
    try:
        return p.chromium.launch(args=args)
    except Exception:
        return p.chromium.launch(executable_path=CHROME, args=args)


with sync_playwright() as p:
    browser = launch_chromium(p)
    page = browser.new_page(viewport={"width": 1400, "height": 900}, device_scale_factor=1)
    tmp = os.path.join(ROOT, "assets", "_preview_tmp.html")
    with open(tmp, "w", encoding="utf-8") as fh:
        fh.write(html)
    page.goto("file://" + tmp)
    page.wait_for_timeout(900)
    page.screenshot(path=OUT, full_page=True)
    browser.close()
    os.remove(tmp)
print("->", OUT)
