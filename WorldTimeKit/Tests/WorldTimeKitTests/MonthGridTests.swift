import Foundation
import Testing
@testable import WorldTimeKit

struct MonthGridTests {
    let november = ISO8601DateFormatter().date(from: "2026-11-12T12:00:00Z")!

    func calendar(firstWeekday: Int) -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        calendar.locale = Locale(identifier: "en_GB")
        calendar.firstWeekday = firstWeekday
        return calendar
    }

    @Test func monthStartsOnItsFirstDay() {
        let grid = MonthGrid(containing: november, calendar: calendar(firstWeekday: 2))
        #expect(grid.start == ISO8601DateFormatter().date(from: "2026-11-01T00:00:00Z"))
    }

    @Test func weeksStartingOnMondayFillTheGapWithLastMonth() {
        let grid = MonthGrid(containing: november, calendar: calendar(firstWeekday: 2))
        #expect(grid.days.count == 42)
        #expect(grid.days.first?.number == 26)
        #expect(grid.days.first?.isInMonth == false)
        #expect(grid.days[6].number == 1)
    }

    @Test func weeksStartingOnSundayNeedNoGapWhenTheMonthStartsOnSunday() {
        let grid = MonthGrid(containing: november, calendar: calendar(firstWeekday: 1))
        #expect(grid.days.count == 35)
        #expect(grid.days.first?.number == 1)
        #expect(grid.days.first?.isInMonth == true)
    }

    @Test func everyDayOfTheMonthAppearsOnce() {
        let grid = MonthGrid(containing: november, calendar: calendar(firstWeekday: 2))
        #expect(grid.days.filter(\.isInMonth).map(\.number) == Array(1...30))
    }

    @Test func weekdaySymbolsFollowTheFirstWeekday() {
        #expect(MonthGrid(containing: november, calendar: calendar(firstWeekday: 2)).weekdaySymbols.first == "M")
        #expect(MonthGrid(containing: november, calendar: calendar(firstWeekday: 1)).weekdaySymbols.first == "S")
    }
}
