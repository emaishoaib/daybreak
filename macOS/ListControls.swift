import SwiftUI

struct ListControls: View {
    let hiddenCount: Int
    let isExpanded: Bool
    let onToggle: () -> Void
    let onAdd: () -> Void

    var body: some View {
        ZStack {
            if hiddenCount > 0 {
                Button(action: onToggle) {
                    HStack(spacing: 4) {
                        Text(isExpanded ? "Show fewer" : "\(hiddenCount) more")
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption2.weight(.semibold))
                    }
                    .font(.caption)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .floatingOverGlobe(in: Capsule())
                }
                .buttonStyle(.plain)
            }
            HStack {
                Spacer()
                Button(action: onAdd) {
                    Image(systemName: "plus")
                        .font(.caption.weight(.semibold))
                        .frame(width: 24, height: 24)
                        .floatingOverGlobe(in: Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add a place")
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 6)
    }
}

private extension View {
    func floatingOverGlobe(in shape: some InsettableShape) -> some View {
        foregroundStyle(.secondary)
            .background(.black.opacity(0.55), in: shape)
            .overlay(shape.strokeBorder(.white.opacity(0.12), lineWidth: 0.5))
            .contentShape(shape)
    }
}
