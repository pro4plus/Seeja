#!/usr/bin/env python3
"""توليد مؤثرات صوتية كرتونية للسيجا (WAV أحادي 16-bit 44.1kHz) بلا أي ملفات خارجية.
التشغيل: python3 tools/make_sounds.py   (يكتب إلى assets/sounds)
الأسلوب: فقاعات وبوب، ماريمبا مطاطية، صفير انزلاق، بونك خشبي، أبواق مرحة."""
import os, wave
import numpy as np

SR = 44100
OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "sounds")
rng = np.random.default_rng(7)


def t(d):
    return np.linspace(0, d, int(SR * d), endpoint=False)


def env(n, a=0.004, d=0.0, curve=4.0):
    """بداية سريعة ثم تلاشٍ أسي."""
    x = np.arange(n) / SR
    e = np.exp(-curve * x / max(x[-1], 1e-6))
    att = np.minimum(1, x / a)
    return e * att


def sine_sweep(f0, f1, d, curve=3.0):
    tt = t(d)
    f = f1 + (f0 - f1) * np.exp(-curve * tt / d)
    return np.sin(2 * np.pi * np.cumsum(f) / SR)


def pop(f0=900, f1=260, d=0.14, amp=0.8):
    s = sine_sweep(f0, f1, d, 6.0)
    return s * env(len(s), 0.002, curve=7.0) * amp


def marimba(f, d=0.45, amp=0.6):
    tt = t(d)
    s = (np.sin(2 * np.pi * f * tt) + 0.35 * np.sin(2 * np.pi * f * 4 * tt) * np.exp(-14 * tt)
         + 0.15 * np.sin(2 * np.pi * f * 9.2 * tt) * np.exp(-30 * tt))
    return s * env(len(s), 0.002, curve=6.0) * amp


def boing(f0=330, d=0.38, amp=0.6, wob=14.0):
    tt = t(d)
    f = f0 * (1 + 0.5 * np.exp(-6 * tt) * np.sin(2 * np.pi * wob * tt))
    s = np.sin(2 * np.pi * np.cumsum(f) / SR)
    s += 0.3 * np.sin(2 * np.pi * np.cumsum(f * 2) / SR)
    return s * env(len(s), 0.003, curve=5.0) * amp


def bonk(f=190, d=0.18, amp=0.8):
    tt = t(d)
    s = np.sin(2 * np.pi * f * np.exp(-8 * tt) * tt * 1.0 + 0.0)
    s = sine_sweep(f * 2.2, f, d, 12.0)
    n = rng.standard_normal(len(tt)) * np.exp(-90 * tt) * 0.35
    return (s * env(len(s), 0.001, curve=9.0) + n) * amp


def whoosh(f0=500, f1=2400, d=0.22, amp=0.35):
    n = rng.standard_normal(int(SR * d))
    # مرشح ممر متحرك بسيط عبر تعديل سعة جيبية
    tt = t(d)
    f = f0 + (f1 - f0) * (tt / d)
    carrier = np.sin(2 * np.pi * np.cumsum(f) / SR)
    s = n * 0.5 * carrier
    e = np.sin(np.pi * tt / d) ** 1.5
    return s * e * amp


def squeak(f0=1100, f1=1900, d=0.12, amp=0.4):
    tt = t(d)
    f = f0 + (f1 - f0) * (tt / d)
    s = np.sin(2 * np.pi * np.cumsum(f) / SR)
    return s * np.sin(np.pi * tt / d) * amp


def trombone(f0, f1, d=0.5, amp=0.55):
    tt = t(d)
    f = f0 + (f1 - f0) * (tt / d) + 3 * np.sin(2 * np.pi * 6 * tt)
    ph = 2 * np.pi * np.cumsum(f) / SR
    s = np.sin(ph) + 0.5 * np.sin(2 * ph) + 0.33 * np.sin(3 * ph)
    return s * np.minimum(1, tt / 0.03) * np.exp(-2.0 * tt / d) * amp


def mix(*parts):
    n = max(int(off * SR) + len(p) for off, p in parts)
    out = np.zeros(n)
    for off, p in parts:
        o = int(off * SR)
        out[o:o + len(p)] += p
    return out


def shift(f, semitones):
    return f * (2 ** (semitones / 12))


def save(name, x, peak=0.9):
    x = np.asarray(x)
    m = np.max(np.abs(x)) or 1.0
    x = x / m * peak
    # نهاية ناعمة
    fade = int(SR * 0.006)
    x[-fade:] *= np.linspace(1, 0, fade)
    data = (x * 32767).astype(np.int16)
    with wave.open(os.path.join(OUT, name + ".wav"), "wb") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
        w.writeframes(data.tobytes())


def main():
    os.makedirs(OUT, exist_ok=True)
    save("ui_tap", pop(1200, 520, 0.09, 0.8))
    save("select", mix((0, marimba(880, 0.22)), (0.05, marimba(1175, 0.25))))
    for i, f in enumerate([420, 480, 540], 1):          # وضع حجر: بوب مع نقرة خشب
        save(f"place{i}", mix((0, pop(f * 2, f, 0.16, 0.8)), (0, bonk(f * 0.45, 0.1, 0.4))))
    for i, (a, b) in enumerate([(500, 2200), (400, 1900), (600, 2600)], 1):  # انزلاق
        save(f"slide{i}", mix((0, whoosh(a, b, 0.2)), (0.14, pop(700, 380, 0.07, 0.35))))
    save("land", mix((0, bonk(150, 0.2, 0.9)), (0, pop(500, 200, 0.12, 0.4))))
    for i, f in enumerate([523, 587, 659], 1):          # أكل: ضربة + صرير + نغمة ماريمبا صاعدة
        save(f"capture{i}", mix((0, bonk(220, 0.18, 0.8)), (0.03, squeak(900, 1700, 0.12)),
                                (0.07, marimba(f * 2, 0.4, 0.5))))
    notes = [523, 659, 784, 1047]
    save("capture_multi", mix((0, bonk(200, 0.2, 0.8)),
                              *[(0.05 + k * 0.07, marimba(n * 2, 0.35, 0.5)) for k, n in enumerate(notes)],
                              (0.05, squeak(800, 2100, 0.3, 0.3))))
    save("invalid", mix((0, boing(180, 0.25, 0.6, 20)), (0, bonk(110, 0.12, 0.5))))
    save("turn", mix((0, marimba(784, 0.25, 0.5)), (0.09, marimba(988, 0.3, 0.5))))
    save("hint", mix((0, marimba(1047, 0.3, 0.45)), (0.12, marimba(1319, 0.3, 0.45)), (0.24, marimba(1568, 0.4, 0.45))))
    save("undo", mix((0, whoosh(2000, 500, 0.18, 0.4)), (0.12, pop(500, 800, 0.1, 0.5))))
    save("start", mix(*[(k * 0.09, marimba(f, 0.4, 0.55)) for k, f in enumerate([392, 523, 659, 784])],
                      (0.4, boing(520, 0.45, 0.4, 10))))
    win = [523, 659, 784, 1047, 784, 1047, 1319]
    save("win", mix(*[(k * 0.11, marimba(f, 0.55, 0.55)) for k, f in enumerate(win)],
                    (0.78, boing(660, 0.6, 0.35, 9)),
                    *[(0.05 + k * 0.17, squeak(1500, 2400, 0.08, 0.15)) for k in range(5)]))
    save("lose", mix((0, trombone(330, 300, 0.4)), (0.4, trombone(300, 270, 0.4)),
                     (0.8, trombone(270, 150, 0.7))))
    save("draw", mix((0, marimba(587, 0.3, 0.5)), (0.15, marimba(587, 0.3, 0.5)), (0.3, marimba(494, 0.5, 0.5))))
    print("done:", len(os.listdir(OUT)), "files")


if __name__ == "__main__":
    main()
