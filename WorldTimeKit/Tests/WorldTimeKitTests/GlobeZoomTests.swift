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
}
