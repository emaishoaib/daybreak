import SwiftUI
import WorldTimeKit

struct GlobeBlueprint: View {
    private static let lineColour = Color(red: 0.3, green: 0.55, blue: 1).opacity(0.7)
    private static let lineWidth: CGFloat = 0.75
    private static let drawIn = Animation.easeInOut(duration: 0.8)

    let orientation: GlobeOrientation
    let zoom: Double

    @State private var progress = 0.0

    var body: some View {
        Graticule(orientation: orientation, zoom: zoom)
            .trim(from: 0, to: progress)
            .stroke(Self.lineColour, lineWidth: Self.lineWidth)
            .onAppear {
                withAnimation(Self.drawIn) { progress = 1 }
            }
    }
}

private struct Graticule: Shape {
    private static let spacingDegrees = 30.0
    private static let sampleDegrees = 3.0

    let orientation: GlobeOrientation
    let zoom: Double

    func path(in rect: CGRect) -> Path {
        let radius = GlobeRenderer.radius(for: rect.size, zoom: zoom)
        let centre = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path(ellipseIn: CGRect(x: centre.x - radius, y: centre.y - radius, width: radius * 2, height: radius * 2))
        for latitude in stride(from: -90 + Self.spacingDegrees, to: 90, by: Self.spacingDegrees) {
            let parallel = stride(from: -180.0, through: 180, by: Self.sampleDegrees).map { Coordinate(latitude: latitude, longitude: $0) }
            add(parallel, to: &path, centre: centre, radius: radius)
        }
        for longitude in stride(from: -180.0, to: 180, by: Self.spacingDegrees) {
            let meridian = stride(from: -90.0, through: 90, by: Self.sampleDegrees).map { Coordinate(latitude: $0, longitude: longitude) }
            add(meridian, to: &path, centre: centre, radius: radius)
        }
        return path
    }

    private func add(_ line: [Coordinate], to path: inout Path, centre: CGPoint, radius: Double) {
        var isDrawing = false
        for coordinate in line {
            let point = orientation.viewPoint(of: coordinate)
            guard point.facesViewer else {
                isDrawing = false
                continue
            }
            let onScreen = CGPoint(x: centre.x + point.x * radius, y: centre.y - point.y * radius)
            if isDrawing { path.addLine(to: onScreen) } else { path.move(to: onScreen) }
            isDrawing = true
        }
    }
}
