import SwiftUI
import WorldTimeKit

struct Globe: View {
    let places: [Place]
    let moment: ChosenMoment

    @State private var orientation = GlobeOrientation(centreLongitude: Self.homeLongitude)
    @State private var zoom = GlobeZoom.range.lowerBound
    @State private var dragStart: GlobeOrientation?
    @State private var pinchStart: Double?

    var body: some View {
        TimelineView(.everyMinute) { context in
            let date = moment.date(at: context.date)
            GeometryReader { geometry in
                ZStack {
                    GlobeImage(orientation: orientation, zoom: zoom, sun: Sun.overhead(at: date))
                    GlobePins(places: places, orientation: orientation, zoom: zoom, date: date)
                }
                .contentShape(Rectangle())
                .gesture(drag(radius: GlobeRenderer.radius(for: geometry.size, zoom: zoom)))
                .simultaneousGesture(pinch)
            }
            .clipped()
            .overlay(alignment: .bottomTrailing) {
                ZoomButtons(zoom: $zoom)
                    .padding(8)
            }
        }
    }

    private static var homeLongitude: Double {
        Double(TimeZone.autoupdatingCurrent.secondsFromGMT()) / 240
    }

    private func drag(radius: Double) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let start = dragStart ?? orientation
                dragStart = start
                orientation = start
                    .turned(byDegrees: -value.translation.width / radius * 180 / .pi)
                    .tilted(byDegrees: value.translation.height / radius * 180 / .pi)
            }
            .onEnded { _ in
                dragStart = nil
            }
    }

    private var pinch: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                let start = pinchStart ?? zoom
                pinchStart = start
                zoom = GlobeZoom.clamped(start * value.magnification)
            }
            .onEnded { _ in
                pinchStart = nil
            }
    }
}

private struct ZoomButtons: View {
    @Binding var zoom: Double

    var body: some View {
        VStack(spacing: 0) {
            ZoomButton(symbol: "plus", label: "Zoom in") {
                zoom = GlobeZoom.zoomedIn(from: zoom)
            }
            Divider()
                .frame(width: 18)
            ZoomButton(symbol: "minus", label: "Zoom out") {
                zoom = GlobeZoom.zoomedOut(from: zoom)
            }
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
