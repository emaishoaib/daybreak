import Foundation
import Testing
@testable import WorldTimeKit

struct PlaceTests {
    let london = TimeZone(identifier: "Europe/London")!
    let londonPlace = Place(name: "London", timeZoneIdentifier: "Europe/London", coordinate: Coordinate(latitude: 51.51, longitude: -0.13))
    let newYork = Place(name: "New York", timeZoneIdentifier: "America/New_York", coordinate: Coordinate(latitude: 40.71, longitude: -74.01))
    let tokyo = Place(name: "Tokyo", timeZoneIdentifier: "Asia/Tokyo", coordinate: Coordinate(latitude: 35.68, longitude: 139.69))
    let kolkata = Place(name: "Kolkata", timeZoneIdentifier: "Asia/Kolkata", coordinate: Coordinate(latitude: 22.57, longitude: 88.36))

    func time(_ text: String) -> Date {
        ISO8601DateFormatter().date(from: text)!
    }

    func hours(_ hours: Double) -> TimeInterval {
        hours * 60 * 60
    }

    @Test func offsetIsTheGapBetweenTheTwoClocks() {
        #expect(tokyo.offset(from: london, at: time("2026-11-12T12:00:00Z")) == hours(9))
        #expect(newYork.offset(from: london, at: time("2026-11-12T12:00:00Z")) == hours(-5))
    }

    @Test func offsetKeepsHalfHourZones() {
        #expect(kolkata.offset(from: london, at: time("2026-11-12T12:00:00Z")) == hours(5.5))
    }

    @Test func offsetFollowsEachZonesOwnDaylightSaving() {
        #expect(newYork.offset(from: london, at: time("2026-03-15T12:00:00Z")) == hours(-4))
    }

    @Test func placesOnTheSameDateHaveNoDayDifference() {
        #expect(tokyo.dayDifference(from: london, at: time("2026-11-12T12:00:00Z")) == 0)
    }

    @Test func placeAheadPastMidnightIsOnTheNextDay() {
        #expect(tokyo.dayDifference(from: london, at: time("2026-11-12T20:00:00Z")) == 1)
    }

    @Test func placeBehindBeforeMidnightIsOnThePreviousDay() {
        #expect(newYork.dayDifference(from: london, at: time("2026-11-13T02:00:00Z")) == -1)
    }

    @Test func placeIsInDaylightAtMidday() {
        #expect(londonPlace.daylight(at: time("2026-11-12T12:00:00Z")) == .day)
    }

    @Test func placeIsInTwilightJustAfterSunset() {
        #expect(londonPlace.daylight(at: time("2026-11-12T16:35:00Z")) == .twilight)
    }

    @Test func placeIsInNightAtMidnight() {
        #expect(londonPlace.daylight(at: time("2026-11-12T00:00:00Z")) == .night)
    }

    @Test func identityCombinesTheZoneAndTheName() {
        #expect(tokyo.id == "Asia/Tokyo/Tokyo")
    }

    func place(named name: String) -> Place {
        Place(name: name, timeZoneIdentifier: "UTC", coordinate: Coordinate(latitude: 0, longitude: 0))
    }

    @Test func aOneWordPlaceIsShortenedToItsFirstThreeLetters() {
        #expect(place(named: "Cairo").shortCode == "CAI")
        #expect(place(named: "Amsterdam").shortCode == "AMS")
    }

    @Test func aPlaceOfSeveralWordsIsShortenedToItsInitials() {
        #expect(place(named: "New York").shortCode == "NY")
        #expect(place(named: "United Kingdom").shortCode == "UK")
    }

    @Test func smallLinkingWordsAreLeftOutOfTheInitials() {
        #expect(place(named: "Rio de Janeiro").shortCode == "RJ")
    }

    @Test func anythingAfterACommaIsIgnored() {
        #expect(place(named: "Hong Kong, China").shortCode == "HK")
    }
}
