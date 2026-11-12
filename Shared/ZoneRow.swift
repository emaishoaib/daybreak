import SwiftUI
import WorldTimeKit

struct ZoneRow: View {
    let place: Place
    let date: Date

    var body: some View {
        let home = Here.shared.timeZone

        HStack(spacing: 10) {
            DaylightIcon(daylight: place.daylight(at: date))
            VStack(alignment: .leading, spacing: 1) {
                Text("\(place.name) \(Text("(\(place.timeZone.abbreviation(for: date) ?? place.timeZoneIdentifier))").foregroundStyle(.secondary))")
                    .lineLimit(1)
                Text(Self.offsetText(place.offset(from: home, at: date)))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if place.dayDifference(from: home, at: date) != 0 {
                DayChip(text: date.formatted(style(.dateTime.weekday(.abbreviated).day())))
            }
            Text(date.formatted(style(.dateTime.hour().minute())))
                .font(.title3)
                .monospacedDigit()
        }
        .padding(.vertical, 2)
    }

    private func style(_ style: Date.FormatStyle) -> Date.FormatStyle {
        var style = style
        style.timeZone = place.timeZone
        return style
    }

    private static func offsetText(_ offset: TimeInterval) -> String {
        guard offset != 0 else { return "Same time" }
        let minutes = Int(offset / 60)
        let sign = minutes > 0 ? "+" : "-"
        let hours = abs(minutes) / 60
        let remainder = abs(minutes) % 60
        return remainder == 0 ? "\(sign)\(hours)h" : "\(sign)\(hours)h \(remainder)m"
    }
}

private struct DaylightIcon: View {
    let daylight: Daylight

    var body: some View {
        Image(systemName: symbol)
            .foregroundStyle(colour)
            .frame(width: 20)
    }

    private var symbol: String {
        switch daylight {
        case .day: "sun.max.fill"
        case .twilight: "sun.horizon.fill"
        case .night: "moon.fill"
        }
    }

    private var colour: Color {
        switch daylight {
        case .day: .yellow
        case .twilight: .orange
        case .night: .secondary
        }
    }
}

private struct DayChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .foregroundStyle(.orange)
            .background(.orange.opacity(0.18), in: RoundedRectangle(cornerRadius: 4))
    }
}
