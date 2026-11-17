import Foundation

/// Turns a mood into the week's playlist. Today it filters the mock library;
/// this is where the generative AI will plug in later.
struct PlaylistGenerator {
    var library: [Song] = MockLibrary.songs

    func playlist(for mood: Mood, weekStart: Date) -> Playlist {
        Playlist(mood: mood, weekStart: weekStart, songs: library.filter { $0.mood == mood })
    }
}
