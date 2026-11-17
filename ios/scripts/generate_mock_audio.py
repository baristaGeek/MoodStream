#!/usr/bin/env python3
"""Generate the mock songs bundled with the app.

Each mood gets 3 short synthesized clips whose tempo, key and timbre match it,
so you can hear that the right playlist was picked. Standard library only;
converts WAV to AAC (.m4a) with macOS's built-in `afconvert`.

Usage: python3 scripts/generate_mock_audio.py   (run from ios/)
"""
import math
import os
import random
import struct
import subprocess
import wave

SAMPLE_RATE = 22050
DURATION = 20.0
OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "MoodStream", "Resources", "Audio")

MAJOR = [0, 2, 4, 5, 7, 9, 11]
MINOR = [0, 2, 3, 5, 7, 8, 10]

# Each mood: tempo, scale, chord progression (scale degrees), lead waveform, notes per beat.
MOODS = {
    "hyped": dict(bpm=128, scale=MAJOR, progression=[0, 4, 5, 3], wave="square", subdivision=2, drums=True),
    "chill": dict(bpm=78, scale=MAJOR, progression=[0, 5, 3, 4], wave="sine", subdivision=1, drums=False),
    "melancholy": dict(bpm=62, scale=MINOR, progression=[0, 5, 2, 6], wave="sine", subdivision=1, drums=False),
    "restless": dict(bpm=150, scale=MINOR, progression=[0, 0, 5, 6], wave="saw", subdivision=4, drums=True),
}

# (file name, root MIDI note, random seed): three different songs per mood.
SONGS = {
    "hyped": [("hyped_neon_rush", 60, 1), ("hyped_sunrise_sprint", 62, 2), ("hyped_turn_it_up", 65, 3)],
    "chill": [("chill_slow_sunday", 60, 4), ("chill_paper_lanterns", 57, 5), ("chill_cloud_drift", 62, 6)],
    "melancholy": [("melancholy_rainy_window", 57, 7), ("melancholy_letters_unsent", 55, 8), ("melancholy_fading_polaroid", 60, 9)],
    "restless": [("restless_static_storm", 52, 10), ("restless_cant_sit_still", 55, 11), ("restless_midnight_pulse", 50, 12)],
}


def freq(midi):
    return 440.0 * 2 ** ((midi - 69) / 12)


def osc(kind, phase):
    p = phase % 1.0
    if kind == "square":
        return 0.6 if p < 0.5 else -0.6
    if kind == "saw":
        return 2 * p - 1
    return math.sin(2 * math.pi * p)


def scale_note(root, scale, degree):
    octave, step = divmod(degree, len(scale))
    return root + 12 * octave + scale[step]


def render(mood, root, seed):
    cfg = MOODS[mood]
    rng = random.Random(seed)
    n = int(SAMPLE_RATE * DURATION)
    buf = [0.0] * n
    beat = 60.0 / cfg["bpm"]
    bar = beat * 4

    def add_note(start, length, midi, kind, amp, attack=0.01, release=0.08):
        f = freq(midi)
        s0 = int(start * SAMPLE_RATE)
        count = int(length * SAMPLE_RATE)
        for i in range(count):
            idx = s0 + i
            if idx >= n:
                break
            t = i / SAMPLE_RATE
            env = min(1.0, t / attack) * min(1.0, (length - t) / release)
            buf[idx] += amp * max(env, 0.0) * osc(kind, f * t)

    t = 0.0
    bar_index = 0
    while t < DURATION:
        degree = cfg["progression"][bar_index % len(cfg["progression"])]
        chord = [scale_note(root - 12, cfg["scale"], degree + d) for d in (0, 2, 4)]
        # Pad: sustained chord.
        for note in chord:
            add_note(t, bar, note, "sine", 0.10, attack=0.3, release=0.4)
        # Bass on every beat.
        for b in range(4):
            add_note(t + b * beat, beat * 0.9, chord[0] - 12, "sine", 0.22)
        # Lead: arpeggio / melody over the chord.
        step = beat / cfg["subdivision"]
        for k in range(4 * cfg["subdivision"]):
            if rng.random() < 0.15:
                continue
            note = scale_note(root, cfg["scale"], degree + rng.choice([0, 2, 4, 7]))
            add_note(t + k * step, step * 0.85, note, cfg["wave"], 0.12)
        # Simple drums: kick on beats, noise hat on off-beats.
        if cfg["drums"]:
            for b in range(4):
                s0 = int((t + b * beat) * SAMPLE_RATE)
                for i in range(int(0.15 * SAMPLE_RATE)):
                    if s0 + i < n:
                        tt = i / SAMPLE_RATE
                        buf[s0 + i] += 0.5 * math.exp(-tt * 25) * math.sin(2 * math.pi * (60 + 90 * math.exp(-tt * 40)) * tt)
                h0 = int((t + b * beat + beat / 2) * SAMPLE_RATE)
                for i in range(int(0.04 * SAMPLE_RATE)):
                    if h0 + i < n:
                        buf[h0 + i] += 0.08 * math.exp(-i / SAMPLE_RATE * 80) * rng.uniform(-1, 1)
        t += bar
        bar_index += 1

    # Fade in/out and normalize.
    fade = int(1.0 * SAMPLE_RATE)
    for i in range(fade):
        buf[i] *= i / fade
        buf[n - 1 - i] *= i / fade
    peak = max(abs(x) for x in buf) or 1.0
    return [x / peak * 0.85 for x in buf]


def write_m4a(name, samples):
    wav_path = os.path.join(OUT_DIR, name + ".wav")
    m4a_path = os.path.join(OUT_DIR, name + ".m4a")
    with wave.open(wav_path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SAMPLE_RATE)
        w.writeframes(b"".join(struct.pack("<h", int(s * 32767)) for s in samples))
    subprocess.run(["afconvert", "-f", "m4af", "-d", "aac", "-b", "64000", wav_path, m4a_path], check=True)
    os.remove(wav_path)
    print("wrote", os.path.relpath(m4a_path))


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    for mood, songs in SONGS.items():
        for name, root, seed in songs:
            write_m4a(name, render(mood, root, seed))


if __name__ == "__main__":
    main()
