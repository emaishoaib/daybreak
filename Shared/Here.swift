import CoreLocation
import Foundation
import MapKit
import Observation
import WorldTimeKit

@MainActor
@Observable
final class Here {
    static let shared = Here()
    private static let savedKey = "here"

    private(set) var timeZone: TimeZone
    private(set) var country: String?
    private(set) var city: String?
    private(set) var coordinate: Coordinate?

    var onTravel: ((Place, TimeZone) -> Void)?

    private init() {
        let saved = UserDefaults.standard.dictionary(forKey: Self.savedKey)
        timeZone = (saved?["timeZone"] as? String).flatMap(TimeZone.init(identifier:)) ?? .autoupdatingCurrent
        country = saved?["country"] as? String
        city = saved?["city"] as? String
        if let latitude = saved?["latitude"] as? Double, let longitude = saved?["longitude"] as? Double {
            coordinate = Coordinate(latitude: latitude, longitude: longitude)
        }
    }

    var place: Place {
        let fallbackName = timeZone.identifier.split(separator: "/").last.map { $0.replacingOccurrences(of: "_", with: " ") } ?? timeZone.identifier
        return Place(
            name: country ?? fallbackName,
            timeZoneIdentifier: timeZone.identifier,
            coordinate: coordinate ?? Coordinate(latitude: 0, longitude: Double(timeZone.secondsFromGMT()) / 240)
        )
    }

    var calendar: Calendar {
        var calendar = Calendar.autoupdatingCurrent
        calendar.timeZone = timeZone
        return calendar
    }

    func style(_ style: Date.FormatStyle) -> Date.FormatStyle {
        var style = style
        style.timeZone = timeZone
        return style
    }

    func refresh() async {
        if let coordinate = await CurrentLocation.coordinate(), await locate(at: coordinate) { return }
        await guessFromSystemTimeZone()
    }

    private func locate(at coordinate: Coordinate) async -> Bool {
        guard let request = MKReverseGeocodingRequest(location: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)),
              let item = try? await request.mapItems.first,
              let timeZone = item.timeZone else { return false }
        update(timeZone: timeZone, country: item.addressRepresentations?.regionName, city: item.addressRepresentations?.cityName, coordinate: coordinate)
        return true
    }

    private func guessFromSystemTimeZone() async {
        let system = TimeZone.autoupdatingCurrent
        guard system.identifier != timeZone.identifier || country == nil,
              let city = system.identifier.split(separator: "/").last?.replacingOccurrences(of: "_", with: " ") else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = city
        request.resultTypes = .address
        let items = (try? await MKLocalSearch(request: request).start().mapItems) ?? []
        let item = items.first { $0.timeZone?.identifier == system.identifier } ?? items.first
        let location = item?.location.coordinate
        update(
            timeZone: system,
            country: item?.addressRepresentations?.regionName,
            city: item?.addressRepresentations?.cityName ?? city,
            coordinate: location.map { Coordinate(latitude: $0.latitude, longitude: $0.longitude) }
        )
    }

    private func update(timeZone: TimeZone, country: String?, city: String?, coordinate: Coordinate?) {
        let left = place
        self.timeZone = timeZone
        self.country = country
        self.city = city
        self.coordinate = coordinate
        var saved: [String: Any] = ["timeZone": timeZone.identifier]
        saved["country"] = country
        saved["city"] = city
        saved["latitude"] = coordinate?.latitude
        saved["longitude"] = coordinate?.longitude
        UserDefaults.standard.set(saved, forKey: Self.savedKey)
        if left.timeZoneIdentifier != timeZone.identifier {
            onTravel?(left, timeZone)
        }
    }
}
