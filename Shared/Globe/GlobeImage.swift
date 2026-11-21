import SwiftUI
import WorldTimeKit

struct GlobeImage: View {
    let orientation: GlobeOrientation
    let zoom: Double
    let sun: Coordinate

    @Environment(\.displayScale) private var displayScale

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                if let image = GlobeRenderer.shared.image {
                    Image(decorative: image, scale: displayScale)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
            .onChange(of: request(for: geometry.size), initial: true) { _, request in
                GlobeRenderer.shared.draw(request)
            }
        }
    }

    private func request(for size: CGSize) -> GlobeRenderer.Request {
        GlobeRenderer.Request(
            width: Int(size.width * displayScale),
            height: Int(size.height * displayScale),
            orientation: orientation,
            zoom: zoom,
            sun: sun
        )
    }
}
