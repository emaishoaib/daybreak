public enum GlobeZoom {
    public static let range = 1.0...3.5
    public static let stepFactor = 1.5

    public static func clamped(_ zoom: Double) -> Double {
        min(max(zoom, range.lowerBound), range.upperBound)
    }

    public static func zoomedIn(from zoom: Double) -> Double {
        clamped(zoom * stepFactor)
    }

    public static func zoomedOut(from zoom: Double) -> Double {
        clamped(zoom / stepFactor)
    }
}
