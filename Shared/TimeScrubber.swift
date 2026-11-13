import SwiftUI
import WorldTimeKit

struct TimeScrubber<Trailing: View>: View {
    let moment: ChosenMoment
    let trailing: Trailing

    @State private var here = Here.shared

    init(moment: ChosenMoment, @ViewBuilder trailing: () -> Trailing) {
        self.moment = moment
        self.trailing = trailing()
    }

    var body: some View {
        TimelineView(.everyMinute) { context in
            let date = moment.date(at: context.date)
            VStack(spacing: 6) {
                ZStack {
                    Text(date.formatted(here.style(.dateTime.weekday(.abbreviated).day().month(.abbreviated).hour().minute())))
                        .monospacedDigit()
                    HStack(spacing: 8) {
                        Spacer()
                        Button("Now") {
                            moment.glideToNow()
                        }
                        .opacity(moment.isLive ? 0 : 1)
                        .allowsHitTesting(!moment.isLive)
                        trailing
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
