import XCTest
@testable import MoodStream

@MainActor
final class MoodStoreTests: XCTestCase {
    private var defaults: UserDefaults!
    private let suiteName = "MoodStoreTests"

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
    }

    // Wednesday, 2026-11-18 12:00 local time.
    private let wednesday = MoodStore.calendar.date(from: DateComponents(year: 2026, month: 11, day: 18, hour: 12))!

    private func date(daysAfterWednesday days: Int) -> Date {
        MoodStore.calendar.date(byAdding: .day, value: days, to: wednesday)!
    }

    func testNeedsCheckInWhenNothingPicked() {
        let store = MoodStore(defaults: defaults, now: { self.wednesday })
        XCTAssertNil(store.currentMood)
        XCTAssertTrue(store.needsCheckIn)
    }

    func testPickedMoodLastsForTheRestOfTheWeek() {
        var now = wednesday
        let store = MoodStore(defaults: defaults, now: { now })
        store.select(.chill)

        now = date(daysAfterWednesday: 4) // Sunday, same week
        XCTAssertEqual(store.currentMood, .chill)
        XCTAssertFalse(store.needsCheckIn)
    }

    func testNewWeekStartsOnMondayAndAsksAgain() {
        var now = wednesday
        let store = MoodStore(defaults: defaults, now: { now })
        store.select(.hyped)

        now = date(daysAfterWednesday: 5) // Monday
        XCTAssertNil(store.currentMood)
        XCTAssertTrue(store.needsCheckIn)
    }

    func testMoodIsPersistedAcrossLaunches() {
        MoodStore(defaults: defaults, now: { self.wednesday }).select(.melancholy)
        let relaunched = MoodStore(defaults: defaults, now: { self.wednesday })
        XCTAssertEqual(relaunched.currentMood, .melancholy)
    }

    func testRequestedCheckInClearsAfterSelecting() {
        let store = MoodStore(defaults: defaults, now: { self.wednesday })
        store.select(.restless)
        store.isCheckInRequested = true
        XCTAssertTrue(store.needsCheckIn)

        store.select(.chill)
        XCTAssertFalse(store.needsCheckIn)
        XCTAssertEqual(store.currentMood, .chill)
    }
}
