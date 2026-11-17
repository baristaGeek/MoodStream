import SwiftUI

enum Theme {
    static let neon = Color(hex: 0xB14EFF)
    static let neonSoft = Color(hex: 0xD9A6FF)
    static let background = Color(hex: 0x0B0712)
    static let card = Color(hex: 0x1A1325)
    static let secondaryText = Color.white.opacity(0.6)
}

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

extension View {
    /// Layered purple glow used for highlighted controls.
    func neonGlow(_ color: Color = Theme.neon, radius: CGFloat = 12) -> some View {
        shadow(color: color.opacity(0.9), radius: radius / 3)
            .shadow(color: color.opacity(0.6), radius: radius)
    }
}

func formatTime(_ seconds: TimeInterval) -> String {
    let total = Int(seconds.rounded(.down))
    return String(format: "%d:%02d", total / 60, total % 60)
}
