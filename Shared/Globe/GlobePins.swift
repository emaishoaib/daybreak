import SwiftUI
import WorldTimeKit

struct GlobePins: View {
    private static let visibleDepth = 0.2

    let places: [Place]
    let orientation: GlobeOrientation
    let zoom: Double
    let date: Date

    var body: some View {
        GeometryReader { geometry in
            let radius = GlobeRenderer.radius(for: geometry.size, zoom: zoom)
            let centre = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)

            ForEach(places) { place in
                let point = orientation.viewPoint(of: place.coordinate)
                if point.z > Self.visibleDepth {
                    GlobePin(place: place, date: date)
                        .position(x: centre.x + point.x * radius, y: centre.y - point.y * radius)
                }
            }
        }
        .allowsHitTesting(false)
    }
}

private struct GlobePin: View {
    let place: Place
    let date: Date

    var body: some View {
        Circle()
            .fill(.yellow)
            .frame(width: 6, height: 6)
            .shadow(color: .yellow, radius: 3)
            .overlay(alignment: .leading) {
                Text(date.formatted(style))
                    .font(.caption2)
                    .monospacedDigit()
                    .padding(.horizontal, 4)
                    .background(.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 4))
                    .fixedSize()
                    .offset(x: 10)
            }
    }

    private var style: Date.FormatStyle {
        var style = Date.FormatStyle.dateTime.hour().minute()
        style.timeZone = place.timeZone
        return style
    }
}
