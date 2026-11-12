import SwiftUI
import WorldTimeKit

struct CalendarPanel: View {
    let zones: ZoneList
    let moment: ChosenMoment

    @State private var shownMonth: Date?

    var body: some View {
        TimelineView(.everyMinute) { context in
            let date = moment.date(at: context.date)
            let calendar = Calendar.autoupdatingCurrent
            let grid = MonthGrid(containing: shownMonth ?? date, calendar: calendar)

            VStack(spacing: 14) {
                MonthHeader(start: grid.start) { months in
                    shownMonth = calendar.date(byAdding: .month, value: months, to: grid.start)
                } onToday: {
                    moment.returnToNow()
                    shownMonth = nil
                }
                MonthView(grid: grid, selected: date, today: context.date) { day in
                    moment.choose(day: day, at: context.date)
                    shownMonth = nil
                }
                Divider()
                DayGroupsView(places: zones.places, date: date)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .onChange(of: moment.state) {
            shownMonth = nil
        }
    }
}

private struct MonthHeader: View {
    let start: Date
    let onShift: (Int) -> Void
    let onToday: () -> Void

    var body: some View {
        HStack {
            Text(start.formatted(.dateTime.month(.wide).year()))
                .font(.headline)
            Spacer()
            ControlGroup {
                Button {
                    onShift(-1)
                } label: {
                    Image(systemName: "chevron.left")
                }
                .accessibilityLabel("Previous month")
                Button("Today", action: onToday)
                Button {
                    onShift(1)
                } label: {
                    Image(systemName: "chevron.right")
                }
                .accessibilityLabel("Next month")
            }
            .fixedSize()
        }
    }
}
