# MoodStream iOS

SwiftUI app (iOS 17+). Pick your mood each week and get a playlist that matches it.
Uses mock songs for now; there's no login, backend or AI yet.

## Setup

1. Install **Xcode** from the Mac App Store, then point the command-line tools at it:
   `sudo xcode-select -s /Applications/Xcode.app`
2. Install XcodeGen: `brew install xcodegen`
3. Generate and open the project (run again after adding/removing files):
   ```sh
   cd ios
   xcodegen generate
   open MoodStream.xcodeproj
   ```

## Run on your iPhone (free Apple ID)

1. Xcode → Settings → Accounts → add your Apple ID.
2. Copy `Config/Local.xcconfig.example` to `Config/Local.xcconfig` and set `DEVELOPMENT_TEAM`
   to your Team ID (shown under your account in Xcode). Re-run `xcodegen generate`.
   If Xcode says the bundle id is taken, set `MOODSTREAM_BUNDLE_ID` there too.
3. Plug in the iPhone, trust the computer, and turn on **Settings → Privacy & Security → Developer Mode** (the phone restarts).
4. Select your iPhone as the run destination and press **⌘R**.
5. The first launch is blocked until you trust the developer: **Settings → General → VPN & Device Management** → your Apple ID → Trust.

Apps signed with a free Apple ID expire after 7 days; just run from Xcode again.

## Trying the flow

- First launch asks for notification permission, then shows the mood check-in.
- Pick a mood → **Create my playlist** → tap a song (or the purple play button) for the player.
- **Change mood** goes back to the check-in.
- The weekly reminder fires Mondays at 9:00. In Debug builds, the 🔔 button on the playlist
  sends it in 5 seconds — lock the phone to see it arrive, then tap it to open the check-in.
- Tests: **⌘U** in Xcode.

## Layout

```
MoodStream/
  App/        entry point, AppDelegate (notification taps), RootView (routing)
  Models/     Mood, Song/Playlist, MockLibrary
  Services/   PlaylistGenerator, MoodStore, AudioPlayer, NotificationScheduler
  Views/      MoodCheckInView, PlaylistView, NowPlayingView, Theme
  Resources/  Assets, Audio (generated mock songs)
scripts/      generate_mock_audio.py, generate_app_icon.py
```

`PlaylistGenerator` is where generative AI will plug in later.
