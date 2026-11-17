import SwiftUI

/// Screen 1b: the week's playlist for the chosen mood.
struct PlaylistView: View {
    let playlist: Playlist

    @EnvironmentObject private var moodStore: MoodStore
    @EnvironmentObject private var player: AudioPlayer
    @State private var isNowPlayingPresented = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header
                controls
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                VStack(spacing: 4) {
                    ForEach(Array(playlist.songs.enumerated()), id: \.element.id) { index, song in
                        SongRow(index: index, song: song, isCurrent: player.currentSong == song, isPlaying: player.isPlaying)
                            .onTapGesture { play(from: index) }
                    }
                }
                .padding(.horizontal, 12)
            }
            .padding(.bottom, 40)
        }
        .ignoresSafeArea(edges: .top)
        .foregroundStyle(.white)
        .fullScreenCover(isPresented: $isNowPlayingPresented) {
            NowPlayingView(mood: playlist.mood)
        }
    }

    private var header: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: playlist.mood.colors + [Theme.background],
                           startPoint: .topLeading, endPoint: .bottom)
                .frame(height: 340)

            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: playlist.mood.icon)
                    .font(.system(size: 44))
                    .neonGlow(.white, radius: 10)
                Text("YOUR WEEK")
                    .font(.caption.weight(.bold))
                    .tracking(2)
                    .foregroundStyle(.white.opacity(0.75))
                Text(playlist.title)
                    .font(.system(size: 38, weight: .heavy))
                Text("\(playlist.mood.playlistStyle) · \(playlist.songs.count) songs · Week of \(playlist.weekStart.formatted(.dateTime.month().day()))")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.75))
            }
            .padding(20)
        }
    }

    private var controls: some View {
        HStack {
            Button {
                moodStore.isCheckInRequested = true
            } label: {
                Label("Change mood", systemImage: "arrow.triangle.2.circlepath")
                    .font(.subheadline.weight(.semibold))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(Capsule().stroke(.white.opacity(0.3)))
            }

            #if DEBUG
            Button {
                Task { await NotificationScheduler.sendTest() }
            } label: {
                Image(systemName: "bell.badge")
                    .padding(9)
                    .background(Circle().stroke(.white.opacity(0.3)))
            }
            .accessibilityLabel("Send test notification in 5 seconds")
            #endif

            Spacer()

            Button {
                if isPlayingThisPlaylist {
                    isNowPlayingPresented = true
                } else {
                    play(from: 0)
                }
            } label: {
                Image(systemName: isPlayingThisPlaylist && player.isPlaying ? "waveform" : "play.fill")
                    .font(.title2.weight(.bold))
                    .frame(width: 60, height: 60)
                    .background(Circle().fill(Theme.neon))
                    .foregroundStyle(.white)
            }
            .neonGlow()
        }
    }

    private var isPlayingThisPlaylist: Bool {
        player.currentSong.map { playlist.songs.contains($0) } ?? false
    }

    private func play(from index: Int) {
        if player.currentSong != playlist.songs[index] {
            player.play(playlist.songs, startingAt: index)
        }
        isNowPlayingPresented = true
    }
}

private struct SongRow: View {
    let index: Int
    let song: Song
    let isCurrent: Bool
    let isPlaying: Bool

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(LinearGradient(colors: song.mood.colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 48, height: 48)
                Image(systemName: isCurrent && isPlaying ? "waveform" : song.mood.icon)
                    .foregroundStyle(.white)
                    .symbolEffect(.variableColor.iterative, isActive: isCurrent && isPlaying)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(song.title)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(isCurrent ? Theme.neonSoft : .white)
                Text(song.artist)
                    .font(.subheadline)
                    .foregroundStyle(Theme.secondaryText)
            }
            Spacer()
            Image(systemName: "ellipsis")
                .foregroundStyle(Theme.secondaryText)
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 12).fill(isCurrent ? Theme.card : .clear))
        .contentShape(Rectangle())
    }
}
