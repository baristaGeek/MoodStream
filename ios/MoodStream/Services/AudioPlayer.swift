import AVFoundation

/// Plays a queue of songs with AVAudioPlayer. Keeps playing in the background
/// (UIBackgroundModes: audio) and advances to the next song automatically.
@MainActor
final class AudioPlayer: NSObject, ObservableObject {
    @Published private(set) var queue: [Song] = []
    @Published private(set) var currentIndex: Int?
    @Published private(set) var isPlaying = false
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0

    private var player: AVAudioPlayer?
    private var timer: Timer?

    var currentSong: Song? {
        guard let currentIndex, queue.indices.contains(currentIndex) else { return nil }
        return queue[currentIndex]
    }

    override init() {
        super.init()
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
    }

    func play(_ songs: [Song], startingAt index: Int = 0) {
        queue = songs
        load(index: index)
    }

    func togglePlayPause() {
        guard let player else { return }
        if player.isPlaying {
            player.pause()
            isPlaying = false
            stopTimer()
        } else {
            resume()
        }
    }

    func next() {
        guard let currentIndex, currentIndex + 1 < queue.count else {
            stop()
            return
        }
        load(index: currentIndex + 1)
    }

    /// Restarts the song if we're more than 3 seconds in, otherwise goes back one.
    func previous() {
        guard let currentIndex else { return }
        if currentTime > 3 || currentIndex == 0 {
            seek(to: 0)
        } else {
            load(index: currentIndex - 1)
        }
    }

    func seek(to time: TimeInterval) {
        player?.currentTime = time
        currentTime = time
    }

    private func load(index: Int) {
        guard queue.indices.contains(index), let url = queue[index].fileURL else { return }
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.delegate = self
            self.player = player
            currentIndex = index
            duration = player.duration
            currentTime = 0
            resume()
        } catch {
            print("AudioPlayer: couldn't load \(url.lastPathComponent): \(error)")
        }
    }

    private func resume() {
        try? AVAudioSession.sharedInstance().setActive(true)
        player?.play()
        isPlaying = true
        startTimer()
    }

    private func stop() {
        player?.stop()
        player?.currentTime = 0
        currentTime = 0
        isPlaying = false
        stopTimer()
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, let player = self.player else { return }
                self.currentTime = player.currentTime
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

extension AudioPlayer: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in self.next() }
    }
}
