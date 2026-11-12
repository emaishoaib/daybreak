import Testing
@testable import WorldTimeKit

struct GlobeOrientationTests {
    func isClose(_ point: ViewPoint, _ x: Double, _ y: Double, _ z: Double) -> Bool {
        abs(point.x - x) < 1e-9 && abs(point.y - y) < 1e-9 && abs(point.z - z) < 1e-9
    }

    @Test func theCentreOfTheGlobeFacesTheViewer() {
        let orientation = GlobeOrientation(centreLongitude: 30)
        let centre = Coordinate(latitude: GlobeOrientation.defaultTiltDegrees, longitude: 30)
        #expect(isClose(orientation.viewPoint(of: centre), 0, 0, 1))
    }

    @Test func aPlaceAQuarterTurnEastSitsOnTheRightEdge() {
        let orientation = GlobeOrientation(centreLongitude: 0, tilt: 0)
        #expect(isClose(orientation.viewPoint(of: Coordinate(latitude: 0, longitude: 90)), 1, 0, 0))
    }

    @Test func theNorthPoleLeansTowardsTheViewer() {
        let pole = GlobeOrientation(centreLongitude: 0).viewPoint(of: Coordinate(latitude: 90, longitude: 0))
        #expect(pole.y > 0.9)
        #expect(pole.facesViewer)
    }

    @Test func theFarSideOfTheGlobeFacesAway() {
        let orientation = GlobeOrientation(centreLongitude: 0)
        #expect(!orientation.viewPoint(of: Coordinate(latitude: 0, longitude: 180)).facesViewer)
    }

    @Test func turningWrapsAroundTheDateLine() {
        #expect(GlobeOrientation(centreLongitude: 170).turned(byDegrees: 20).centreLongitude == -170)
        #expect(GlobeOrientation(centreLongitude: -170).turned(byDegrees: -20).centreLongitude == 170)
    }

    @Test func turningMovesTheCentreWithTheGlobe() {
        let orientation = GlobeOrientation(centreLongitude: 0, tilt: 0).turned(byDegrees: 90)
        #expect(isClose(orientation.viewPoint(of: Coordinate(latitude: 0, longitude: 90)), 0, 0, 1))
    }

    @Test func tiltingMovesTheCentreNorth() {
        let orientation = GlobeOrientation(centreLongitude: 0, tilt: 0).tilted(byDegrees: 50)
        let london = orientation.viewPoint(of: Coordinate(latitude: 50, longitude: 0))
        #expect(abs(london.z - 1) < 1e-9)
    }

    @Test func tiltingStopsShortOfThePoles() {
        #expect(GlobeOrientation(centreLongitude: 0).tilted(byDegrees: 200).tilt == GlobeOrientation.tiltLimitDegrees)
        #expect(GlobeOrientation(centreLongitude: 0).tilted(byDegrees: -200).tilt == -GlobeOrientation.tiltLimitDegrees)
    }
}
