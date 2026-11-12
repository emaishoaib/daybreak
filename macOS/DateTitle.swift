import SwiftUI

struct DateTitle: View {
    let moment: ChosenMoment

    var body: some View {
        TimelineView(.everyMinute) { context in
            Text(moment.date(at: context.date).formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated)))
                .font(.headline)
        }
    }
}
