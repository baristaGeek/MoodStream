import Foundation

/// Remembers the mood picked for the current week (weeks start on Monday).
@MainActor
final class MoodStore: ObservableObject {
    @Published private(set) var mood: Mood?
    @Published private(set) var weekStart: Date?
    /// Set when the user taps the weekly notification or "Change mood".
    @Published var isCheckInRequested = false

    private let defaults: UserDefaults
    private let now: () -> Date

    private static let moodKey = "weeklyMood"
    private static let weekKey = "weeklyMoodWeekStart"

    static var calendar: Calendar {
        var calendar = Calendar(identifier: .iso8601) // Monday-first weeks
        calendar.timeZone = .current
        return calendar
    }

    init(defaults: UserDefaults = .standard, now: @escaping () -> Date = Date.init) {
        self.defaults = defaults
        self.now = now
        mood = defaults.string(forKey: Self.moodKey).flatMap(Mood.init(rawValue:))
        weekStart = defaults.object(forKey: Self.weekKey) as? Date
    }

    static func startOfWeek(for date: Date) -> Date {
        calendar.dateInterval(of: .weekOfYear, for: date)?.start ?? date
    }

    /// The mood for the current week, or nil if it hasn't been picked yet.
    var currentMood: Mood? {
        guard let mood, weekStart == Self.startOfWeek(for: now()) else { return nil }
        return mood
    }

    var needsCheckIn: Bool { currentMood == nil || isCheckInRequested }

    func select(_ mood: Mood) {
        let week = Self.startOfWeek(for: now())
        self.mood = mood
        weekStart = week
        isCheckInRequested = false
        defaults.set(mood.rawValue, forKey: Self.moodKey)
        defaults.set(week, forKey: Self.weekKey)
    }
}
