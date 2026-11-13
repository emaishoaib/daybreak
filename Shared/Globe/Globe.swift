import SwiftUI
import WorldTimeKit

struct Globe: View {
    let places: [Place]
    let moment: ChosenMoment
    let flight: GlobeFlight?

    @State private var camera = GlobeCamera(orientation: GlobeOrientation(centreLongitude: MainActor.assumeIsolated { Self.homeLongitude }))
    @State private var motion: GlobeMotion?
    @State private var dragStart: GlobeCamera?
    @State private var pinchStart: GlobeCamera?

    var body: some View {
        TimelineView(.everyMinute) { context in
            let date = moment.date(at: context.date)
            TimelineView(.animation(paused: motion == nil)) { frame in
                let shown = motion?.camera(at: frame.date) ?? camera
                GeometryReader { geometry in
                    ZStack {
                        GlobeImage(orientation: shown.orientation, zoom: shown.zoom, sun: Sun.overhead(at: date))
                        GlobePins(places: places, here: hereOnGlobe, orientation: shown.orientation, zoom: shown.zoom, date: date)
                    }
                    .contentShape(Rectangle())
                    .gesture(drag(radius: GlobeRenderer.radius(for: geometry.size, zoom: shown.zoom)))
                    .simultaneousGesture(pinch)
                }
            }
            .clipped()
            .overlay(alignment: .bottomTrailing) {
                GlobeZoomButtons {
                    move(to: camera.zoomed(to: GlobeZoom.zoomedIn(from: camera.zoom)), seconds: GlobeMotion.zoomSeconds)
                } onZoomOut: {
                    move(to: camera.zoomed(to: GlobeZoom.zoomedOut(from: camera.zoom)), seconds: GlobeMotion.zoomSeconds)
                }
                .padding(8)
            }
        }
        .onChange(of: flight) {
            guard let coordinate = flight?.place.coordinate else { return }
            move(to: camera.focused(on: coordinate), seconds: GlobeMotion.flightSeconds)
        }
    }

    private var hereOnGlobe: Place? {
        Here.shared.coordinate == nil ? nil : Here.shared.place
    }

    private static var homeLongitude: Double {
        Here.shared.coordinate?.longitude ?? Double(Here.shared.timeZone.secondsFromGMT()) / 240
    }

    private func move(to target: GlobeCamera, seconds: TimeInterval) {
        let now = Date.now
        let next = GlobeMotion(from: motion?.camera(at: now) ?? camera, to: target, start: now, durationSeconds: seconds)
        camera = target
        motion = next
        Task {
            try? await Task.sleep(for: .seconds(seconds))
            if motion == next {
                motion = nil
            }
        }
    }

    private func stopMoving() {
        guard let motion else { return }
        camera = motion.camera(at: .now)
        self.motion = nil
    }

    private func drag(radius: Double) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if dragStart == nil { stopMoving() }
                let start = dragStart ?? camera
                dragStart = start
                camera.orientation = start.orientation
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
                if pinchStart == nil { stopMoving() }
                let start = pinchStart ?? camera
                pinchStart = start
                camera = start.zoomed(to: start.zoom * value.magnification)
            }
            .onEnded { _ in
                pinchStart = nil
            }
    }
}
