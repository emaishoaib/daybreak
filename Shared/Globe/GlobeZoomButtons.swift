import SwiftUI

struct GlobeZoomButtons: View {
    let onZoomIn: () -> Void
    let onZoomOut: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ZoomButton(symbol: "plus", label: "Zoom in", action: onZoomIn)
            Divider()
                .frame(width: 18)
            ZoomButton(symbol: "minus", label: "Zoom out", action: onZoomOut)
        }
        .background(.black.opacity(0.45), in: RoundedRectangle(cornerRadius: 8))
    }
}

private struct ZoomButton: View {
    let symbol: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.caption.weight(.semibold))
                .frame(width: 26, height: 24)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(.secondary)
        .accessibilityLabel(label)
    }
}
