import SwiftUI
import WorldTimeKit

struct GlobeImage: View {
    let orientation: GlobeOrientation
    let sun: Coordinate

    @Environment(\.displayScale) private var displayScale

    var body: some View {
        GeometryReader { geometry in
            if let image = GlobeRenderer.shared.image(
                width: Int(geometry.size.width * displayScale),
                height: Int(geometry.size.height * displayScale),
                orientation: orientation,
                sun: sun
            ) {
                Image(decorative: image, scale: displayScale)
            }
        }
    }
}
