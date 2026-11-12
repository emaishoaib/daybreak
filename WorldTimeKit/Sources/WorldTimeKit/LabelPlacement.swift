public enum LabelPlacement {
    public enum Side: CaseIterable, Sendable {
        case right
        case left
        case above
        case below
    }

    public struct Point: Equatable, Sendable {
        public let x: Double
        public let y: Double

        public init(x: Double, y: Double) {
            self.x = x
            self.y = y
        }
    }

    public struct Size: Equatable, Sendable {
        public let width: Double
        public let height: Double

        public init(width: Double, height: Double) {
            self.width = width
            self.height = height
        }
    }

    struct Box: Equatable {
        let minX: Double
        let minY: Double
        let maxX: Double
        let maxY: Double

        func overlaps(_ other: Box) -> Bool {
            minX < other.maxX && other.minX < maxX && minY < other.maxY && other.minY < maxY
        }
    }

    public static func sides(for dots: [Point], labels: [Size], dotRadius: Double, gap: Double) -> [Side?] {
        var taken = dots.map { box(around: $0, radius: dotRadius) }
        return zip(dots, labels).map { dot, label in
            let side = Side.allCases.first { side in
                let candidate = box(for: label, beside: dot, on: side, dotRadius: dotRadius, gap: gap)
                return !taken.contains { $0.overlaps(candidate) }
            }
            if let side {
                taken.append(box(for: label, beside: dot, on: side, dotRadius: dotRadius, gap: gap))
            }
            return side
        }
    }

    public static func centre(of label: Size, beside dot: Point, on side: Side, dotRadius: Double, gap: Double) -> Point {
        let reach = dotRadius + gap
        return switch side {
        case .right: Point(x: dot.x + reach + label.width / 2, y: dot.y)
        case .left: Point(x: dot.x - reach - label.width / 2, y: dot.y)
        case .above: Point(x: dot.x, y: dot.y - reach - label.height / 2)
        case .below: Point(x: dot.x, y: dot.y + reach + label.height / 2)
        }
    }

    static func box(for label: Size, beside dot: Point, on side: Side, dotRadius: Double, gap: Double) -> Box {
        let centre = centre(of: label, beside: dot, on: side, dotRadius: dotRadius, gap: gap)
        return Box(
            minX: centre.x - label.width / 2,
            minY: centre.y - label.height / 2,
            maxX: centre.x + label.width / 2,
            maxY: centre.y + label.height / 2
        )
    }

    private static func box(around dot: Point, radius: Double) -> Box {
        Box(minX: dot.x - radius, minY: dot.y - radius, maxX: dot.x + radius, maxY: dot.y + radius)
    }
}
