import Foundation

public struct DayGroup: Hashable, Sendable, Identifiable {
    public let dayDifference: Int
    public let places: [Place]

    public var id: Int {
        dayDifference
    }

    public static func groups(of places: [Place], from home: TimeZone, at date: Date) -> [DayGroup] {
        Dictionary(grouping: places) { $0.dayDifference(from: home, at: date) }
            .map { DayGroup(dayDifference: $0.key, places: $0.value) }
            .sorted { $0.dayDifference < $1.dayDifference }
    }
}
