import SwiftUI

struct ShowMoreButton: View {
    let hiddenCount: Int
    let isExpanded: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 4) {
                Text(isExpanded ? "Show fewer" : "\(hiddenCount) more")
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption2.weight(.semibold))
            }
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 3)
            .controlChip(in: Capsule())
        }
        .buttonStyle(.plain)
    }
}

struct AddPlaceButton: View {
    let onAdd: () -> Void

    var body: some View {
        Button(action: onAdd) {
            Image(systemName: "plus")
                .font(.caption.weight(.semibold))
                .frame(width: 24, height: 24)
                .controlChip(in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Add a place")
    }
}

private extension View {
    func controlChip(in shape: some InsettableShape) -> some View {
        foregroundStyle(.secondary)
            .background(.white.opacity(0.08), in: shape)
            .overlay(shape.strokeBorder(.white.opacity(0.12), lineWidth: 0.5))
            .contentShape(shape)
    }
}
