import Testing
@testable import WorldTimeKit

struct LabelPlacementTests {
    let label = LabelPlacement.Size(width: 50, height: 14)

    func sides(_ dots: [(Double, Double)]) -> [LabelPlacement.Side?] {
        LabelPlacement.sides(
            for: dots.map { LabelPlacement.Point(x: $0.0, y: $0.1) },
            labels: Array(repeating: label, count: dots.count),
            dotRadius: 3,
            gap: 4
        )
    }

    @Test func labelsFarApartBothSitOnTheRight() {
        #expect(sides([(0, 0), (0, 100)]) == [.right, .right])
    }

    @Test func aLabelThatWouldCoverTheNextDotMovesToTheLeft() {
        #expect(sides([(0, 0), (20, 0)]) == [.left, .right])
    }

    @Test func aLabelBoxedInOnBothSidesMovesAbove() {
        #expect(sides([(0, 0), (-20, 0), (20, 0)]) == [.above, .left, .right])
    }

    @Test func aLabelWithNowhereToGoIsHidden() {
        let crowd = [(0.0, 0.0), (-20.0, 0.0), (20.0, 0.0), (0.0, -20.0), (0.0, 20.0)]
        #expect(sides(crowd).first == .some(nil))
    }

    @Test func earlierLabelsGetFirstChoice() {
        #expect(sides([(20, 0), (0, 0)]) == [.right, .left])
    }

    @Test func aLabelCentresBesideItsDot() {
        let centre = LabelPlacement.centre(of: label, beside: LabelPlacement.Point(x: 10, y: 10), on: .left, dotRadius: 3, gap: 4)
        #expect(centre == LabelPlacement.Point(x: -22, y: 10))
    }
}
