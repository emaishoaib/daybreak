import Testing
@testable import WorldTimeKit

struct SmartSwapTests {
    let unitedKingdom = Place(name: "United Kingdom", timeZoneIdentifier: "Europe/London", coordinate: Coordinate(latitude: 51.5, longitude: -0.12))
    let egypt = Place(name: "Egypt", timeZoneIdentifier: "Africa/Cairo", coordinate: Coordinate(latitude: 30.04, longitude: 31.24))
    let japan = Place(name: "Japan", timeZoneIdentifier: "Asia/Tokyo", coordinate: Coordinate(latitude: 35.68, longitude: 139.69))
    let cairo = Place(name: "Cairo", timeZoneIdentifier: "Africa/Cairo", coordinate: Coordinate(latitude: 30.04, longitude: 31.24))
    let newYork = Place(name: "New York", timeZoneIdentifier: "America/New_York", coordinate: Coordinate(latitude: 40.71, longitude: -74.01))

    @Test func arrivingSomewhereOnTheListSwapsItForThePlaceYouLeft() {
        var swap = SmartSwap(places: [newYork, cairo])
        swap.travel(leaving: unitedKingdom, arrivingIn: "Africa/Cairo")
        #expect(swap.places == [newYork, unitedKingdom])
    }

    @Test func comingHomeBringsBackTheExactPlaceThatWasSwappedOut() {
        var swap = SmartSwap(places: [newYork, cairo])
        swap.travel(leaving: unitedKingdom, arrivingIn: "Africa/Cairo")
        swap.travel(leaving: egypt, arrivingIn: "Europe/London")
        #expect(swap.places == [newYork, cairo])
        #expect(swap.swappedOut[unitedKingdom.timeZoneIdentifier] == unitedKingdom)
    }

    @Test func arrivingSomewhereNotOnTheListAddsThePlaceYouLeftAtTheTop() {
        var swap = SmartSwap(places: [newYork])
        swap.travel(leaving: unitedKingdom, arrivingIn: "Asia/Tokyo")
        #expect(swap.places == [unitedKingdom, newYork])
    }

    @Test func movingOnFromASwapAddsBackTheOriginalPlaceRatherThanTheCountry() {
        var swap = SmartSwap(places: [cairo, newYork])
        swap.travel(leaving: unitedKingdom, arrivingIn: "Africa/Cairo")
        swap.travel(leaving: egypt, arrivingIn: "Asia/Tokyo")
        #expect(swap.places == [cairo, unitedKingdom, newYork])
        #expect(swap.swappedOut.isEmpty)
    }

    @Test func noPlaceIsEverLostAcrossATrip() {
        var swap = SmartSwap(places: [cairo, newYork])
        swap.travel(leaving: unitedKingdom, arrivingIn: "Africa/Cairo")
        swap.travel(leaving: egypt, arrivingIn: "Asia/Tokyo")
        swap.travel(leaving: japan, arrivingIn: "Europe/London")
        #expect(swap.places == [cairo, japan, newYork])
        #expect(swap.swappedOut[unitedKingdom.timeZoneIdentifier] == unitedKingdom)
    }

    @Test func thePlaceYouLeftIsNotAddedTwice() {
        var swap = SmartSwap(places: [unitedKingdom, newYork])
        swap.travel(leaving: unitedKingdom, arrivingIn: "Asia/Tokyo")
        #expect(swap.places == [unitedKingdom, newYork])
    }

    @Test func stayingInTheSameTimeZoneChangesNothing() {
        var swap = SmartSwap(places: [cairo])
        swap.travel(leaving: unitedKingdom, arrivingIn: "Europe/London")
        #expect(swap == SmartSwap(places: [cairo]))
    }
}
