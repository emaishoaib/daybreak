import SwiftUI
import WorldTimeKit

struct ZoneRow: View {
    let place: Place
    let date: Date
    var isInMenuBar = false
    var onToggleMenuBar: (() -> Void)?

    var body: some View {
        let home = Here.shared.timeZone

        HStack(spacing: RowLayout.columnSpacing) {
            #if os(macOS)
            MenuBarPin(isPinned: isInMenuBar) {
                onToggleMenuBar?()
            }
            #endif
            VStack(alignment: .leading, spacing: 1) {
                Text("\(place.name) \(Text("(\(place.timeZone.abbreviation(for: date) ?? place.timeZoneIdentifier))").foregroundStyle(.secondary))")
                    .lineLimit(1)
                HStack(spacing: RowLayout.subtitleSpacing) {
                    DaylightIcon(daylight: place.daylight(at: date))
                    Text(Self.offsetText(place.offset(from: home, at: date)))
                        .foregroundStyle(.secondary)
                }
                .font(.caption)
            }
            Spacer()
            if place.dayDifference(from: home, at: date) != 0 {
                DayChip(text: date.formatted(style(.dateTime.weekday(.abbreviated).day())))
            }
            RowTime(text: date.formatted(style(.dateTime.hour().minute())))
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
            .frame(width: RowLayout.subtitleIconWidth)
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

private struct RowTime: View {
    private static let widestSamples = [10, 22].map { hour in
        widestSample(Date(timeIntervalSince1970: Double(hour * 3600 + 58 * 60)), .dateTime.hour().minute())
    }

    let text: String

    var body: some View {
        ZStack(alignment: .trailing) {
            ForEach(Self.widestSamples, id: \.self) { Text($0).hidden() }
            Text(text)
        }
        .font(.title3)
        .monospacedDigit()
    }
}

private struct DayChip: View {
    private static let widestSamples = (21...27).map { day in
        widestSample(Date(timeIntervalSince1970: Double(day * 86_400)), .dateTime.weekday(.abbreviated).day())
    }

    let text: String

    var body: some View {
        ZStack {
            ForEach(Self.widestSamples, id: \.self) { Text($0).hidden() }
            Text(text)
        }
        .font(.caption)
        .monospacedDigit()
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .foregroundStyle(.orange)
        .background(.orange.opacity(0.18), in: RoundedRectangle(cornerRadius: 4))
    }
}

private func widestSample(_ date: Date, _ style: Date.FormatStyle) -> String {
    var style = style
    style.timeZone = .gmt
    return date.formatted(style)
}
