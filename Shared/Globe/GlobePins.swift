import SwiftUI
import WorldTimeKit

struct GlobePins: View {
    private static let visibleDepth = 0.2
    private static let dotSize: CGFloat = 6
    private static let labelGap: Double = 4
    private static let labelCharacterWidth: Double = 6.4
    private static let labelPadding: Double = 8
    private static let labelHeight: Double = 15
    private static let ringWidth: CGFloat = 1.5
    private static let placeColour = Color(red: 0.45, green: 1, blue: 0.4)

    let places: [Place]
    let here: Place?
    let orientation: GlobeOrientation
    let zoom: Double
    let date: Date

    var body: some View {
        GeometryReader { geometry in
            let pins = visiblePins(in: geometry.size)
            let labels = pins.map { label(for: $0.place) }
            let sides = LabelPlacement.sides(
                for: pins.map(\.point),
                labels: labels.map(\.size),
                dotRadius: Self.dotSize / 2,
                gap: Self.labelGap
            )

            ForEach(pins.indices, id: \.self) { index in
                let pin = pins[index]
                Circle()
                    .fill(pin.colour)
                    .frame(width: Self.dotSize, height: Self.dotSize)
                    .overlay(Circle().strokeBorder(.black.opacity(0.8), lineWidth: Self.ringWidth).padding(-Self.ringWidth))
                    .shadow(color: pin.colour.opacity(0.8), radius: 4)
                    .position(x: pin.point.x, y: pin.point.y)
                if let side = sides[index] {
                    let centre = LabelPlacement.centre(of: labels[index].size, beside: pin.point, on: side, dotRadius: Self.dotSize / 2, gap: Self.labelGap)
                    PinLabel(text: labels[index].text)
                        .position(x: centre.x, y: centre.y)
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func visiblePins(in size: CGSize) -> [(place: Place, point: LabelPlacement.Point, colour: Color)] {
        let radius = GlobeRenderer.radius(for: size, zoom: zoom)
        let centre = CGPoint(x: size.width / 2, y: size.height / 2)
        let marked = (here.map { [($0, Color.blue)] } ?? []) + places.map { ($0, Self.placeColour) }
        return marked.compactMap { place, colour in
            guard let coordinate = place.coordinate else { return nil }
            let point = orientation.viewPoint(of: coordinate)
            guard point.z > Self.visibleDepth else { return nil }
            return (place, LabelPlacement.Point(x: centre.x + point.x * radius, y: centre.y - point.y * radius), colour)
        }
    }

    private func label(for place: Place) -> (text: String, size: LabelPlacement.Size) {
        var style = Date.FormatStyle.dateTime.hour().minute()
        style.timeZone = place.timeZone
        let text = date.formatted(style)
        return (text, LabelPlacement.Size(width: Double(text.count) * Self.labelCharacterWidth + Self.labelPadding, height: Self.labelHeight))
    }
}

private struct PinLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption2)
            .monospacedDigit()
            .padding(.horizontal, 4)
            .background(.black.opacity(0.55), in: RoundedRectangle(cornerRadius: 4))
            .fixedSize()
    }
}
