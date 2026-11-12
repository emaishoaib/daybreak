import SwiftUI

struct PopUpContent: View {
    static let size = CGSize(width: 640, height: 560)
    static let worldWidth: CGFloat = 360

    @State private var settings = SettingsPage.shared

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    PanelPlaceholder(title: "World")
                        .frame(width: Self.worldWidth)
                    Divider()
                    PanelPlaceholder(title: "Calendar")
                }
                Divider()
                FooterBar()
            }
            .frame(width: Self.size.width, height: Self.size.height)
            if settings.isShown {
                SettingsView()
                    .frame(width: Self.worldWidth, height: Self.size.height)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
        .background(Palette.night)
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
