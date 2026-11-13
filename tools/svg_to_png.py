#!/usr/bin/env python3
"""يحوّل ملفات SVG في assets/svg إلى PNG في assets/png باستخدام كروميوم (Playwright).

الاستخدام:  python3 tools/svg_to_png.py [مقياس]
المقياس الافتراضي 3 (يحافظ على حدّة الخطوط عند العرض داخل اللعبة).
"""
import os
import re
import sys

from playwright.sync_api import sync_playwright

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SVG_DIR = os.path.join(ROOT, "assets", "svg")
PNG_DIR = os.path.join(ROOT, "assets", "png")
CHROME = "/root/.cache/ms-playwright/chromium-1243/chrome-linux/chrome"

VIEWBOX = re.compile(r'viewBox\s*=\s*"([\d.\-\s]+)"')


def launch_chromium(p):
    """يفتح كروميوم: يحاول المسار الافتراضي أولاً ثم المسار المحلي."""
    args = ["--no-sandbox", "--disable-dev-shm-usage", "--force-color-profile=srgb"]
    try:
        return p.chromium.launch(args=args)
    except Exception:
        return p.chromium.launch(executable_path=CHROME, args=args)


def viewbox_of(path):
    with open(path, "r", encoding="utf-8") as fh:
        head = fh.read(4000)
    m = VIEWBOX.search(head)
    if not m:
        return None
    return [float(v) for v in m.group(1).replace(",", " ").split()]


def main():
    scale = float(sys.argv[1]) if len(sys.argv) > 1 else 3.0
    os.makedirs(PNG_DIR, exist_ok=True)
    svgs = sorted(f for f in os.listdir(SVG_DIR) if f.endswith(".svg"))
    with sync_playwright() as p:
        browser = launch_chromium(p)
        for name in svgs:
            src = os.path.join(SVG_DIR, name)
            vb = viewbox_of(src)
            with open(src, "r", encoding="utf-8") as fh:
                markup = fh.read()
            w = vb[2] if vb else 512
            h = vb[3] if vb else 512
            page = browser.new_page(
                viewport={"width": int(w), "height": int(h)},
                device_scale_factor=scale,
            )
            page.set_content(
                "<html><body style='margin:0;background:transparent'>" + markup + "</body></html>"
            )
            page.wait_for_timeout(120)
            out = os.path.join(PNG_DIR, name[:-4] + ".png")
            page.screenshot(path=out, omit_background=True)
            page.close()
            print("->", os.path.relpath(out, ROOT))
        browser.close()


if __name__ == "__main__":
    main()
