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
                    ReturnPill(
                        text: date.formatted(here.style(.dateTime.weekday(.abbreviated).day().month(.abbreviated).hour().minute())),
                        isAway: !moment.isLive
                    ) {
                        moment.glideToNow()
                    }
                    HStack {
                        Spacer()
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

private struct ReturnPill: View {
    let text: String
    let isAway: Bool
    let onReturn: () -> Void

    var body: some View {
        Button(action: onReturn) {
            HStack(spacing: 5) {
                if isAway {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.caption.weight(.semibold))
                        .transition(.scale.combined(with: .opacity))
                }
                Text(text)
                    .monospacedDigit()
            }
            .padding(.horizontal, isAway ? 10 : 0)
            .padding(.vertical, 3)
            .background(.blue.opacity(isAway ? 0.25 : 0), in: Capsule())
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .allowsHitTesting(isAway)
        .accessibilityHint(isAway ? "Returns to now" : "")
        .animation(.snappy, value: isAway)
    }
}
