import os
import wave
import struct
import math
import random

os.makedirs("assets/sounds", exist_ok=True)
SAMPLE_RATE = 44100

def write_wav(filename, samples):
    path = os.path.join("assets/sounds", filename)
    max_val = max(abs(s) for s in samples) or 1.0
    scale = (0.707 * 32767) / max_val
    fade_len = int(0.004 * SAMPLE_RATE)
    for i in range(min(fade_len, len(samples))):
        samples[i] *= i / fade_len
        samples[-(i + 1)] *= i / fade_len
    with wave.open(path, "w") as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)
        wf.setframerate(SAMPLE_RATE)
        data = b"".join(struct.pack("<h", int(max(-32767, min(32767, s * scale)))) for s in samples)
        wf.writeframes(data)

def gen_knock(duration, freqs, decay):
    n = int(duration * SAMPLE_RATE)
    return [sum(math.sin(2 * math.pi * f * (i / SAMPLE_RATE)) for f in freqs) / len(freqs) * math.exp(-decay * (i / SAMPLE_RATE)) for i in range(n)]

def gen_tambour(duration, freq):
    n = int(duration * SAMPLE_RATE)
    delay = max(1, int(SAMPLE_RATE / freq))
    buf = [random.uniform(-1, 1) for _ in range(delay)]
    samples = []
    for i in range(n):
        val = buf[i % delay]
        samples.append(val)
        buf[i % delay] = 0.992 * 0.5 * (val + buf[(i + 1) % delay])
    return samples

def gen_doum(duration):
    n = int(duration * SAMPLE_RATE)
    samples = []
    phase = 0.0
    for i in range(n):
        t = i / SAMPLE_RATE
        freq = 130 * math.exp(-8 * t) + 55
        phase += 2 * math.pi * freq / SAMPLE_RATE
        samples.append(math.sin(phase) * math.exp(-6 * t))
    return samples

if __name__ == "__main__":
    write_wav("ui_tap.wav", gen_knock(0.06, [520, 880], 45))
    write_wav("select.wav", gen_knock(0.11, [410, 640, 980], 30))
    for idx in range(1, 4):
        write_wav(f"place_{idx}.wav", gen_knock(0.20, [260 + idx*15, 430], 20))
        write_wav(f"capture_{idx}.wav", gen_tambour(0.38, 293.66 * (1 + 0.1 * idx)))
    write_wav("slide.wav", [random.uniform(-0.3, 0.3) * math.sin(math.pi * i / (0.24 * SAMPLE_RATE)) for i in range(int(0.24 * SAMPLE_RATE))])
    write_wav("land.wav", gen_knock(0.12, [310, 510], 32))
    write_wav("capture_multi.wav", gen_doum(0.25) + gen_tambour(0.35, 392.0))
    write_wav("invalid.wav", gen_knock(0.07, [180, 240], 35) + gen_knock(0.08, [160, 220], 35))
    write_wav("turn.wav", gen_tambour(0.22, 293.66))
    write_wav("hint.wav", gen_tambour(0.32, 440.0))
    write_wav("undo.wav", gen_knock(0.22, [350, 220], 18))
    write_wav("start.wav", gen_tambour(0.25, 261.63) + gen_tambour(0.25, 349.23) + gen_tambour(0.25, 440.0))
    write_wav("win.wav", gen_tambour(0.3, 261.63) + gen_tambour(0.3, 329.63) + gen_tambour(0.3, 392.0) + gen_tambour(0.9, 523.25))
    write_wav("lose.wav", gen_tambour(0.5, 329.63) + gen_tambour(0.7, 261.63))
    write_wav("draw.wav", gen_tambour(0.4, 293.66) + gen_tambour(0.4, 293.66))
