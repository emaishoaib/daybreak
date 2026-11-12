import SwiftUI

struct HereHeading: View {
    let moment: ChosenMoment

    @State private var country = HomeCountry.shared

    var body: some View {
        TimelineView(.everyMinute) { context in
            let date = moment.date(at: context.date)
            HStack {
                HStack(spacing: 8) {
                    Text(date.formatted(.dateTime.hour().minute()))
                        .monospacedDigit()
                    Text(place(at: date))
                }
                .headingPill()
                Spacer()
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 6)
        .task { await country.load() }
    }

    private func place(at date: Date) -> String {
        let zone = TimeZone.autoupdatingCurrent.abbreviation(for: date) ?? TimeZone.autoupdatingCurrent.identifier
        guard let name = country.name else { return zone }
        return "\(name) (\(zone))"
    }
}
