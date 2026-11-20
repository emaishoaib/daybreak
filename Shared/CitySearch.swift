import MapKit
import Observation
import WorldTimeKit

@MainActor
@Observable
final class CitySearch: NSObject {
    private static let lookUpPause: Duration = .milliseconds(400)

    private(set) var results: [MKLocalSearchCompletion] = []
    private(set) var timeZones: [Place] = []
    private var foundPlaces: [String: Place] = [:]

    var query = "" {
        didSet {
            completer.queryFragment = query
            timeZones = TimeZoneSearch.places(matching: query)
        }
    }

    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.resultTypes = .address
        completer.addressFilter = MKAddressFilter(including: [.locality, .subAdministrativeArea, .administrativeArea, .country])
        completer.delegate = self
    }

    func foundPlace(for completion: MKLocalSearchCompletion) -> Place? {
        foundPlaces[Self.key(for: completion)]
    }

    func lookUpAfterPause(_ completion: MKLocalSearchCompletion) async {
        guard foundPlace(for: completion) == nil, (try? await Task.sleep(for: Self.lookUpPause)) != nil else { return }
        _ = await place(for: completion)
    }

    func place(for completion: MKLocalSearchCompletion) async -> Place? {
        if let place = foundPlace(for: completion) { return place }
        let place = await searchPlace(for: completion)
        foundPlaces[Self.key(for: completion)] = place
        return place
    }

    private func searchPlace(for completion: MKLocalSearchCompletion) async -> Place? {
        let request = MKLocalSearch.Request(completion: completion)
        request.resultTypes = .address
        guard let item = try? await MKLocalSearch(request: request).start().mapItems.first,
              let timeZone = item.timeZone else { return nil }
        let coordinate = item.location.coordinate
        return Place(
            name: item.name ?? completion.title,
            timeZoneIdentifier: timeZone.identifier,
            coordinate: Coordinate(latitude: coordinate.latitude, longitude: coordinate.longitude)
        )
    }

    private static func key(for completion: MKLocalSearchCompletion) -> String {
        "\(completion.title)\n\(completion.subtitle)"
    }
}

extension CitySearch: @MainActor MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        results = completer.results
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
        results = []
    }
}
