import SwiftUI

@main
struct MoodStreamApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(appDelegate.moodStore)
                .environmentObject(appDelegate.player)
                .preferredColorScheme(.dark)
                .task { await NotificationScheduler.setUp() }
        }
    }
}
