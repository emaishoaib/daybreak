import SwiftUI

struct PopUpContent: View {
    static let width: CGFloat = 360
    static let heightWithoutMonth: CGFloat = 560

    @MainActor
    static var height: CGFloat {
        heightWithoutMonth + MonthPage.shared.addedHeight
    }

    let zones: ZoneList
    let moment: ChosenMoment

    @State private var settings = SettingsPage.shared

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                WorldPanel(zones: zones, moment: moment)
                Divider()
                FooterBar()
            }
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
