import SwiftUI

/// The four weekly moods, laid out on two axes: energy (high/low) × feeling (good/bad).
enum Mood: String, CaseIterable, Identifiable, Codable {
    case hyped
    case chill
    case melancholy
    case restless

    var id: String { rawValue }

    var title: String {
        switch self {
        case .hyped: "Hyped"
        case .chill: "Chill"
        case .melancholy: "Melancholy"
        case .restless: "Restless"
        }
    }

    var subtitle: String {
        switch self {
        case .hyped: "High energy, feeling good"
        case .chill: "Low key, feeling good"
        case .melancholy: "Low key, feeling down"
        case .restless: "High energy, on edge"
        }
    }

    var playlistStyle: String {
        switch self {
        case .hyped: "Upbeat pop & dance"
        case .chill: "Lo-fi & acoustic"
        case .melancholy: "Slow, heartfelt ballads"
        case .restless: "Intense rock & electronic"
        }
    }

    /// SF Symbol name.
    var icon: String {
        switch self {
        case .hyped: "bolt.fill"
        case .chill: "moon.stars.fill"
        case .melancholy: "cloud.rain.fill"
        case .restless: "flame.fill"
        }
    }

    var colors: [Color] {
        switch self {
        case .hyped: [Color(hex: 0xFF4FD8), Color(hex: 0xB14EFF)]
        case .chill: [Color(hex: 0x4FC3FF), Color(hex: 0x7B5CFF)]
        case .melancholy: [Color(hex: 0x5468FF), Color(hex: 0x2B2D6E)]
        case .restless: [Color(hex: 0xFF5E5E), Color(hex: 0x9B2CFF)]
        }
    }
}
