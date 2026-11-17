import XCTest
@testable import MoodStream

final class PlaylistGeneratorTests: XCTestCase {
    func testPlaylistOnlyContainsSongsForTheChosenMood() {
        let generator = PlaylistGenerator()
        for mood in Mood.allCases {
            let playlist = generator.playlist(for: mood, weekStart: .now)
            XCTAssertEqual(playlist.mood, mood)
            XCTAssertFalse(playlist.songs.isEmpty, "\(mood) has no songs")
            XCTAssertTrue(playlist.songs.allSatisfy { $0.mood == mood })
        }
    }

    func testEveryMockSongHasABundledAudioFile() {
        for song in MockLibrary.songs {
            XCTAssertNotNil(Bundle(for: AppDelegate.self).url(forResource: song.id, withExtension: "m4a"),
                            "Missing audio for \(song.id)")
        }
    }
}
