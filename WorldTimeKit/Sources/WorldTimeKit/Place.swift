import Foundation

public struct Place: Codable, Hashable, Sendable, Identifiable {
    private static let secondsPerDay: TimeInterval = 24 * 60 * 60

    public let name: String
    public let timeZoneIdentifier: String
    public let coordinate: Coordinate

    public init(name: String, timeZoneIdentifier: String, coordinate: Coordinate) {
        self.name = name
        self.timeZoneIdentifier = timeZoneIdentifier
        self.coordinate = coordinate
    }

    public var id: String {
        "\(timeZoneIdentifier)/\(name)"
    }

    public var shortCode: String {
        let name = name.split(separator: ",").first.map(String.init) ?? name
        let words = name.split(separator: " ").filter { $0.first?.isUppercase == true }
        guard words.count > 1 else {
            return String(name.filter(\.isLetter).prefix(3)).uppercased()
        }
        return String(words.prefix(3).compactMap(\.first)).uppercased()
    }

    public var timeZone: TimeZone {
        TimeZone(identifier: timeZoneIdentifier) ?? .gmt
    }

    public func offset(from home: TimeZone, at date: Date) -> TimeInterval {
        TimeInterval(timeZone.secondsFromGMT(for: date) - home.secondsFromGMT(for: date))
    }

    public func dayDifference(from home: TimeZone, at date: Date) -> Int {
        Self.dayNumber(of: date, in: timeZone) - Self.dayNumber(of: date, in: home)
    }

    public func daylight(at date: Date) -> Daylight {
        Daylight(sunElevation: Sun.elevation(at: coordinate, on: date))
    }

    private static func dayNumber(of date: Date, in timeZone: TimeZone) -> Int {
        let localSeconds = date.timeIntervalSince1970 + TimeInterval(timeZone.secondsFromGMT(for: date))
        return Int((localSeconds / secondsPerDay).rounded(.down))
    }
}
