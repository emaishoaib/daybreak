import SwiftUI

struct HereRow: View {
    let date: Date

    @State private var here = Here.shared

    var body: some View {
        let zone = here.timeZone.abbreviation(for: date) ?? here.timeZone.identifier

        HStack(spacing: RowLayout.columnSpacing) {
            Image(systemName: "location.fill")
                .foregroundStyle(.blue)
                .frame(width: RowLayout.leadingWidth)
            VStack(alignment: .leading, spacing: 1) {
                Text("\(here.country ?? here.timeZone.identifier) \(Text("(\(zone))").foregroundStyle(.secondary))")
                    .lineLimit(1)
                Text("You're here")
                    .font(.caption)
                    .foregroundStyle(.blue)
            }
            Spacer()
            Text(date.formatted(here.style(.dateTime.hour().minute())))
                .font(.title3)
                .monospacedDigit()
        }
        .padding(.vertical, 2)
    }
}
