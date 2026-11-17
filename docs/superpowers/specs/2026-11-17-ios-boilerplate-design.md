# MoodStream iOS boilerplate — design

Date: 2026-11-17 · Status: approved

## Goal

A minimal SwiftUI app the owner can run on their iPhone 15 to prove the core loop:
weekly mood check-in → mood-matched playlist → audio playback. No login, no backend,
no generative AI yet.

## Moods

Two axes, energy × feeling:

| Mood       | Energy | Feeling  | Music                    |
|------------|--------|----------|--------------------------|
| Hyped      | High   | Positive | Upbeat pop / dance       |
| Chill      | Low    | Positive | Lo-fi / acoustic         |
| Melancholy | Low    | Negative | Slow, sad ballads        |
| Restless   | High   | Negative | Intense rock / electronic |

## Screens

1. **Mood check-in** — "What's your mood this week?" with 4 neon tiles. Shown when no mood
   is picked for the current week (ISO week, Monday start) or when the Monday notification is tapped.
2. **Playlist** — mood gradient header, neon play button, track list, "Change mood".
3. **Now playing** — artwork, title/artist, progress slider, previous / play-pause / next.

Visual style: dark, Spotify-like, purple neon highlights.

## Components

- `Mood` — enum with name, icon, colors.
- `Song`, `MockLibrary` — 12 mock songs (3 per mood) bundled as generated audio clips.
- `PlaylistGenerator` — mood → playlist. Seam for the future AI generator.
- `MoodStore` — persists mood + week in `UserDefaults`; decides whether a check-in is due.
- `AudioPlayer` — `AVAudioPlayer` wrapper: queue, play/pause, next/previous, seek, auto-advance,
  background playback.
- `NotificationScheduler` — local repeating notification, Mondays 09:00 (no APNs / paid account).

## Testing

- Unit tests for `PlaylistGenerator` and `MoodStore`.
- Debug-only button that fires the check-in notification in 5 seconds.

## Out of scope

Login, backend, AI, mini player, real music, lock-screen controls.

## Tooling

XcodeGen (`ios/project.yml`) generates the Xcode project; the `.xcodeproj` is not committed.
Signing team lives in a git-ignored `ios/Config/Local.xcconfig`.
