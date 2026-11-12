public enum Daylight: Sendable {
    private static let sunriseElevationDegrees = -0.833
    private static let civilDuskElevationDegrees = -6.0

    case day
    case twilight
    case night

    public init(sunElevation: Double) {
        self = switch sunElevation {
        case Self.sunriseElevationDegrees...: .day
        case Self.civilDuskElevationDegrees...: .twilight
        default: .night
        }
    }
}
