import SwiftUI
import WorldTimeKit

struct MonthView: View {
    let grid: MonthGrid
    let selected: Date
    let today: Date
    let onPick: (Date) -> Void

    var body: some View {
        let calendar = Calendar.autoupdatingCurrent

        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 8) {
            ForEach(grid.weekdaySymbols.indices, id: \.self) { index in
                Text(grid.weekdaySymbols[index])
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            ForEach(grid.days) { day in
                Button {
                    onPick(day.date)
                } label: {
                    DayCell(
                        day: day,
                        isSelected: calendar.isDate(day.date, inSameDayAs: selected),
                        isToday: calendar.isDate(day.date, inSameDayAs: today)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct DayCell: View {
    let day: MonthGrid.Day
    let isSelected: Bool
    let isToday: Bool

    var body: some View {
        Text("\(day.number)")
            .monospacedDigit()
            .frame(width: 28, height: 28)
            .foregroundStyle(isToday ? AnyShapeStyle(.white) : day.isInMonth ? AnyShapeStyle(.primary) : AnyShapeStyle(.tertiary))
            .background {
                if isToday {
                    Circle().fill(.tint)
                } else if isSelected {
                    Circle().strokeBorder(.tint, lineWidth: 1.5)
                }
            }
            .contentShape(Circle())
    }
}
