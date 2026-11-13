import Foundation
import Testing
@testable import WorldTimeKit

struct TimeZoneSearchTests {
    let english = Locale(identifier: "en_US")

    @Test func anAbbreviationFindsItsTimeZoneFirst() {
        let first = TimeZoneSearch.places(matching: "pst", locale: english).first
        #expect(first?.timeZoneIdentifier == "America/Los_Angeles")
        #expect(first?.name == "Pacific Time")
    }

    @Test func partOfANameFindsItsTimeZone() {
        let identifiers = TimeZoneSearch.places(matching: "pacific", locale: english).map(\.timeZoneIdentifier)
        #expect(identifiers.contains("America/Los_Angeles"))
    }

    @Test func foundTimeZonesHaveNoPlaceOnTheMap() {
        let places = TimeZoneSearch.places(matching: "utc", locale: english)
        #expect(!places.isEmpty)
        #expect(places.allSatisfy { $0.isTimeZone })
    }

    @Test func aTimeZoneWithTwoAbbreviationsAppearsOnce() {
        let identifiers = TimeZoneSearch.places(matching: "p", locale: english).map(\.timeZoneIdentifier)
        let pacificCount = identifiers.filter { $0 == "America/Los_Angeles" }.count
        #expect(pacificCount <= 1)
    }

    @Test func utcIsItsOwnZoneRatherThanGreenwichMeanTime() {
        let first = TimeZoneSearch.places(matching: "utc", locale: english).first
        #expect(first?.timeZoneIdentifier == "Etc/UTC")
        #expect(first?.name == "Coordinated Universal Time")
        #expect(first?.shortCode == "UTC")
    }

    @Test func anEmptyQueryFindsNothing() {
        #expect(TimeZoneSearch.places(matching: "  ", locale: english).isEmpty)
    }
}
