import Foundation

public struct GlobeOrientation: Hashable, Sendable {
    public static let defaultTiltDegrees = 18.0
    public static let tiltLimitDegrees = 80.0

    public private(set) var centreLongitude: Double
    public private(set) var tilt: Double

    public init(centreLongitude: Double, tilt: Double = defaultTiltDegrees) {
        self.centreLongitude = Self.wrapped(centreLongitude)
        self.tilt = min(max(tilt, -Self.tiltLimitDegrees), Self.tiltLimitDegrees)
    }

    public func turned(byDegrees degrees: Double) -> GlobeOrientation {
        GlobeOrientation(centreLongitude: centreLongitude + degrees, tilt: tilt)
    }

    public func tilted(byDegrees degrees: Double) -> GlobeOrientation {
        GlobeOrientation(centreLongitude: centreLongitude, tilt: tilt + degrees)
    }

    public func interpolated(to target: GlobeOrientation, progress: Double) -> GlobeOrientation {
        let turn = Self.wrapped(target.centreLongitude - centreLongitude)
        return GlobeOrientation(
            centreLongitude: centreLongitude + turn * progress,
            tilt: tilt + (target.tilt - tilt) * progress
        )
    }

    public func viewPoint(of coordinate: Coordinate) -> ViewPoint {
        let latitude = radians(coordinate.latitude)
        let longitude = radians(coordinate.longitude - centreLongitude)
        let tilt = radians(tilt)
        let x = cos(latitude) * sin(longitude)
        let y = sin(latitude)
        let z = cos(latitude) * cos(longitude)
        return ViewPoint(x: x, y: y * cos(tilt) - z * sin(tilt), z: y * sin(tilt) + z * cos(tilt))
    }

    private static func wrapped(_ longitude: Double) -> Double {
        let wrapped = (longitude + 180).truncatingRemainder(dividingBy: 360)
        return (wrapped < 0 ? wrapped + 360 : wrapped) - 180
    }

    private func radians(_ degrees: Double) -> Double {
        degrees * .pi / 180
    }
}

public struct ViewPoint: Hashable, Sendable {
    public let x: Double
    public let y: Double
    public let z: Double

    public var facesViewer: Bool {
        z > 0
    }
}
