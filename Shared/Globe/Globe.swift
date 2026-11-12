import SwiftUI
import WorldTimeKit

struct Globe: View {
    let places: [Place]
    let moment: ChosenMoment
    let showsTimes: Bool

    @State private var orientation = GlobeOrientation(centreLongitude: Self.homeLongitude)
    @State private var dragStart: GlobeOrientation?

    var body: some View {
        TimelineView(.everyMinute) { context in
            let date = moment.date(at: context.date)
            GeometryReader { geometry in
                ZStack {
                    GlobeImage(orientation: orientation, sun: Sun.overhead(at: date))
                    GlobePins(places: places, orientation: orientation, date: date, showsTimes: showsTimes)
                }
                .contentShape(Rectangle())
                .gesture(drag(radius: min(geometry.size.width, geometry.size.height) / 2 * GlobeRenderer.radiusFraction))
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
                orientation = start.turned(byDegrees: -value.translation.width / radius * 180 / .pi)
            }
            .onEnded { _ in
                dragStart = nil
            }
    }
}
