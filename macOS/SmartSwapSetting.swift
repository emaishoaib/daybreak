import SwiftUI

enum SmartSwapSetting {
    static let key = "smartSwap"
}

struct SmartSwapToggle: View {
    @AppStorage(SmartSwapSetting.key) private var isOn = false

    var body: some View {
        Toggle(isOn: $isOn) {
            Text("Smart swap")
            Text("When you travel to a place on your list, swap it for the place you left.")
        }
    }
}
