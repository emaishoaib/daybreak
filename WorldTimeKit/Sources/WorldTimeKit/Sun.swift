import Foundation

public enum Sun {
    private static let unixEpochJulianDay = 2_440_587.5
    private static let j2000JulianDay = 2_451_545.0
    private static let secondsPerDay: Double = 24 * 60 * 60

    public static func overhead(at date: Date) -> Coordinate {
        let days = date.timeIntervalSince1970 / secondsPerDay + unixEpochJulianDay - j2000JulianDay
        let meanLongitude = 280.460 + 0.985_647_4 * days
        let meanAnomaly = radians(357.528 + 0.985_600_3 * days)
        let eclipticLongitude = radians(meanLongitude + 1.915 * sin(meanAnomaly) + 0.020 * sin(2 * meanAnomaly))
        let obliquity = radians(23.439 - 0.000_000_4 * days)

        let declination = asin(sin(obliquity) * sin(eclipticLongitude))
        let rightAscension = atan2(cos(obliquity) * sin(eclipticLongitude), cos(eclipticLongitude))
        let siderealTime = 280.460_618_37 + 360.985_647_366_29 * days

        return Coordinate(
            latitude: degrees(declination),
            longitude: normalised(degrees(rightAscension) - siderealTime)
        )
    }

    public static func elevation(at coordinate: Coordinate, on date: Date) -> Double {
        let sun = overhead(at: date)
        let latitude = radians(coordinate.latitude)
        let declination = radians(sun.latitude)
        let hourAngle = radians(coordinate.longitude - sun.longitude)
        let sine = sin(latitude) * sin(declination) + cos(latitude) * cos(declination) * cos(hourAngle)
        return degrees(asin(min(max(sine, -1), 1)))
    }

    private static func normalised(_ longitude: Double) -> Double {
        let wrapped = (longitude + 180).truncatingRemainder(dividingBy: 360)
        return (wrapped < 0 ? wrapped + 360 : wrapped) - 180
    }

    private static func radians(_ degrees: Double) -> Double {
        degrees * .pi / 180
    }

    private static func degrees(_ radians: Double) -> Double {
        radians * 180 / .pi
    }
}
