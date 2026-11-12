import CoreGraphics

enum GlobeSize {
    case large
    case small

    var height: CGFloat {
        switch self {
        case .large: 240
        case .small: 110
        }
    }

    var toggled: GlobeSize {
        self == .large ? .small : .large
    }

    var showsTimes: Bool {
        self == .large
    }

    static func clamped(_ height: CGFloat) -> CGFloat {
        min(max(height, small.height), large.height)
    }

    static func settled(at height: CGFloat) -> GlobeSize {
        height < (small.height + large.height) / 2 ? .small : .large
    }
}
