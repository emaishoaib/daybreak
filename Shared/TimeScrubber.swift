import SwiftUI
import WorldTimeKit

struct TimeScrubber: View {
    let moment: ChosenMoment

    @State private var here = Here.shared

    var body: some View {
        TimelineView(.everyMinute) { context in
            let date = moment.date(at: context.date)
            VStack(spacing: 6) {
                ZStack {
                    Text(date.formatted(here.style(.dateTime.weekday(.abbreviated).day().month(.abbreviated).hour().minute())))
                        .monospacedDigit()
                    HStack {
                        Spacer()
                        Button("Now") {
                            moment.glideToNow()
                        }
                        .opacity(moment.isLive ? 0 : 1)
                        .allowsHitTesting(!moment.isLive)
                    }
                }
                DayTrack(
                    dayStart: here.calendar.startOfDay(for: date),
                    minutes: moment.minutesIntoDay(at: context.date),
                    coordinate: coordinate
                ) { minutes in
                    moment.choose(minutesIntoDay: minutes, at: context.date)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }

    private var coordinate: Coordinate {
        here.coordinate ?? Coordinate(latitude: 0, longitude: Double(here.timeZone.secondsFromGMT()) / 240)
    }
}
