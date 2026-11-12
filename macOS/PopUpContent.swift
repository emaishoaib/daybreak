import SwiftUI

struct PopUpContent: View {
    static let size = CGSize(width: 640, height: 560)
    static let worldWidth: CGFloat = 360

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                PanelPlaceholder(title: "World")
                    .frame(width: Self.worldWidth)
                Divider()
                PanelPlaceholder(title: "Calendar")
            }
            Divider()
            QuitBar()
        }
        .frame(width: Self.size.width, height: Self.size.height)
        .background(Color(white: 0.11))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

private struct PanelPlaceholder: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.title3)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
