import SwiftUI

/// Screen 2: playback for the current song.
struct NowPlayingView: View {
    let mood: Mood

    @EnvironmentObject private var player: AudioPlayer
    @Environment(\.dismiss) private var dismiss
    @State private var scrubTime: TimeInterval?

    var body: some View {
        ZStack {
            LinearGradient(colors: [mood.colors[1].opacity(0.55), Theme.background],
                           startPoint: .top, endPoint: .center)
                .ignoresSafeArea()

            VStack(spacing: 28) {
                topBar
                Spacer(minLength: 0)
                artwork
                Spacer(minLength: 0)
                songInfo
                progress
                transport
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .foregroundStyle(.white)
        .background(Theme.background)
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.down").font(.title3.weight(.semibold))
            }
            .accessibilityLabel("Close")
            Spacer()
            VStack(spacing: 2) {
                Text("PLAYING FROM").font(.caption2.weight(.bold)).tracking(1.5)
                    .foregroundStyle(Theme.secondaryText)
                Text("\(mood.title) Week").font(.subheadline.weight(.semibold))
            }
            Spacer()
            Image(systemName: "ellipsis").font(.title3).opacity(0) // balances the close button
        }
        .padding(.top, 8)
    }

    private var artwork: some View {
        RoundedRectangle(cornerRadius: 24)
            .fill(LinearGradient(colors: mood.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                Image(systemName: mood.icon)
                    .font(.system(size: 110))
                    .foregroundStyle(.white.opacity(0.9))
                    .symbolEffect(.pulse, isActive: player.isPlaying)
            )
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Theme.neon.opacity(0.8), lineWidth: 1.5))
            .neonGlow(radius: player.isPlaying ? 28 : 12)
            .scaleEffect(player.isPlaying ? 1 : 0.92)
            .animation(.spring(response: 0.45), value: player.isPlaying)
    }

    private var songInfo: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(player.currentSong?.title ?? "Not playing")
                    .font(.title2.weight(.bold))
                Text(player.currentSong?.artist ?? "—")
                    .foregroundStyle(Theme.secondaryText)
            }
            Spacer()
            Image(systemName: "heart")
                .font(.title2)
                .foregroundStyle(Theme.neon)
        }
    }

    private var progress: some View {
        VStack(spacing: 6) {
            Slider(
                value: Binding(
                    get: { scrubTime ?? player.currentTime },
                    set: { scrubTime = $0 }
                ),
                in: 0...max(player.duration, 1),
                onEditingChanged: { editing in
                    if !editing, let scrubTime {
                        player.seek(to: scrubTime)
                        self.scrubTime = nil
                    }
                }
            )
            .tint(Theme.neon)
            HStack {
                Text(formatTime(scrubTime ?? player.currentTime))
                Spacer()
                Text("-" + formatTime(max(player.duration - (scrubTime ?? player.currentTime), 0)))
            }
            .font(.caption.monospacedDigit())
            .foregroundStyle(Theme.secondaryText)
        }
    }

    private var transport: some View {
        HStack {
            Button { player.previous() } label: {
                Image(systemName: "backward.fill").font(.title)
            }
            .accessibilityLabel("Previous")
            Spacer()
            Button { player.togglePlayPause() } label: {
                Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 30, weight: .bold))
                    .frame(width: 76, height: 76)
                    .background(Circle().fill(Theme.neon))
            }
            .neonGlow(radius: 18)
            .accessibilityLabel(player.isPlaying ? "Pause" : "Play")
            Spacer()
            Button { player.next() } label: {
                Image(systemName: "forward.fill").font(.title)
            }
            .accessibilityLabel("Next")
        }
        .padding(.horizontal, 24)
    }
}
