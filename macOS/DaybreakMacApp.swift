import SwiftUI

@main
struct DaybreakMacApp: App {
    var body: some Scene {
        MenuBarExtra("Daybreak", systemImage: "sun.horizon") {
            Button("Quit Daybreak") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
    }
}
