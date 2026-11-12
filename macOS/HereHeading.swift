import SwiftUI

struct HereHeading: View {
    let moment: ChosenMoment
    let canExpand: Bool
    let isExpanded: Bool
    let onToggle: () -> Void
    let onAdd: () -> Void

    @State private var country = HomeCountry.shared

    var body: some View {
        TimelineView(.everyMinute) { context in
            HStack {
                if canExpand {
                    Button(action: onToggle) {
                        label(at: moment.date(at: context.date))
                            .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(isExpanded ? "Show fewer places" : "Show all places")
                } else {
                    label(at: moment.date(at: context.date))
                }
                Spacer()
                Button(action: onAdd) {
                    Image(systemName: "plus")
                }
                .buttonStyle(.borderless)
                .accessibilityLabel("Add a place")
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 6)
        .task { await country.load() }
    }

    private func label(at date: Date) -> some View {
        HStack(spacing: 8) {
            Text(date.formatted(.dateTime.hour().minute()))
                .monospacedDigit()
            Text(place(at: date))
            if canExpand {
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .headingPill()
    }

    private func place(at date: Date) -> String {
        let zone = TimeZone.autoupdatingCurrent.abbreviation(for: date) ?? TimeZone.autoupdatingCurrent.identifier
        guard let name = country.name else { return zone }
        return "\(name) (\(zone))"
    }
}
