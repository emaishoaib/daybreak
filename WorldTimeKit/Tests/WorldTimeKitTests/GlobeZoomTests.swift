import Foundation
import Testing
@testable import WorldTimeKit

struct GlobeZoomTests {
    @Test func zoomStaysWithinItsRange() {
        #expect(GlobeZoom.clamped(0.2) == GlobeZoom.range.lowerBound)
        #expect(GlobeZoom.clamped(9) == GlobeZoom.range.upperBound)
    }

    @Test func zoomingInAndOutUndoEachOther() {
        #expect(abs(GlobeZoom.zoomedOut(from: GlobeZoom.zoomedIn(from: 1.5)) - 1.5) < 1e-9)
    }

    @Test func zoomingOutNeverGoesBelowTheWholeGlobe() {
        #expect(GlobeZoom.zoomedOut(from: 1) == 1)
    }

    let start = Date(timeIntervalSince1970: 0)

    @Test func aTransitionStartsAtItsFirstZoom() {
        #expect(GlobeZoom.Transition(from: 1, to: 2.25, start: start).zoom(at: start) == 1)
    }

    @Test func aTransitionEndsAtItsTargetZoom() {
        let transition = GlobeZoom.Transition(from: 1, to: 2.25, start: start)
        #expect(abs(transition.zoom(at: start.addingTimeInterval(GlobeZoom.Transition.durationSeconds)) - 2.25) < 1e-9)
    }

    @Test func halfwayThroughATransitionFeelsHalfwayAtEitherScale() {
        let transition = GlobeZoom.Transition(from: 1, to: 2.25, start: start)
        #expect(abs(transition.zoom(at: start.addingTimeInterval(GlobeZoom.Transition.durationSeconds / 2)) - 1.5) < 1e-6)
    }

    @Test func aTransitionHoldsItsTargetOnceFinished() {
        let transition = GlobeZoom.Transition(from: 2.25, to: 1, start: start)
        let later = start.addingTimeInterval(5)
        #expect(transition.isFinished(at: later))
        #expect(transition.zoom(at: later) == 1)
    }
}
