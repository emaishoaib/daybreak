import SwiftUI

struct MenuBarPin: View {
    let isPinned: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            Image(systemName: isPinned ? "pin.fill" : "pin")
                .rotationEffect(.degrees(45))
                .foregroundStyle(isPinned ? AnyShapeStyle(.orange) : AnyShapeStyle(.tertiary))
                .frame(width: RowLayout.leadingWidth, height: RowLayout.leadingWidth)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(isPinned ? "Remove from the menu bar" : "Show in the menu bar")
        .accessibilityLabel(isPinned ? "Remove from the menu bar" : "Show in the menu bar")
    }
}
