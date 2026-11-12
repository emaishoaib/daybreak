import SwiftUI

struct TimeScrubber: View {
    private static let lastMinuteOfDay: Double = 24 * 60 - 1
    private static let stepMinutes: Double = 15

    let moment: ChosenMoment

    var body: some View {
        TimelineView(.everyMinute) { context in
            VStack(spacing: 6) {
                HStack {
                    Text("Your time")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text(moment.date(at: context.date).formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated).hour().minute()))
                        .monospacedDigit()
                    Spacer()
                    Button("Now") {
                        moment.returnToNow()
                    }
                    .opacity(moment.isLive ? 0 : 1)
                    .allowsHitTesting(!moment.isLive)
                }
                Slider(
                    value: Binding(
                        get: { moment.minutesIntoDay(at: context.date) },
                        set: { moment.choose(minutesIntoDay: $0, at: context.date) }
                    ),
                    in: 0...Self.lastMinuteOfDay,
                    step: Self.stepMinutes
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
        }
    }
}
