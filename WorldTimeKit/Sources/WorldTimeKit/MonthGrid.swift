import Foundation

public struct MonthGrid: Sendable {
    public struct Day: Hashable, Sendable, Identifiable {
        public let date: Date
        public let number: Int
        public let isInMonth: Bool

        public var id: Date {
            date
        }
    }

    public let start: Date
    public let weekdaySymbols: [String]
    public let days: [Day]

    public init(containing date: Date, calendar: Calendar) {
        let start = calendar.dateInterval(of: .month, for: date)?.start ?? date
        self.start = start

        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let shift = calendar.firstWeekday - 1
        weekdaySymbols = Array(symbols[shift...] + symbols[..<shift])

        let leading = (calendar.component(.weekday, from: start) - calendar.firstWeekday + 7) % 7
        let length = calendar.range(of: .day, in: .month, for: start)?.count ?? 30
        let weeks = (leading + length + 6) / 7
        days = (0..<weeks * 7).map { index in
            let date = calendar.date(byAdding: .day, value: index - leading, to: start) ?? start
            return Day(
                date: date,
                number: calendar.component(.day, from: date),
                isInMonth: calendar.isDate(date, equalTo: start, toGranularity: .month)
            )
        }
    }
}
