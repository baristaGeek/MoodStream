import UserNotifications

/// Schedules the weekly "What's your mood this week?" reminder as a local notification,
/// so no server or paid Apple Developer account is needed.
enum NotificationScheduler {
    static let checkInCategory = "MOOD_CHECK_IN"
    private static let weeklyID = "weekly-mood-check-in"

    /// Asks for permission (once) and schedules Mondays at 09:00 local time.
    static func setUp() async {
        let center = UNUserNotificationCenter.current()
        guard (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) == true else { return }

        var monday = DateComponents()
        monday.weekday = 2 // Sunday = 1
        monday.hour = 9
        let trigger = UNCalendarNotificationTrigger(dateMatching: monday, repeats: true)
        try? await center.add(UNNotificationRequest(identifier: weeklyID, content: content(), trigger: trigger))
    }

    /// Fires the same notification in a few seconds, for testing without waiting for Monday.
    static func sendTest(after seconds: TimeInterval = 5) async {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        try? await UNUserNotificationCenter.current()
            .add(UNNotificationRequest(identifier: UUID().uuidString, content: content(), trigger: trigger))
    }

    private static func content() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "New week, new soundtrack 🎧"
        content.body = "What's your mood this week?"
        content.sound = .default
        content.categoryIdentifier = checkInCategory
        return content
    }
}
