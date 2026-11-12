import Foundation

public struct GlobeOrientation: Hashable, Sendable {
    public static let defaultTiltDegrees = 18.0

    public private(set) var centreLongitude: Double
    public let tilt: Double

    public init(centreLongitude: Double, tilt: Double = defaultTiltDegrees) {
        self.centreLongitude = Self.wrapped(centreLongitude)
        self.tilt = tilt
    }

    public func turned(byDegrees degrees: Double) -> GlobeOrientation {
        GlobeOrientation(centreLongitude: centreLongitude + degrees, tilt: tilt)
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
