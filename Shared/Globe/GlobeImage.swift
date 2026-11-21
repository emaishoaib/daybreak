import SwiftUI
import WorldTimeKit

struct GlobeImage: View {
    private static let graceSeconds = 0.15
    private static let reveal = Animation.easeInOut(duration: 0.4)

    let orientation: GlobeOrientation
    let zoom: Double
    let sun: Coordinate

    @Environment(\.displayScale) private var displayScale
    @State private var isLate = false

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .topLeading) {
                switch GlobeRenderer.shared.picture {
                case .ready(let image):
                    Image(decorative: image, scale: displayScale)
                        .resizable()
                        .transition(.opacity)
                case .waiting:
                    if isLate {
                        GlobeBlueprint(orientation: orientation, zoom: zoom)
                            .transition(.opacity)
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
            .animation(isLate && hasImage ? Self.reveal : nil, value: hasImage)
            .onChange(of: request(for: geometry.size), initial: true) { _, request in
                GlobeRenderer.shared.draw(request)
            }
            .task(id: waitingSince) {
                await waitForImage()
            }
        }
    }

    private var waitingSince: Date? {
        guard case .waiting(let since) = GlobeRenderer.shared.picture else { return nil }
        return since
    }

    private var hasImage: Bool {
        waitingSince == nil
    }

    private func waitForImage() async {
        guard !hasImage else { return }
        isLate = false
        try? await Task.sleep(for: .seconds(Self.graceSeconds))
        guard !Task.isCancelled else { return }
        isLate = true
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
