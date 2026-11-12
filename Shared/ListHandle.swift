import SwiftUI

struct ListHandle: View {
    var body: some View {
        Capsule()
            .fill(.tertiary)
            .frame(width: 36, height: 4)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
            .contentShape(Rectangle())
            .accessibilityLabel("Resize the globe")
            .accessibilityAddTraits(.isButton)
    }
}
