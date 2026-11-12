import SwiftUI

struct DateButton: View {
    let moment: ChosenMoment
    let isOpen: Bool
    let onToggle: () -> Void

    var body: some View {
        TimelineView(.everyMinute) { context in
            Button(action: onToggle) {
                HStack(spacing: 4) {
                    Text(moment.date(at: context.date).formatted(Here.shared.style(.dateTime.weekday(.abbreviated).day().month(.abbreviated))))
                    Image(systemName: isOpen ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .headingPill()
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isOpen ? "Hide the month" : "Show the month")
        }
    }
}
