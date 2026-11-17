import Foundation

struct Song: Identifiable, Equatable {
    let id: String
    let title: String
    let artist: String
    let mood: Mood

    /// The bundled audio file. `id` doubles as the file name (without extension).
    var fileURL: URL? {
        Bundle.main.url(forResource: id, withExtension: "m4a")
    }
}

struct Playlist: Equatable {
    let mood: Mood
    let weekStart: Date
    let songs: [Song]

    var title: String { "\(mood.title) Week" }
}
