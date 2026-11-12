import SwiftUI

struct DateButton: View {
    let moment: ChosenMoment
    let isOpen: Bool
    let onToggle: () -> Void

    var body: some View {
        TimelineView(.everyMinute) { context in
            Button(action: onToggle) {
                HStack(spacing: 4) {
                    Text(moment.date(at: context.date).formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated)))
                        .font(.headline)
                    Image(systemName: isOpen ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(.white.opacity(isOpen ? 0.12 : 0.06), in: RoundedRectangle(cornerRadius: 6))
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(isOpen ? "Hide the month" : "Show the month")
        }
    }
}
