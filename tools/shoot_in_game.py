#!/usr/bin/env python3
"""يلتقط لقطات من داخل اللعبة: شاشة البداية، الرئيسية، الإعداد،
اللعب (قبل وبعد وضع الحجارة)، ومعرض الرسومات.

الاستخدام: python3 tools/shoot_in_game.py [اسم المجلد]
"""
import http.server
import os
import socketserver
import sys
import threading

from playwright.sync_api import sync_playwright

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
WEB = os.path.join(ROOT, "build", "web")
OUT = os.path.join(ROOT, "shots", sys.argv[1] if len(sys.argv) > 1 else "ingame")
CHROME = "/root/.cache/ms-playwright/chromium-1243/chrome-linux/chrome"
PORT = 8801


def serve():
    handler = lambda *a, **k: http.server.SimpleHTTPRequestHandler(*a, directory=WEB, **k)
    socketserver.TCPServer.allow_reuse_address = True
    httpd = socketserver.TCPServer(("127.0.0.1", PORT), handler)
    threading.Thread(target=httpd.serve_forever, daemon=True).start()
    return httpd


def tap(page, x, y):
    page.mouse.move(x, y)
    page.wait_for_timeout(140)
    page.mouse.down()
    page.wait_for_timeout(120)
    page.mouse.up()


def main():
    os.makedirs(OUT, exist_ok=True)
    httpd = serve()
    with sync_playwright() as p:
        browser = p.chromium.launch(
            executable_path=CHROME, args=["--no-sandbox", "--disable-dev-shm-usage"]
        )
        page = browser.new_page(viewport={"width": 390, "height": 844}, device_scale_factor=2)

        # 1) شاشة البداية (الطبق والجدار) قبل انتهاء الأنيميشن.
        page.goto(f"http://127.0.0.1:{PORT}/index.html")
        page.wait_for_timeout(2600)
        page.screenshot(path=os.path.join(OUT, "00_splash.png"))

        # 2) الشاشة الرئيسية.
        page.wait_for_timeout(7500)
        page.screenshot(path=os.path.join(OUT, "01_home.png"))

        # 3) شاشة الإعداد.
        tap(page, 195, 612)
        page.wait_for_timeout(2500)
        page.screenshot(path=os.path.join(OUT, "02_setup.png"))

        # 4) اختيار حجر (فيروزي) ثم الانتقال للّعب.
        tap(page, 155, 629)
        page.wait_for_timeout(900)
        page.screenshot(path=os.path.join(OUT, "03_setup_stone.png"))
        tap(page, 195, 780)
        page.wait_for_timeout(5000)
        page.screenshot(path=os.path.join(OUT, "04_game.png"))

        # 5) وضع حجارة على اللوح (طور التوزيع) بلقطة أغنى.
        for (x, y) in [(105, 330), (285, 330), (105, 470), (285, 470)]:
            tap(page, x, y)
            page.wait_for_timeout(1400)
        page.screenshot(path=os.path.join(OUT, "05_game_stones.png"))

        browser.close()
    httpd.shutdown()
    print("->", OUT)


if __name__ == "__main__":
    main()
