import Foundation
import Testing
@testable import WorldTimeKit

struct DayGroupTests {
    let london = TimeZone(identifier: "Europe/London")!
    let newYork = Place(name: "New York", timeZoneIdentifier: "America/New_York", coordinate: Coordinate(latitude: 40.71, longitude: -74.01))
    let tokyo = Place(name: "Tokyo", timeZoneIdentifier: "Asia/Tokyo", coordinate: Coordinate(latitude: 35.68, longitude: 139.69))
    let kolkata = Place(name: "Kolkata", timeZoneIdentifier: "Asia/Kolkata", coordinate: Coordinate(latitude: 22.57, longitude: 88.36))
    let evening = ISO8601DateFormatter().date(from: "2026-11-12T20:00:00Z")!

    @Test func placesOnTheSameDateShareAGroup() {
        let groups = DayGroup.groups(of: [tokyo, newYork, kolkata], from: london, at: evening)
        #expect(groups.map(\.dayDifference) == [0, 1])
        #expect(groups[1].places == [tokyo, kolkata])
    }

    @Test func groupsRunFromYesterdayToTomorrow() {
        let lateNight = ISO8601DateFormatter().date(from: "2026-11-13T02:00:00Z")!
        let groups = DayGroup.groups(of: [tokyo, newYork], from: london, at: lateNight)
        #expect(groups.map(\.dayDifference) == [-1, 0])
    }

    @Test func noPlacesMakeNoGroups() {
        #expect(DayGroup.groups(of: [], from: london, at: evening).isEmpty)
    }
}
