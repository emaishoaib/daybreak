import Foundation

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

    public struct Transition: Equatable, Sendable {
        public static let durationSeconds: TimeInterval = 0.35

        public let from: Double
        public let to: Double
        public let start: Date

        public init(from: Double, to: Double, start: Date) {
            self.from = from
            self.to = to
            self.start = start
        }

        public func zoom(at date: Date) -> Double {
            let progress = min(max(date.timeIntervalSince(start) / Self.durationSeconds, 0), 1)
            let eased = progress * progress * (3 - 2 * progress)
            return from * pow(to / from, eased)
        }

        public func isFinished(at date: Date) -> Bool {
            date.timeIntervalSince(start) >= Self.durationSeconds
        }
    }
}
