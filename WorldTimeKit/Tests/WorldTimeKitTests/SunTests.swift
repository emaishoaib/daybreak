import Foundation
import Testing
@testable import WorldTimeKit

struct SunTests {
    func time(_ text: String) -> Date {
        ISO8601DateFormatter().date(from: text)!
    }

    @Test func sunStandsOverTheTropicOfCancerAtTheJuneSolstice() {
        #expect(abs(Sun.overhead(at: time("2026-06-21T08:24:00Z")).latitude - 23.44) < 0.05)
    }

    @Test func sunStandsOverTheTropicOfCapricornAtTheDecemberSolstice() {
        #expect(abs(Sun.overhead(at: time("2026-12-21T20:50:00Z")).latitude + 23.44) < 0.05)
    }

    @Test func sunStandsOverTheEquatorAtTheMarchEquinox() {
        #expect(abs(Sun.overhead(at: time("2026-03-20T14:46:00Z")).latitude) < 0.05)
    }

    @Test func sunIsNearlyOverGreenwichAtNoonInGreenwich() {
        #expect(abs(Sun.overhead(at: time("2026-03-20T12:00:00Z")).longitude) < 3)
    }

    @Test func sunMovesFifteenDegreesWestEveryHour() {
        let noon = Sun.overhead(at: time("2026-03-20T12:00:00Z")).longitude
        let oneOClock = Sun.overhead(at: time("2026-03-20T13:00:00Z")).longitude
        #expect(abs(noon - oneOClock - 15) < 0.1)
    }

    @Test func sunLongitudeWrapsAroundTheDateLine() {
        let longitude = Sun.overhead(at: time("2026-03-20T00:00:00Z")).longitude
        #expect(longitude >= -180 && longitude < 180)
        #expect(abs(abs(longitude) - 180) < 3)
    }

    @Test func sunIsStraightUpWhereItStandsOverhead() {
        let date = time("2026-11-12T14:00:00Z")
        #expect(abs(Sun.elevation(at: Sun.overhead(at: date), on: date) - 90) < 0.001)
    }

    @Test func sunIsStraightDownOnTheOtherSideOfTheEarth() {
        let date = time("2026-11-12T14:00:00Z")
        let overhead = Sun.overhead(at: date)
        let antipode = Coordinate(latitude: -overhead.latitude, longitude: overhead.longitude + 180)
        #expect(abs(Sun.elevation(at: antipode, on: date) + 90) < 0.001)
    }
}
