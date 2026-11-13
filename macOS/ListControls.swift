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
    static let size: CGFloat = 24

    let isOpen: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            Image(systemName: "plus")
                .font(.caption.weight(.semibold))
                .rotationEffect(.degrees(isOpen ? 45 : 0))
                .frame(width: Self.size, height: Self.size)
                .controlChip(in: Circle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(isOpen ? "Close search" : "Add a place")
    }
}

struct AddPlaceButtonSpace: View {
    var body: some View {
        Color.clear
            .frame(width: AddPlaceButton.size, height: AddPlaceButton.size)
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
