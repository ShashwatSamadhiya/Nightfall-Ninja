"""Generate chiptune-style WAV sound effects and a music loop for Dash Runner."""
import math
import os
import random
import struct
import wave

SR = 22050
OUT = "/Users/farmsetu/Desktop/game/assets/audio"


def write_wav(name, samples):
    path = os.path.join(OUT, name)
    with wave.open(path, "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        frames = b"".join(
            struct.pack("<h", int(max(-1.0, min(1.0, s)) * 32767)) for s in samples
        )
        w.writeframes(frames)
    print(f"{name}: {os.path.getsize(path) / 1024:.0f} KB")


def env(i, n, attack=0.005, release=0.03):
    t = i / SR
    total = n / SR
    if t < attack:
        return t / attack
    if t > total - release:
        return max(0.0, (total - t) / release)
    return 1.0


def sq(phase):
    return 1.0 if (phase % 1.0) < 0.5 else -1.0


def sweep(f0, f1, dur, amp=0.5):
    n = int(SR * dur)
    out = []
    ph = 0.0
    for i in range(n):
        t = i / n
        f = f0 * (f1 / f0) ** t
        ph += f / SR
        out.append(sq(ph) * amp * env(i, n))
    return out


def tone(freq, dur, amp=0.45):
    n = int(SR * dur)
    return [math.sin(2 * math.pi * freq * i / SR) * amp * env(i, n) for i in range(n)]


os.makedirs(OUT, exist_ok=True)
random.seed(7)

# --- SFX -------------------------------------------------------------------
write_wav("jump.wav", sweep(320, 760, 0.14))
write_wav("double_jump.wav", sweep(480, 1100, 0.14))
write_wav("point.wav", tone(880, 0.07) + tone(1318.5, 0.11))

hit = sweep(380, 90, 0.3, amp=0.45)
for i in range(len(hit)):
    hit[i] += (random.random() * 2 - 1) * 0.28 * (1 - i / len(hit))
write_wav("hit.wav", hit)

# --- Music loop: 8 bars at 140 BPM, C major --------------------------------
BPM = 140
Q = 60 / BPM  # quarter note seconds
F = {
    "F2": 87.31, "G2": 98.00, "A2": 110.00, "C3": 130.81,
    "C4": 261.63, "D4": 293.66, "E4": 329.63, "F4": 349.23,
    "G4": 392.00, "A4": 440.00, "C5": 523.25,
}
MELODY = ("C4 E4 G4 E4 A4 G4 E4 D4 G4 E4 D4 C4 D4 E4 G4 A4 "
          "C5 A4 G4 E4 A4 G4 E4 D4 A4 C5 A4 F4 G4 A4 G4 D4").split()
BASS = ["C3", "C3", "G2", "G2", "A2", "A2", "F2", "G2"]

total = int(SR * Q * 32)
out = [0.0] * total


def add(start, samples):
    for i, s in enumerate(samples):
        j = start + i
        if 0 <= j < total:
            out[j] += s


# Melody: quarter notes, square wave.
for idx, name in enumerate(MELODY):
    f = F[name]
    n = int(Q * SR * 0.92)
    ph = 0.0
    buf = []
    for i in range(n):
        ph += f / SR
        buf.append(sq(ph) * 0.12 * env(i, n, 0.008, 0.06))
    add(int(idx * Q * SR), buf)

# Bass: eighth-note pulses on the bar's root.
for bar in range(8):
    f = F[BASS[bar]]
    for e in range(8):
        n = int(Q * SR * 0.45)
        ph = 0.0
        buf = []
        for i in range(n):
            ph += f / SR
            buf.append(sq(ph) * 0.085 * env(i, n, 0.005, 0.05))
        add(int((bar * 4 + e * 0.5) * Q * SR), buf)

# Kick thump on every beat.
for beat in range(32):
    n = int(0.09 * SR)
    ph = 0.0
    buf = []
    for i in range(n):
        t = i / SR
        ph += (60 + 110 * math.exp(-t * 25)) / SR
        buf.append(math.sin(2 * math.pi * ph) * 0.3 * (1 - i / n))
    add(int(beat * Q * SR), buf)

# Hi-hat ticks on the offbeats.
for beat in range(32):
    n = int(0.03 * SR)
    buf = [(random.random() * 2 - 1) * 0.05 * (1 - i / n) for i in range(n)]
    add(int((beat + 0.5) * Q * SR), buf)

write_wav("bgm.wav", out)

# Coin pickup: quick bright two-note ding.
write_wav("coin.wav", tone(1318.5, 0.05, amp=0.38) + tone(1760, 0.09, amp=0.38))
