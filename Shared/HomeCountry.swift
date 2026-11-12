import Foundation
import MapKit
import Observation

@MainActor
@Observable
final class HomeCountry {
    static let shared = HomeCountry()
    private static let key = "homeCountries"

    private(set) var name: String?

    func load(for timeZone: TimeZone = .autoupdatingCurrent) async {
        let zone = timeZone.identifier
        if let saved = Self.saved[zone] {
            name = saved
            return
        }
        guard let city = zone.split(separator: "/").last?.replacingOccurrences(of: "_", with: " ") else { return }
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = city
        request.resultTypes = .address
        guard let items = try? await MKLocalSearch(request: request).start().mapItems,
              let found = (items.first { $0.timeZone?.identifier == zone } ?? items.first)?.addressRepresentations?.regionName else { return }
        name = found
        UserDefaults.standard.set(Self.saved.merging([zone: found]) { $1 }, forKey: Self.key)
    }

    private static var saved: [String: String] {
        UserDefaults.standard.dictionary(forKey: key) as? [String: String] ?? [:]
    }
}
