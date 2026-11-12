import Foundation
import Testing
@testable import WorldTimeKit

struct GlobeCameraTests {
    let start = Date(timeIntervalSince1970: 0)
    let wide = GlobeCamera(orientation: GlobeOrientation(centreLongitude: 0, tilt: 0))
    let cairo = Coordinate(latitude: 30.04, longitude: 31.24)

    @Test func focusingPutsThePlaceInTheMiddle() {
        let focused = wide.focused(on: cairo)
        let point = focused.orientation.viewPoint(of: cairo)
        #expect(abs(point.x) < 1e-9 && abs(point.y) < 1e-9)
    }

    @Test func focusingZoomsInALittle() {
        #expect(wide.focused(on: cairo).zoom == GlobeCamera.focusZoom)
    }

    @Test func focusingKeepsADeeperZoom() {
        #expect(wide.zoomed(to: 3).focused(on: cairo).zoom == 3)
    }

    @Test func aMotionStartsWhereItBegins() {
        let motion = GlobeMotion(from: wide, to: wide.focused(on: cairo), start: start, durationSeconds: 1)
        #expect(motion.camera(at: start) == wide)
    }

    @Test func aMotionEndsWhereItIsGoing() {
        let target = wide.focused(on: cairo)
        let motion = GlobeMotion(from: wide, to: target, start: start, durationSeconds: 1)
        let end = motion.camera(at: start.addingTimeInterval(1))
        #expect(abs(end.orientation.centreLongitude - target.orientation.centreLongitude) < 1e-9)
        #expect(abs(end.orientation.tilt - target.orientation.tilt) < 1e-9)
        #expect(abs(end.zoom - target.zoom) < 1e-9)
        #expect(motion.isFinished(at: start.addingTimeInterval(1)))
    }

    @Test func zoomingHalfwayFeelsHalfwayAtEitherScale() {
        let motion = GlobeMotion(from: wide, to: wide.zoomed(to: 2.25), start: start, durationSeconds: 1)
        #expect(abs(motion.camera(at: start.addingTimeInterval(0.5)).zoom - 1.5) < 1e-6)
    }

    @Test func turningTakesTheShortWayAcrossTheDateLine() {
        let from = GlobeCamera(orientation: GlobeOrientation(centreLongitude: 170, tilt: 0))
        let to = GlobeCamera(orientation: GlobeOrientation(centreLongitude: -170, tilt: 0))
        let halfway = GlobeMotion(from: from, to: to, start: start, durationSeconds: 1).camera(at: start.addingTimeInterval(0.5))
        #expect(abs(abs(halfway.orientation.centreLongitude) - 180) < 1e-6)
    }
}
