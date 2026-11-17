import SwiftUI

struct RootView: View {
    @EnvironmentObject private var moodStore: MoodStore

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()

            if moodStore.needsCheckIn {
                MoodCheckInView()
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            } else if let mood = moodStore.currentMood {
                PlaylistView(playlist: PlaylistGenerator().playlist(
                    for: mood,
                    weekStart: MoodStore.startOfWeek(for: .now)
                ))
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: moodStore.needsCheckIn)
    }
}
