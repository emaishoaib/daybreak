import Foundation

public struct GlobeCamera: Hashable, Sendable {
    public static let focusZoom = 2.0

    public var orientation: GlobeOrientation
    public var zoom: Double

    public init(orientation: GlobeOrientation, zoom: Double = GlobeZoom.range.lowerBound) {
        self.orientation = orientation
        self.zoom = GlobeZoom.clamped(zoom)
    }

    public func focused(on coordinate: Coordinate) -> GlobeCamera {
        GlobeCamera(
            orientation: GlobeOrientation(centreLongitude: coordinate.longitude, tilt: coordinate.latitude),
            zoom: max(zoom, Self.focusZoom)
        )
    }

    public func zoomed(to zoom: Double) -> GlobeCamera {
        GlobeCamera(orientation: orientation, zoom: zoom)
    }
}

public struct GlobeMotion: Equatable, Sendable {
    public static let zoomSeconds: TimeInterval = 0.35
    public static let flightSeconds: TimeInterval = 0.9

    public let from: GlobeCamera
    public let to: GlobeCamera
    public let start: Date
    public let durationSeconds: TimeInterval

    public init(from: GlobeCamera, to: GlobeCamera, start: Date, durationSeconds: TimeInterval) {
        self.from = from
        self.to = to
        self.start = start
        self.durationSeconds = durationSeconds
    }

    public func camera(at date: Date) -> GlobeCamera {
        let progress = min(max(date.timeIntervalSince(start) / durationSeconds, 0), 1)
        let eased = progress * progress * (3 - 2 * progress)
        return GlobeCamera(
            orientation: from.orientation.interpolated(to: to.orientation, progress: eased),
            zoom: from.zoom * pow(to.zoom / from.zoom, eased)
        )
    }

    public func isFinished(at date: Date) -> Bool {
        date.timeIntervalSince(start) >= durationSeconds
    }
}
