#!/usr/bin/env python3
"""يلتقط لقطات من نسخة الويب المبنية (build/web) لمعاينة الشاشات.

الاستخدام: python3 tools/shoot.py [اسم مجلد الإخراج]
"""
import http.server
import os
import socketserver
import sys
import threading
import time

from playwright.sync_api import sync_playwright

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WEB = os.path.join(ROOT, "build", "web")
OUT = os.path.join(ROOT, "shots")
CHROME = "/root/.cache/ms-playwright/chromium-1243/chrome-linux/chrome"
PORT = 8777


def serve():
    handler = lambda *a, **k: http.server.SimpleHTTPRequestHandler(*a, directory=WEB, **k)
    socketserver.TCPServer.allow_reuse_address = True
    httpd = socketserver.TCPServer(("127.0.0.1", PORT), handler)
    threading.Thread(target=httpd.serve_forever, daemon=True).start()
    return httpd


def launch_chromium(p):
    """يفتح كروميوم: يحاول المسار الافتراضي أولاً ثم المسار المحلي."""
    args = ["--no-sandbox", "--disable-dev-shm-usage", "--force-color-profile=srgb"]
    try:
        return p.chromium.launch(args=args)
    except Exception:
        return p.chromium.launch(executable_path=CHROME, args=args)


def _tap(page, x, y):
    """نقرة أدق: ضغط مطوّل قليلاً حتى يستقبلها Flutter."""
    page.mouse.move(x, y)
    page.wait_for_timeout(150)
    page.mouse.down()
    page.wait_for_timeout(120)
    page.mouse.up()


def main():
    out = os.path.join(OUT, sys.argv[1] if len(sys.argv) > 1 else "run")
    os.makedirs(out, exist_ok=True)
    httpd = serve()
    with sync_playwright() as p:
        browser = launch_chromium(p)
        page = browser.new_page(
            viewport={"width": 390, "height": 844},
            device_scale_factor=2,
        )
        page.goto(f"http://127.0.0.1:{PORT}/index.html")
        page.wait_for_timeout(9000)
        page.screenshot(path=os.path.join(out, "01_home.png"))

        # الانتقال للإعداد: زر «العب ضد الكمبيوتر» أسفل لوحة العرض.
        _tap(page, 195, 612)
        page.wait_for_timeout(2500)
        page.screenshot(path=os.path.join(out, "02_setup.png"))

        # اختيار أول حجر ثم بدء اللعب.
        _tap(page, 155, 629)
        page.wait_for_timeout(900)
        page.screenshot(path=os.path.join(out, "03_setup_stone.png"))
        _tap(page, 195, 780)
        page.wait_for_timeout(5000)
        page.screenshot(path=os.path.join(out, "04_game.png"))

        # معرض الرسومات: رجوع للرئيسية ثم فتح الرابط في الأسفل.
        page.go_back()
        page.wait_for_timeout(1200)
        page.go_back()
        page.wait_for_timeout(2000)
        page.mouse.click(48, 772)
        page.wait_for_timeout(2500)
        page.screenshot(path=os.path.join(out, "05_gallery.png"))

        browser.close()
    httpd.shutdown()
    print("->", out)


if __name__ == "__main__":
    main()
