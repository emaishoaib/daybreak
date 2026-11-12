import SwiftUI
import WorldTimeKit

struct Globe: View {
    let places: [Place]
    let moment: ChosenMoment

    @State private var orientation = GlobeOrientation(centreLongitude: Self.homeLongitude)
    @State private var zoom = GlobeZoom.range.lowerBound
    @State private var dragStart: GlobeOrientation?
    @State private var pinchStart: Double?
    @State private var zoomTransition: GlobeZoom.Transition?

    var body: some View {
        TimelineView(.everyMinute) { context in
            let date = moment.date(at: context.date)
            TimelineView(.animation(paused: zoomTransition == nil)) { frame in
                let shownZoom = zoomTransition?.zoom(at: frame.date) ?? zoom
                GeometryReader { geometry in
                    ZStack {
                        GlobeImage(orientation: orientation, zoom: shownZoom, sun: Sun.overhead(at: date))
                        GlobePins(places: places, orientation: orientation, zoom: shownZoom, date: date)
                    }
                    .contentShape(Rectangle())
                    .gesture(drag(radius: GlobeRenderer.radius(for: geometry.size, zoom: shownZoom)))
                    .simultaneousGesture(pinch)
                }
            }
            .clipped()
            .overlay(alignment: .bottomTrailing) {
                GlobeZoomButtons {
                    animateZoom(to: GlobeZoom.zoomedIn(from: zoom))
                } onZoomOut: {
                    animateZoom(to: GlobeZoom.zoomedOut(from: zoom))
                }
                .padding(8)
            }
        }
    }

    private func animateZoom(to target: Double) {
        let now = Date.now
        let transition = GlobeZoom.Transition(from: zoomTransition?.zoom(at: now) ?? zoom, to: target, start: now)
        zoom = target
        zoomTransition = transition
        Task {
            try? await Task.sleep(for: .seconds(GlobeZoom.Transition.durationSeconds))
            if zoomTransition == transition {
                zoomTransition = nil
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
                zoomTransition = nil
                zoom = GlobeZoom.clamped(start * value.magnification)
            }
            .onEnded { _ in
                pinchStart = nil
            }
    }
}
