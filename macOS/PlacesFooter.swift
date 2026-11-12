import SwiftUI

struct PlacesFooter: View {
    let hiddenCount: Int
    let isExpanded: Bool
    let onAdd: () -> Void
    let onToggle: () -> Void

    var body: some View {
        HStack {
            Button(action: onAdd) {
                Label("Add a place", systemImage: "plus")
            }
            Spacer()
            if hiddenCount > 0 {
                Button(action: onToggle) {
                    HStack(spacing: 4) {
                        Text(isExpanded ? "Show fewer" : "Show \(hiddenCount) more")
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption2.weight(.semibold))
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }
}
