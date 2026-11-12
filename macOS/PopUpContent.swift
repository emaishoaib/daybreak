import SwiftUI

struct PopUpContent: View {
    static let width: CGFloat = 360

    @MainActor
    static var height: CGFloat {
        PopUpLayout.shared.contentHeight
    }

    let zones: ZoneList
    let moment: ChosenMoment

    @State private var settings = SettingsPage.shared
    @State private var layout = PopUpLayout.shared

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                WorldPanel(zones: zones, moment: moment)
                FooterBar()
            }
            .fixedSize(horizontal: false, vertical: true)
            .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { layout.contentHeight = $0 }
            if settings.isShown {
                SettingsView()
            }
        }
        .frame(width: Self.width)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(Palette.night)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
