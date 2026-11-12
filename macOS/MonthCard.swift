import SwiftUI
import WorldTimeKit

struct MonthCard: View {
    let moment: ChosenMoment

    @State private var shownMonth: Date?

    var body: some View {
        TimelineView(.everyMinute) { context in
            let date = moment.date(at: context.date)
            let calendar = Here.shared.calendar
            let grid = MonthGrid(containing: shownMonth ?? date, calendar: calendar)

            VStack(spacing: 8) {
                HStack {
                    MonthArrow(symbol: "chevron.left", label: "Previous month") {
                        shownMonth = calendar.date(byAdding: .month, value: -1, to: grid.start)
                    }
                    Spacer()
                    Text(grid.start.formatted(Here.shared.style(.dateTime.month(.wide).year())))
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                    MonthArrow(symbol: "chevron.right", label: "Next month") {
                        shownMonth = calendar.date(byAdding: .month, value: 1, to: grid.start)
                    }
                }
                MonthView(grid: grid, selected: date, today: context.date) { day in
                    moment.choose(day: day, at: context.date)
                    shownMonth = nil
                }
            }
            .padding(10)
            .background(.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 10))
        }
        .onChange(of: moment.state) {
            shownMonth = nil
        }
    }
}

private struct MonthArrow: View {
    let symbol: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .frame(width: 24, height: 20)
                .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
        .accessibilityLabel(label)
    }
}
