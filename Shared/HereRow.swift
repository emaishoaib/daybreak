import SwiftUI

struct HereRow: View {
    let date: Date

    @State private var country = HomeCountry.shared

    var body: some View {
        let zone = TimeZone.autoupdatingCurrent

        HStack(spacing: 10) {
            Image(systemName: "location.fill")
                .foregroundStyle(.blue)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 1) {
                Text("\(country.name ?? zone.identifier) \(Text("(\(zone.abbreviation(for: date) ?? zone.identifier))").foregroundStyle(.secondary))")
                    .lineLimit(1)
                Text("You're here")
                    .font(.caption)
                    .foregroundStyle(.blue)
            }
            Spacer()
            Text(date.formatted(.dateTime.hour().minute()))
                .font(.title3)
                .monospacedDigit()
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(.blue.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))
        .task { await country.load() }
    }
}
