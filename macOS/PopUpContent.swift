import SwiftUI

struct PopUpContent: View {
    static let size = CGSize(width: 640, height: 560)
    static let worldWidth: CGFloat = 360

    let zones: ZoneList
    let moment: ChosenMoment

    @State private var settings = SettingsPage.shared

    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    WorldPanel(zones: zones, moment: moment)
                        .frame(width: Self.worldWidth)
                    Divider()
                    CalendarPanel(zones: zones, moment: moment)
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
